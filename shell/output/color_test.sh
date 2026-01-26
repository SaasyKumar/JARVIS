SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
#or use ${BASH_SOURCE[0]}
source "$SCRIPT_DIR/color.sh"

echo "First they ${Yellow}ignore${Color_Off} you,"
echo "then they ${On_IBlue}laugh${Color_Off} at you,"
echo "then you ${BRed}Nuke${Color_Off} them"
echo "${BIGreen}then you win"