#!/bin/bash
#install startScreen and prompt for the current user


if [ -z $1 ]; then
  USERCOLOR="txtGreen"
else
  if [ "$1" == "-u" ]; then
    echo Usage:
    echo "  $0 [-u] : display usage"
    echo "  -- or --"
    echo "  $0 [userColor] [hostColor] [workingDirColor]: if a color is present, it sets the respective color as such"
    echo "  available colors:"
    for color in $(grep ".*=.*# " prompt  | sed 's/=.*//'); do
        if [ "$color" != "reset" ]; then
           echo -n $color,
        fi
    done;
    echo ""

  else
     USERCOLOR=$1
  fi
fi
if [ -z $2 ]; then
  HOSTCOLOR="undGreen"
else
  HOSTCOLOR=$2
fi
if [ -z $3 ]; then
  WDCOLOR="txtCyan"
else
  WDCOLOR=$3
fi

USERNAME=$(basename $HOME)
SCRIPT_DIR=$(dirname $0)
ROOT_DIR=~/.$USERNAME

if [ ! -d $ROOT_DIR ]; then
  mkdir $ROOT_DIR
fi

function install_file
{
  ROOT=$1
  CURDIR=$2
  FILE=$3
  FILE_TO_SOURCE=$4
  CURRENT_FILE=$ROOT/$FILE

  cp $CURDIR/$FILE $ROOT/$FILE 2> /dev/null
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

install_file $ROOT_DIR $SCRIPT_DIR prompt .bashrc
#edit the prompt file
sed -i 's/userColor=.*/userColor=$USERCOLOR/' $ROOT_DIR/prompt
sed -i 's/hostColor=.*/hostColor=$HOSTCOLOR/' $ROOT_DIR/prompt
sed -i 's/wdColor=.*/wdColor=$WDCOLOR/' $ROOT_DIR/prompt

install_file $ROOT_DIR $SCRIPT_DIR startTmux .bashrc
#install tmux configuration file
cp $CURDIR/tmux.conf $HOME/.tmux.conf 2> /dev/null
cp $CURDIR/vimrc $ROOT/.vimrc 2> /dev/null

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
