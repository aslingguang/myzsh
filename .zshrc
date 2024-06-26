
if [[ $(locale -a 2>/dev/null) == *zh_CN.utf8* && $(tty 2>/dev/null) == *pts* ]]; then
    export LANG="zh_CN.UTF-8"
    export LC_ALL="zh_CN.UTF-8"
fi 

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


github_response_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 1 https://github.com)

github_mirror_url="https://github.moeyy.xyz/https://github.com"
github_mirror_url="${github_mirror_url:-https://hub.yzuu.cf}"


if [ $github_response_code -ne 200 ]; then
  git config --global url."${github_mirror_url}".insteadOf "https://github.com"
fi

if command -v nvim &>/dev/null; then
  # install MyVim-starter
  NVIM_HOME="${NVIM_HOME:-${HOME}/.config/nvim}"
  if [ ! -d "${NVIM_HOME}" ]; then
    git clone https://github.com/aslingguang/MyVim-starter.git "${NVIM_HOME}"
  fi
fi


if [[ -d "/opt" ]]; then
  ZINIT_HOME_DIR="/opt/zsh"
  if [[ ! -d $ZINIT_HOME_DIR ]]; then
    if [[ "$(id -u)" -ne 0 ]]; then
      sudo mkdir -p $ZINIT_HOME_DIR
      sudo chmod 777 -R $ZINIT_HOME_DIR
    fi
  fi
else
  ZINIT_HOME_DIR="$HOME/.local/share"
fi
typeset -A ZINIT=(
    BIN_DIR  $ZINIT_HOME_DIR/zinit/zinit.git
    HOME_DIR $ZINIT_HOME_DIR/zinit
    PLUGINS_DIR $ZINIT_HOME_DIR/zinit/plugins
    COMPLETIONS_DIR $ZINIT_HOME_DIR/zinit/completions
    SNIPPETS_DIR $ZINIT_HOME_DIR/zinit/snippets
    COMPINIT_OPTS -C
)

