# echo 'root' | sudo -S ln -s /mnt/wslg/.X11-unix /tmp/.X11-unix &> /dev/null
# if [[ $(locale -a 2>/dev/null) == *zh_CN.utf8* && $(tty 2>/dev/null) == *pts* ]]; then
#     export LANG="zh_CN.UTF-8"
#     export LC_ALL="zh_CN.UTF-8"
# fi   

if [[ -d "/opt/nvim-linux64" ]];then
    export PATH="/opt/nvim-linux64/bin:$PATH"
fi

if [[ -d "/opt/miniconda3" ]]; then
    miniconda_path="/opt/miniconda3"
elif [[ -d "/opt/miniconda" ]]; then
    miniconda_path="/opt/miniconda"
fi

# miniconda3环境变量
if [[ -n "$miniconda_path" ]]; then
  # >>> conda initialize >>>
  # !! Contents within this block are managed by 'conda init' !!
  __conda_setup="$("${miniconda_path}/bin/conda" "shell.bash" "hook" 2> /dev/null)"
  if [ $? -eq 0 ]; then
      eval "$__conda_setup"
  else
      if [ -f "${miniconda_path}/etc/profile.d/conda.sh" ]; then
          . "${miniconda_path}/etc/profile.d/conda.sh"
      else
          export PATH="${miniconda_path}/bin:$PATH"
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
