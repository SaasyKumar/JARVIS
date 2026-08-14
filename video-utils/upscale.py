import argparse
import os
import subprocess
import sys
import tempfile
import types
from pathlib import Path

# Compatibility fix for newer torchvision versions with basicsr
import torchvision.transforms.functional as F_trans

try:
    import torchvision.transforms.functional_tensor  # noqa: F401
except ModuleNotFoundError:
    mod = types.ModuleType("torchvision.transforms.functional_tensor")
    mod.rgb_to_grayscale = F_trans.rgb_to_grayscale
    sys.modules["torchvision.transforms.functional_tensor"] = mod

import cv2
import torch
from basicsr.archs.rrdbnet_arch import RRDBNet
from realesrgan import RealESRGANer
from tqdm import tqdm

MODEL_URLS = {
    "RealESRGAN_x2plus": "https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.1/RealESRGAN_x2plus.pth",
    "RealESRGAN_x4plus": "https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth",
    "RealESRNet_x4plus": "https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.1/RealESRNet_x4plus.pth",
    "RealESRGAN_x4plus_anime_6B": "https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.2.4/RealESRGAN_x4plus_anime_6B.pth",
}


def get_default_device():
    if torch.cuda.is_available():
        return torch.device("cuda")
    if torch.backends.mps.is_available():
        return torch.device("mps")
    return torch.device("cpu")


def upscale_video(
    input_file,
    output_file=None,
    scale=2,
    model_name=None,
    tile=512,
    tile_pad=10,
    pre_pad=0,
    device_name="auto",
    half=False,
):
    input_path = Path(input_file).resolve()
    if not input_path.exists():
        raise FileNotFoundError(f"Input file not found: {input_path}")

    if output_file:
        output_path = Path(output_file).resolve()
    else:
        output_path = input_path.with_name(
            f"{input_path.stem}_upscaled{input_path.suffix}"
        )

    if device_name == "auto":
        device = get_default_device()
    else:
        device = torch.device(device_name)

    if model_name is None:
        model_name = "RealESRGAN_x2plus" if scale == 2 else "RealESRGAN_x4plus"

    model_path = MODEL_URLS.get(model_name, model_name)

    # Configure model architecture
    if model_name == "RealESRGAN_x4plus_anime_6B":
        model = RRDBNet(
            num_in_ch=3,
            num_out_ch=3,
            num_feat=64,
            num_block=6,
            num_grow_ch=32,
            scale=4,
        )
        scale = 4
    elif model_name == "RealESRGAN_x2plus" or scale == 2:
        model = RRDBNet(
            num_in_ch=3,
            num_out_ch=3,
            num_feat=64,
            num_block=23,
            num_grow_ch=32,
            scale=2,
        )
        scale = 2
    else:
        model = RRDBNet(
            num_in_ch=3,
            num_out_ch=3,
            num_feat=64,
            num_block=23,
            num_grow_ch=32,
            scale=4,
        )
        scale = 4

    cap = cv2.VideoCapture(str(input_path))
    if not cap.isOpened():
        raise RuntimeError(f"Could not open video file: {input_path}")

    fps = cap.get(cv2.CAP_PROP_FPS)
    frame_count = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

    print(f"--- Video Upscaling Configuration ---")
    print(f"Input:       {input_path}")
    print(f"Output:      {output_path}")
    print(f"Resolution:  {width}x{height} -> {width * scale}x{height * scale}")
    print(f"FPS:         {fps:.2f}")
    print(f"Frames:      {frame_count}")
    print(f"Model:       {model_name} (scale: {scale}x)")
    print(f"Device:      {device}")
    print(f"--------------------------------------")

    upsampler = RealESRGANer(
        scale=scale,
        model_path=model_path,
        model=model,
        tile=tile,
        tile_pad=tile_pad,
        pre_pad=pre_pad,
        half=half,
        device=device,
    )

    with tempfile.TemporaryDirectory() as temp_dir:
        temp_dir_path = Path(temp_dir)
        frame_dir = temp_dir_path / "frames"
        frame_dir.mkdir()

        frame_number = 0
        pbar = tqdm(total=frame_count, desc="Upscaling frames", unit="frame")

        while True:
            ret, frame = cap.read()
            if not ret:
                break

            output, _ = upsampler.enhance(frame, outscale=scale)

            frame_path = frame_dir / f"{frame_number:08d}.png"
            cv2.imwrite(str(frame_path), output)

            frame_number += 1
            pbar.update(1)

        pbar.close()
        cap.release()

        print("\nEncoding video with ffmpeg...")

        subprocess.run(
            [
                "ffmpeg",
                "-y",
                "-framerate",
                str(fps),
                "-i",
                str(frame_dir / "%08d.png"),
                "-i",
                str(input_path),
                "-map",
                "0:v:0",
                "-map",
                "1:a?",
                "-c:v",
                "libx264",
                "-preset",
                "medium",
                "-crf",
                "18",
                "-pix_fmt",
                "yuv420p",
                "-c:a",
                "copy",
                "-shortest",
                str(output_path),
            ],
            check=True,
        )

    print(f"\nSuccessfully upscaled video!")
    print(f"Output saved to: {output_path}")


def main():
    parser = argparse.ArgumentParser(description="AI Video Upscaling using Real-ESRGAN")
    parser.add_argument("input", help="Path to input video file (e.g. clip_1.mp4)")
    parser.add_argument("-o", "--output", help="Path to output video file (optional)")
    parser.add_argument(
        "-s",
        "--scale",
        type=int,
        choices=[2, 4],
        default=2,
        help="Upscale scale factor (2 or 4, default: 2)",
    )
    parser.add_argument(
        "-m",
        "--model_name",
        type=str,
        default=None,
        help="Model name (e.g. RealESRGAN_x2plus, RealESRGAN_x4plus, RealESRGAN_x4plus_anime_6B)",
    )
    parser.add_argument(
        "-t",
        "--tile",
        type=int,
        default=256,
        help="Tile size, 0 for no tile (default: 256)",
    )
    parser.add_argument(
        "--tile_pad",
        type=int,
        default=10,
        help="Tile padding (default: 10)",
    )
    parser.add_argument(
        "--pre_pad",
        type=int,
        default=0,
        help="Pre padding size (default: 0)",
    )
    parser.add_argument(
        "--device",
        type=str,
        default="auto",
        choices=["auto", "mps", "cuda", "cpu"],
        help="Computing device (default: auto)",
    )
    parser.add_argument(
        "--half",
        action="store_true",
        help="Use half precision (fp16) for faster inference",
    )

    args = parser.parse_args()

    upscale_video(
        input_file=args.input,
        output_file=args.output,
        scale=args.scale,
        model_name=args.model_name,
        tile=args.tile,
        tile_pad=args.tile_pad,
        pre_pad=args.pre_pad,
        device_name=args.device,
        half=args.half,
    )


if __name__ == "__main__":
    main()