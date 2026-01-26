                  # get glyph code name pair as dict

import xml.etree.ElementTree as ET
def extract_glyph_names(svg_file):
    # Parse the SVG file
    tree = ET.parse(svg_file)
    root = tree.getroot()

    glyph_elements = root.findall(".//*{http://www.w3.org/2000/svg}glyph")
    #. ==> current node, // ==>descendants *{} ==> wildcard that matches svg <svg xmlns="http://www.w3.org/2000/svg"><glyph></svg>

    glyph_names = {}
    for glyph in glyph_elements:
        glyph_name = glyph.get('glyph-name')
        glyph_code = repr(glyph.get('unicode')) #output in unicode
        if (glyph_name and glyph_code):
            #excluding ' and \u
            glyph_names[glyph_code[-5:-1]] = glyph_name
    return glyph_names

svg_file_path = '/content/zchat.svg'#svgfile
glyph_names = extract_glyph_names(svg_file_path)
# print(glyph_names)
# print(len(glyph_names))
#js file

#----------------------------------------------------------------------------------------------

def copy_to_new_file(source_file, new_file):
    try:
        with open(source_file, 'r') as source:
            content = source.read()

        # Open the new file in write mode (this will create the file if it doesn't exist)
        with open(new_file, 'w') as destination:
            # Write the content to the new file
            destination.write(content)
            destination.close()

        print(f"Content copied from {source_file} to {new_file} successfully.")
    except FileNotFoundError:
        print(f"Error: The source file {source_file} was not found.")
    except IOError:
        print(f"Error: An I/O error occurred.")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

source_file = 'fontfile.css' #TODO: change
new_file = 'outputfile.css' #TODO:

copy_to_new_file(source_file, new_file)

#----------------------------------------------------------------------------------------------
# Check and append class
prefix=".Movie-" #TODO:
suffix=":before " #TODO:
outstirng = []
count =0

for key in glyph_names:
  with open("outputfile.css", 'r') as target:
    already_available = False
    print(key)
    for line in target:
      # Check if the word is in the line
      if key in line:
        print(key+" found in ")
        print(line)
        already_available = True
        count=count +1
        break
    if already_available:
      continue
    else:
      outstirng.append(prefix+glyph_names[key].lower()+suffix+"{ content: \"\\"+key+"\"; }\n")


print(len(outstirng))
print(count)
with open("outputfile.css", 'a') as target:
  for each in outstirng:
    target.write(each)