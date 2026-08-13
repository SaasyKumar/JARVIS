SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
#or use ${BASH_SOURCE[0]}
source "$SCRIPT_DIR/color.sh"

echo -e"First they ${Yellow}ignore${Color_Off} you,"
echo -e"then they ${On_IBlue}laugh${Color_Off} at you,"
echo -e"then you ${BRed}Nuke${Color_Off} them"
echo -e"${BIGreen}then you win"