# Copy files
The util scripts in this folder will help you in copying process.
These utils are actually made for my cases, then I thought this might be useful to yours. So I uploaded this in git.

# Org2Dev - Original to Development directory copying
This shell script is used to **sync**( i.e to copy content in files that are already exist in the destination folder BASED ON FILENAME).
```sh
```
As a developer I maintain 2 directories, one for project repo and another development repo. the development repo have extra files and I will create new files just for testing in dev. This won't be problem when we copy files from Project repo to Dev repo.
But when it get reverse from dev to original `cp` command will copy unwanted test files too.
* To overcome `cp` disadvantage in reverse process
* To give clear cut idea of what being copied and to where
* To give the user **git branch** check before the operation
* GIT is **Crucial** for this script in both sides(dev and org)

## What you need to do
* `SRC_DIR` -> dev directory, `DST_DIR` -> Original project repo
* `CP_ARRAY` -> If you want to copy certain folders alone (*optional*)

## Execution
* `./org2dev.sh [Git Dest BranchName] [REVERSE]` 
* REVERSE -> leave it or true only on reverse copy i.e from dev to original repo (*optional*)
* will fail if wrong branch name is given, was done intentionally done to prevent copying in wrong branch

* The below images will show the execution (sorry if some part of images are blurred like some Japanese stuffs)
![😭](../images/o2d1.png)
* If the branch name not match you will get error message and the process will be aborted
![😭](../images/o2d2.png)
* Success
![😭](../images/o2d3.png)
* The reverse the same but an extra true
```sh
./org2dev.sh master true
```

# Combine file
This shell script used to combine multiple files and give an output file. If the output file already exist it clear all the file content and rewrite it.
* `file1`, `file2`, `file3`, `output` variables need to be changed where first 3 is input files relative path + filename  that need to be combined and output is the destination file