ZPFX="$ZINIT_HOME_DIR/zinit/polaris"
[ ! -d ${ZINIT[BIN_DIR]} ] && mkdir -p "$(dirname ${ZINIT[BIN_DIR]})"
[ ! -d ${ZINIT[BIN_DIR]}/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "${ZINIT[BIN_DIR]}"
source "${ZINIT[BIN_DIR]}/zinit.zsh"

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit


# Load a few important annexes, without Turbo
# (this is currently required for annexes)
  zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk


# Lines configured by zsh-newuser-install
HISTFILE=$HOME/.zsh_history
HISTSIZE=5000
SAVEHIST=5000
# End of lines configured by zsh-newuser-install



# 加载 powerlevel10k 主题
zinit ice depth=1; zinit load romkatv/powerlevel10k

# source /mnt/e/linux/all/gitLib/aslingguang/fzf-tab-source/fzf-tab.plugin.zsh
if command -v fzf &>/dev/null; then
  zinit ice lucid wait='1'
  zinit load aslingguang/fzf-tab-source
fi

# zinit light zsh-users/zsh-completions
zinit load zsh-users/zsh-autosuggestions
zinit load zdharma/fast-syntax-highlighting
# zinit light zsh-users/zsh-syntax-highlighting
zinit wait lucid atload"zicompinit; zicdreplay" blockf for \
  zsh-users/zsh-completions

#记录访问目录，输z获取,输`z 目录名称`快速跳转(skywind3000/z.lua,rupa/z,zoxide等都不能直接与fzf-tab配合使用 )
zinit ice lucid wait='1' atload"[[ $github_response_code -eq 200 ]] || git config --global --unset-all url."${github_mirror_url}".insteadOf"
zinit load agkozak/zsh-z
# zinit load skywind3000/z.lua




# 下载配置文件
githubraw_url=https://raw.githubusercontent.com
githubraw_response_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 1 https://raw.githubusercontent.com)
if [ $githubraw_response_code -ne 200 ]; then
  githubraw_url="${githubraw_mirror_url:-https://raw.gitmirror.com}"
  # githubraw_url=https://raw.fgit.cf/
fi
myzsh=${githubraw_url}/aslingguang/myzsh/HEAD
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# https://raw.githubusercontent.com/aslingguang/myzsh/HEAD/.zshrc

if [[ ! -f $HOME/.p10k.zsh ]]; then
  echo "$(curl -fsSL ${githubraw_url}/aslingguang/myzsh/HEAD/.p10k.zsh)" > $HOME/.p10k.zsh
fi  

if [[ ! -f $HOME/.gitconfig ]]; then  
  echo "$(curl -fsSL ${githubraw_url}/aslingguang/myzsh/HEAD/.gitconfig)" > $HOME/.gitconfig
fi

if [[ ! -d $HOME/.config/zsh/script ]]; then
  mkdir -p $HOME/.config/zsh/script
fi 

# 命令别名
if [[ ! -f $HOME/.config/zsh/alias.zsh ]]; then  
  echo "$(curl -fsSL ${githubraw_url}/aslingguang/myzsh/HEAD/.config/zsh/alias.zsh)" > $HOME/.config/zsh/alias.zsh
fi

# 环境变量
if [[ ! -f $HOME/.config/zsh/path.zsh ]]; then  
  echo "$(curl -fsSL ${githubraw_url}/aslingguang/myzsh/HEAD/.config/zsh/path.zsh)" > $HOME/.config/zsh/path.zsh
fi

if [[ ! -f $HOME/.config/zsh/script/package_installer.sh ]]; then  
  echo "$(curl -fsSL ${githubraw_url}/aslingguang/myzsh/HEAD/.config/zsh/script/package_installer.sh)" > $HOME/.config/zsh/script/package_installer.sh
fi


if command -v bat &>/dev/null; then
  if [[ ! -d $HOME/.config/bat ]]; then
    mkdir -p $HOME/.config/bat
  fi
  if [[ ! -f $HOME/.config/bat/config ]]; then
    echo "$(curl -fsSL ${githubraw_url}/aslingguang/myzsh/HEAD/.config/bat/config)" > $HOME/.config/bat/config
  fi
fi


if command -v aichat &>/dev/null || [[ -f "$HOME/.config/aichat/aichat" ]]; then
  if [[ ! -d $HOME/.config/aichat ]]; then
    mkdir -p $HOME/.config/aichat
  fi
  if [[ ! -f $HOME/.config/aichat/roles.yaml ]]; then
    echo "$(curl -fsSL ${githubraw_url}/aslingguang/myzsh/HEAD/.config/aichat/roles.yaml)" > $HOME/.config/aichat/roles.yaml
  fi
fi

system_info=$(uname -a)

# p10k主题
[[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh



# termux 配置
if [[ $system_info == *Android* ]]; then
  if [[ ! -d $HOME/.termux ]]; then
      mkdir -p $HOME/.termux   
  fi

  if [[ ! -f $HOME/.termux/termux.properties.bak && -f $HOME/.termux/termux.properties ]]; then
    mv $HOME/.termux/termux.properties $HOME/.termux/termux.properties.bak
    echo "$(curl -fsSL ${githubraw_url}/aslingguang/myzsh/HEAD/.termux/termux.properties)" > $HOME/.termux/termux.properties
  elif [[ ! -f $HOME/.termux/termux.properties ]]; then
    echo "$(curl -fsSL ${githubraw_url}/aslingguang/myzsh/HEAD/.termux/termux.properties)" > $HOME/.termux/termux.properties
  fi

  if command -v sshd &>/dev/null; then
    sshd
  fi

  if command -v mosh &>/dev/null; then
    mosh-server &>/dev/null
  fi
else
  if [[ -z "$(ldd --version |& grep -Po musl)" ]]; then
    # 安装homebrew
    if [[ ! -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
      export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
      export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
      export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
      export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"
      /bin/bash -c "$(curl -fsSL https://mirrors.ustc.edu.cn/misc/brew-install.sh)"
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
      brew update
    elif [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
      # 中科大源
      export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
      export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
      export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"
      # 清华源
      # export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
      # export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
      # export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
    fi
  fi

  if [[ ! -f $HOME/.config/zsh/script/manage_link.sh ]]; then  
    echo "$(curl -fsSL ${githubraw_url}/aslingguang/myzsh/HEAD/.config/zsh/script/manage_link.sh)" > $HOME/.config/zsh/script/manage_link.sh
  fi
fi

# 优先加载自定义配置
if [[ -d "$HOME/.config/zsh/myconfig" ]]; then
  for zsh_config in $HOME/.config/zsh/myconfig/*.zsh; do
    if [[ -f "$zsh_config" ]]; then
      source "$zsh_config"
    fi
  done
fi

# 其他配置
for zsh_config in $HOME/.config/zsh/*.zsh; do
  if [[ -f "$zsh_config" ]]; then
    source "$zsh_config"
  fi
done

if (command -v aichat &>/dev/null || [[ -f "$HOME/.config/aichat/aichat" ]]) && [[ ! -f "$HOME/.config/zsh/script/myai.sh" ]]; then 
  echo "$(curl -fsSL ${githubraw_url}/aslingguang/myzsh/HEAD/.config/zsh/script/myai.sh)" > $HOME/.config/zsh/script/myai.sh
fi

chmod +x -R $HOME/.config/zsh/script/ 2>/dev/null

update_config()
{
  echo "$(curl -fsSL ${githubraw_url}/aslingguang/myzsh/HEAD/.zshrc)" > $HOME/.zshrc
  echo "$(curl -fsSL ${githubraw_url}/aslingguang/myzsh/HEAD/.p10k.zsh)" > $HOME/.p10k.zsh
  echo "$(curl -fsSL ${githubraw_url}/aslingguang/myzsh/HEAD/.gitconfig)" > $HOME/.gitconfig


  if [[ ! -d $HOME/.config/zsh/script ]]; then
    mkdir -p $HOME/.config/zsh/script
  fi  
  echo "$(curl -fsSL ${githubraw_url}/aslingguang/myzsh/HEAD/.config/zsh/alias.zsh)" > $HOME/.config/zsh/alias.zsh
  echo "$(curl -fsSL ${githubraw_url}/aslingguang/myzsh/HEAD/.config/zsh/path.zsh)" > $HOME/.config/zsh/path.zsh
  echo "$(curl -fsSL ${githubraw_url}/aslingguang/myzsh/HEAD/.config/zsh/script/package_installer.sh)" > $HOME/.config/zsh/script/package_installer.sh
  if command -v aichat &>/dev/null || [[ -f "$HOME/.config/aichat/aichat" ]]; then 
    echo "$(curl -fsSL ${githubraw_url}/aslingguang/myzsh/HEAD/.config/zsh/script/myai.sh)" > $HOME/.config/zsh/script/myai.sh
  fi
  

  if command -v bat &>/dev/null; then
    if [[ ! -d $HOME/.config/bat ]]; then
      mkdir -p $HOME/.config/bat
    fi
    echo "$(curl -fsSL ${githubraw_url}/aslingguang/myzsh/HEAD/.config/bat/config)" > $HOME/.config/bat/config
  fi

  if command -v aichat &>/dev/null || [[ -f "$HOME/.config/aichat/aichat" ]]; then
    if [[ ! -d $HOME/.config/aichat ]]; then
      mkdir -p $HOME/.config/aichat
    fi
    echo "$(curl -fsSL ${githubraw_url}/aslingguang/myzsh/HEAD/.config/aichat/roles.yaml)" > $HOME/.config/aichat/roles.yaml
  fi
  
  # 如果是安卓设备，更新termux配置
  if [[ $system_info == *Android* ]]; then
    if [[ ! -d $HOME/.termux ]]; then
      mkdir -p $HOME/.termux   
    fi 
    echo "$(curl -fsSL ${githubraw_url}/aslingguang/myzsh/HEAD/.termux/termux.properties)" > $HOME/.termux/termux.properties
  elif [[ ! -f $HOME/.config/zsh/script/manage_link.sh ]]; then  
    echo "$(curl -fsSL ${githubraw_url}/aslingguang/myzsh/HEAD/.config/zsh/script/manage_link.sh)" > $HOME/.config/zsh/script/manage_link.sh
  fi
  
  chmod +x -R $HOME/.config/zsh/script/ 2>/dev/null

  source "$HOME/.zshrc"

}

remove_config()
{
  if [[ -d $HOME/.config/zsh ]]; then
    rm -rf $HOME/.config/zsh
  fi

  if [[ -d $HOME/.config/bat ]]; then
    rm -rf $HOME/.config/bat
  fi

  if [[ -f $HOME/.p10k.zsh ]]; then
    rm -f $HOME/.p10k.zsh
  fi

  if [[ -f $HOME/.gitconfig ]]; then
      rm -f $HOME/.gitconfig
  fi

  if [[ -f $HOME/.zshrc ]]; then
    rm -f $HOME/.zshrc
  fi
  
  if [[ -f $HOME/.config/aichat/roles.yaml ]]; then
    rm -f $HOME/.config/aichat/roles.yaml
  fi

  if [[ $system_info == *Android* ]]; then
    if [[ -f $HOME/.termux/termux.properties.bak && -f $HOME/.termux/termux.properties ]]; then
      rm -f $HOME/.termux/termux.properties
      mv $HOME/.termux/termux.properties.bak $HOME/.termux/termux.properties
    fi
  fi

  echo "是否删除zint插件 (y/n): "
  read choice
  if [[ $choice == "y" || $choice == "Y" ]]; then
    rm -rf ${ZINIT[HOME_DIR]}
    echo "删除zint插件"
  else
    echo "保留zint插件"
  fi

  echo "是否删除nvim配置 (y/n): "
  read choice
  if [[ $choice == "y" || $choice == "Y" ]]; then
    rm -rf ${NVIM_HOME}
    rm -rf $HOME/.local/share/nvim
    rm -rf $HOME/.local/state/nvim
    echo "删除nvim配置及插件"
  else
    echo "保留nvim配置及插件"
  fi

  if [[ -d "/home/linuxbrew/.linuxbrew/bin" ]]; then
    echo "是否删除homebrew (y/n): "
    read choice
    if [[ $choice == "y" || $choice == "Y" ]]; then
      /bin/bash -c "$(curl -fsSL ${githubraw_url}/Homebrew/install/HEAD/uninstall.sh)"
      sudo rm -rf /home/linuxbrew
      echo "删除homebrew"
    else
      echo "保留homebrew"
    fi
  fi
  
}
