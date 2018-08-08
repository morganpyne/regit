#!/bin/bash
#
# Run an arbitrary git cmd recursively on all repos 
# under the current directory
#
# Defaults to "status" if no argument is supplied

shift
CMD=${@:-status}

DIR=$(PWD)

# Check if the terminal supports colours

if test -t 1; then
    ncolors=$(tput colors)
    if test -n "$ncolors" && test $ncolors -ge 8; then
        bold="$(tput bold)"
        underline="$(tput smul)"
        standout="$(tput smso)"
        normal="$(tput sgr0)"
        black="$(tput setaf 0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        yellow="$(tput setaf 3)"
        blue="$(tput setaf 4)"
        magenta="$(tput setaf 5)"
        cyan="$(tput setaf 6)"
        white="$(tput setaf 7)"
    fi
fi

# Loop over all the subdirectories. For each one that looks
# like it contains a git repo run the git cmd in a subshell, asynchronously
# (This parallelises git operations, speeds things up)
# Wait until all subshells are finished

for REPO in $(find $DIR -type d -name ".git"); do
  GITPATH=${REPO%/.git} # Strip the "/.git" off the path
  (cd "$GITPATH"  > /dev/null && GITBRANCH=$(git rev-parse --abbrev-ref HEAD) \
   && GITOUTPUT=$(git $CMD 2>&1); \
   echo -e "${green}${GITPATH} ${yellow}[${GITBRANCH}]${normal}\n${GITOUTPUT}") & 
done
wait
