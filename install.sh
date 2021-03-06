#!/bin/bash
#install startScreen and prompt for the current user


if [ -z $1 ]; then
  USERCOLOR="Green"
else
  if [ "$1" == "-u" ]; then
    echo Usage:
    echo "  $0 [-u] : display usage"
    echo "  -- or --"
    echo "  $0 [userColor] [hostColor] [workingDirColor] [gitBranchColor]: if a color is present, it sets the respective color as such"
    echo "  available colors:"
    for color in $(grep ".*=.*# " prompt  | sed 's/=.*//'); do
        if [ "$color" != "reset" ]; then
           echo -n $color,
        fi
    done;
    echo ""
    exit 0

  else
     USERCOLOR=$1
  fi
fi
if [ -z $2 ]; then
  HOSTCOLOR="uGreen"
else
  HOSTCOLOR=$2
fi
if [ -z $3 ]; then
  WDCOLOR="LightCyan"
else
  WDCOLOR=$3
fi
if [ -z $4 ]; then
  DATECOLOR="DarkGrey"
else
  DATECOLOR=$4
fi
if [ -z $5 ]; then
  BRANCHCOLOR="Red"
else
  BRANCHCOLOR=$5
fi

USERNAME=$(basename $HOME)
SCRIPT_DIR=$(dirname $0)
ROOT_DIR=~/.$USERNAME

if [ ! -d $ROOT_DIR ]; then
  mkdir $ROOT_DIR
fi

function install_var
{
   VARNAME=$1
   VARVALUE=$2
   FILE=$3
   EXPORT=$4
   EXPORT_TEXT=""
   if [ ! -z $EXPORT ]; then
     EXPORT_TEXT="export "
   fi
   grep "${EXPORT_TEXT}$VARNAME=" $FILE >/dev/null
   if [ $? = 1 ]; then
     echo "Adding ${EXPORT_TEXT}$VARNAME=$VARVALUE to $FILE"
     echo ${EXPORT_TEXT}$VARNAME=$VARVALUE >> $FILE
   else
     echo "Updating $VARNAME to $VARVALUE in $FILE"
     sed -i "s/\(${EXPORT_TEXT}$VARNAME\)=.*/\1=$VARVALUE/" $FILE >/dev/null
   fi
}

function install_file
{
  ROOT=$1
  CURDIR=$2
  FILE=$3
  NEW_FILE_NAME=$4
  FILE_TO_SOURCE=$5
  CURRENT_FILE=$ROOT/$FILE

  if [ -z $NEW_FILE_NAME ]; then 
     NEW_FILE_NAME=$FILE
  fi
  cp $CURDIR/$FILE $ROOT/$NEW_FILE_NAME 2> /dev/null
  if [ $FILE_TO_SOURCE ]; then 
    grep "if \[ $ROOT/$FILE \]; then" $HOME/$FILE_TO_SOURCE >/dev/null
    if [ $? = 1 ]; then
      echo "Adding '$FILE' to $FILE_TO_SOURCE"
      echo "if [ $ROOT/$FILE ]; then" >> $HOME/$FILE_TO_SOURCE 
      echo "  . $ROOT/$FILE" >> $HOME/$FILE_TO_SOURCE 
      echo "fi" >> $HOME/$FILE_TO_SOURCE 
      echo "" >> $HOME/$FILE_TO_SOURCE 
    else
      echo "found '$FILE' in $FILE_TO_SOURCE"
    fi
  fi
}

install_file $ROOT_DIR $SCRIPT_DIR prompt prompt .bashrc
#edit the prompt file
install_var userColor $USERCOLOR $ROOT_DIR/prompt
install_var hostColor $HOSTCOLOR $ROOT_DIR/prompt
install_var wdColor $WDCOLOR $ROOT_DIR/prompt
install_var dateColor $DATECOLOR $ROOT_DIR/prompt
install_var branchColor $BRANCHCOLOR $ROOT_DIR/prompt

install_file $HOME $SCRIPT_DIR vimrc .vimrc
install_file $ROOT_DIR $SCRIPT_DIR startTmux startTmux .bashrc
install_file $ROOT_DIR $SCRIPT_DIR git-completion.bash git-completion.bash .bashrc
install_file $ROOT_DIR $SCRIPT_DIR git-prompt.sh git-prompt.sh .$USERNAME/prompt

#install tmux configuration file
cp $CURDIR/tmux.conf $HOME/.tmux.conf 2> /dev/null
cp $CURDIR/vimrc $ROOT/.vimrc 2> /dev/null

#add vi as the editor of choice
install_var EDITOR vi $HOME/.bashrc export

#add the alias for the exit screen

if [ ! -f $HOME/.bash_aliases ]; then
  touch $HOME/.bash_aliases
fi

grep "alias ss=" $HOME/.bash_aliases >/dev/null
if [ $? = 1 ]; then
  echo "Adding alias for 'ss' to .bash_aliases"
  echo "alias ss='. $HOME/.$USER/startTmux'" >> $HOME/.bash_aliases
else
  echo "found 'ss' in .bash_aliases"
fi
