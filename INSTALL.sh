#!/bin/bash -eu

_hasCommand () {
  type "$1" > /dev/null 2>&1 && return 0
  return 1
}

_setConfig(){
  if [[ -f $2 ]]
  then
    mv $2 $2.default-config
  fi
  ln -s $1 $2
}

echo -n "Input current workspace name -> "
read ws_name
echo "export ZSH_WORKSPACE=""'""$ws_name""'" >> config

echo -n "Input Wttr.in Location -> "
read wttr
echo "export WTTR_LOCATION=""'""$wttr""'" >> config

# Dependency

_hasCommand zsh  || echo "WARNING: zsh  is not found!"
_hasCommand perl || echo "WARNING: perl is not found!"
_hasCommand git  || echo "WARNING: git  is not found!"

curl -fsSL git.io/antigen > $HOME/.zsh/custom-available.d/antigen.zsh

ln -s $HOME/.zsh/.zshenv $HOME/

mkdir -p $HOME/.zsh/custom-enable.d/
mkdir -p $HOME/.zsh/custom.d/
touch    $HOME/.zsh/MEMO.txt
mkdir -p $HOME/.local/packages


# linked dotFiles
dotBase="$HOME/.zsh/src.dotfiles"
_setConfig  ${dotBase}/bash_run_cmd.sh $HOME/.bashrc # .bashrc
_setConfig  ${dotBase}/htop_run_cmd.config $HOME/.config/htop/htoprc
_setConfig  ${dotBase}/tmux.conf $HOME/.tmux.conf




cat <<EOF
+----------------------+
| SETUP SUCCESSFUL !!! |
+----------------------+
EOF

