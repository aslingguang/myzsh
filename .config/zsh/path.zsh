# echo 'root' | sudo -S ln -s /mnt/wslg/.X11-unix /tmp/.X11-unix &> /dev/null
if [[ $(locale -a 2>/dev/null) == *zh_CN.utf8* ]]; then
  export LANG="zh_CN.UTF-8"
  export LC_ALL="zh_CN.UTF-8"
fi   

# miniconda3环境变量
if [[ -d "/opt/miniconda3" ]]; then
  # >>> conda initialize >>>
  # !! Contents within this block are managed by 'conda init' !!
  __conda_setup="$('/opt/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
      eval "$__conda_setup"
  else
      if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
          . "/opt/miniconda3/etc/profile.d/conda.sh"
      else
          export PATH="/opt/miniconda3/bin:$PATH"
      fi
  fi
  unset __conda_setup
  # <<< conda initialize <<<

  # 解决clear在anconda环境下无法使用
  export TERMINFO=/usr/share/terminfo 
elif [[ -d "/opt/miniconda" ]]; then
  # >>> conda initialize >>>
  # !! Contents within this block are managed by 'conda init' !!
  __conda_setup="$('/opt/miniconda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
      eval "$__conda_setup"
  else
      if [ -f "/opt/miniconda/etc/profile.d/conda.sh" ]; then
          . "/opt/miniconda/etc/profile.d/conda.sh"
      else
          export PATH="/opt/miniconda/bin:$PATH"
      fi
  fi
  unset __conda_setup
  # <<< conda initialize <<<

  # 解决clear在anconda环境下无法使用
  export TERMINFO=/usr/share/terminfo 
fi

# idea脚本
if [[ -d "/opt/JetBrains/jetbra/vmoptions" ]]; then
  export IDEA_VM_OPTIONS="/opt/JetBrains/jetbra/vmoptions/idea.vmoptions"
fi
# export PATH="$PATH:~/.local/share/gem/ruby/3.0.0/bin"

[[ ! -d /tmp ]] || export TMPDIR=/tmp

# zoxide配置(快速目录跳转)
# eval "$(z init zsh)"
