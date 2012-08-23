#!/bin/bash
#install startScreen and prompt for the current user

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
install_file $ROOT_DIR $SCRIPT_DIR startScreen .bashrc

#add the alias for the exit screen

if [ ! -f $HOME/.bash_aliases ]; then
  touch $HOME/.bash_aliases
fi

grep "alias exits=" $HOME/.bash_aliases >/dev/null
if [ $? = 1 ]; then
  echo "Adding alias for 'exits' to .bash_aliases"
  echo "alias exits='screen -D \$STY > /dev/null'" >> $HOME/.bash_aliases
else
  echo "found 'exits' in .bash_aliases"
fi