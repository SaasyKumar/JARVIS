CURRENT_DIR=$(pwd)
SRC_DIR="$HOME/" #TODO:original repo directory use $HOME instead of ~ to avoid error
DST_DIR="$CURRENT_DIR/" #TODO:dev setup directory
CP_ARRAY=("javascript/" "style/" "outterfile.js") #TODO:only folders or files need to be copied or if need to copy entire folder use ("")
#FYI the whole code only copies files having same name in both src and dst


Color_Off=$'\033[0m'       # Text Reset
Red=$'\033[0;31m'          # Red
Cyan=$'\033[0;36m'         # Cyan
BGreen=$'\033[1;32m'       # Green
BYellow=$'\033[1;33m'      # Yellow

if [ -z "$1" ]; then
#   Only allow when a param is passed; accepts branch name of destination
  echo "${Red}Error: No branch name provided.${Color_Off} Usage: $0 <param>"
  exit 1
fi

GITBRANCH=$1
REVERSE=$2 #if you want copy files from original repo to dev setup, pass 2nd param as 'true'

if [[ "$REVERSE" == "true" || "$REVERSE" == "TRUE" || "$REVERSE" == "TRUE" ]]; then
        TEMP=$SRC_DIR
        SRC_DIR=$DST_DIR
        DST_DIR=$TEMP
    #SWAPING the src and target to perform copy from original repo to dev setup
        echo "${Cyan}reverse copy${Color_Off}"
fi

cd $SRC_DIR || exit 1
CURRENTBRANCH=$(git rev-parse --abbrev-ref HEAD) #returns the current branch name

#Confirmation
echo "the file in the branch ${BGreen}'$CURRENTBRANCH'${Color_Off} will be copied."
echo "From ${BYellow}$SRC_DIR${Color_Off} to ${BYellow}$DST_DIR${Color_Off}"
read -r -p "Do you want to continue? (y/n) [y]: " ANSWER
ANSWER=${ANSWER:-y}
if [[ "$ANSWER" == "y" || "$ANSWER" == "Y" ]]; then
        echo "initiating..."
else
        echo "${Red}aborting.."
        exit 1
fi

#destination branch check
cd $DST_DIR || exit 1
TARGETBRANCHNAME=$(git rev-parse --abbrev-ref HEAD)

if [ "$GITBRANCH" == "$TARGETBRANCHNAME" ]; then
        echo "Copying to branch $DST_DIR having HEAD at '$TARGETBRANCHNAME'"
        for i in "${CP_ARRAY[@]}"; do
		    echo "Copying $i..."
        	rsync -rt --exclude=".git" --existing "$SRC_DIR/$i" "$DST_DIR/$i"
       	done

        # -r: Recursive, copies directories
        #COPY ONLY THE FILES WHICH HAVE SAME FILE NAME IN BOTH SRC AND DST
        #Can use multiple rsync if you want to copy specific folders or add '/foldername' at the end of src and dst
        exit 1
else
        echo "${Red}Target branch not the same${Color_Off}"
        echo "Target branch is ${BGreen}$TARGETBRANCHNAME${Color_Off}, but the given branch is ${BYellow}$GITBRANCH${Color_Off}"
        exit 1
fi
