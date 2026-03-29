# ============================================================
# 语言环境：仅在中文 UTF-8 可用的 pts 终端下设置
# ============================================================
if [[ $(locale -a 2>/dev/null) == *zh_CN.utf8* && $(tty 2>/dev/null) == *pts* ]]; then
  export LANG="zh_CN.UTF-8"
  export LC_ALL="zh_CN.UTF-8"
fi

# ============================================================
# Powerlevel10k 即时提示（必须在顶部附近）
# ============================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ============================================================
# 镜像探测：自动选择可用的 GitHub / raw 代理
# ============================================================

# 探测单个 URL，返回 HTTP 状态码
_http_code() { curl -s -o /dev/null -w "%{http_code}" --max-time 2 "$1"; }

# GitHub clone 镜像候选（按优先级排列）
_GITHUB_MIRRORS=(
  "https://github.com"
  "https://mirror.ghproxy.com/https://github.com"
  "https://ghfast.top/https://github.com"
  "https://gh-proxy.com/https://github.com"
)

# raw.githubusercontent.com 镜像候选
_RAW_MIRRORS=(
  "https://raw.githubusercontent.com"
  "https://mirror.ghproxy.com/https://raw.githubusercontent.com"
  "https://ghfast.top/https://raw.githubusercontent.com"
)

# 探测 GitHub 可达性
github_response_code=$(_http_code "https://github.com")

# 选择可用的 GitHub clone 镜像
github_mirror_url="https://github.com"
if [[ $github_response_code -ne 200 ]]; then
  for _mirror in "${_GITHUB_MIRRORS[@]:1}"; do
    if [[ $(_http_code "$_mirror/zdharma-continuum/zinit") == 200 ]]; then
      github_mirror_url="$_mirror"
      break
    fi
  done
  git config --global url."${github_mirror_url}/".insteadOf "https://github.com/"
fi

# 选择可用的 raw 内容镜像
githubraw_url="https://raw.githubusercontent.com"
if [[ $(_http_code "https://raw.githubusercontent.com") -ne 200 ]]; then
  for _mirror in "${_RAW_MIRRORS[@]:1}"; do
    if [[ $(_http_code "${_mirror}/aslingguang/myzsh/HEAD/.zshrc") == 200 ]]; then
      githubraw_url="$_mirror"
      break
    fi
  done
fi

# ============================================================
# Neovim 配置初始化
# ============================================================
if command -v nvim &>/dev/null; then
  NVIM_HOME="${NVIM_HOME:-${HOME}/.config/nvim}"
  if [[ ! -d "${NVIM_HOME}" ]]; then
    git clone https://github.com/aslingguang/MyVim-starter.git "${NVIM_HOME}"
  fi
fi

# ============================================================
# Zinit 插件管理器
# ============================================================
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
  BIN_DIR         $ZINIT_HOME_DIR/zinit/zinit.git
  HOME_DIR        $ZINIT_HOME_DIR/zinit
  PLUGINS_DIR     $ZINIT_HOME_DIR/zinit/plugins
  COMPLETIONS_DIR $ZINIT_HOME_DIR/zinit/completions
  SNIPPETS_DIR    $ZINIT_HOME_DIR/zinit/snippets
  COMPINIT_OPTS   -C
)
ZPFX="$ZINIT_HOME_DIR/zinit/polaris"

[[ ! -d ${ZINIT[BIN_DIR]} ]] && mkdir -p "$(dirname ${ZINIT[BIN_DIR]})"
[[ ! -d ${ZINIT[BIN_DIR]}/.git ]] && git clone https://github.com/zdharma-continuum/zinit.git "${ZINIT[BIN_DIR]}"
source "${ZINIT[BIN_DIR]}/zinit.zsh"

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust

# ============================================================
# 历史记录配置
# ============================================================
HISTFILE=$HOME/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

setopt INC_APPEND_HISTORY   # 每条命令立即写入
setopt APPEND_HISTORY        # 追加而非覆盖
setopt SHARE_HISTORY         # 多会话共享历史
setopt EXTENDED_HISTORY      # 记录时间戳
setopt HIST_IGNORE_DUPS      # 忽略连续重复
setopt HIST_IGNORE_SPACE     # 忽略空格开头的命令
setopt HIST_SAVE_NO_DUPS     # 文件中不存重复

# ============================================================
# 插件加载
# ============================================================
zinit ice depth=1; zinit load romkatv/powerlevel10k

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
# 在 zsh-z 加载完成后，若 GitHub 不可用的镜像配置完成，则还原
zinit ice lucid wait='1' atload"[[ $github_response_code -eq 200 ]] || git config --global --unset-all url."${github_mirror_url}".insteadOf"
zinit load agkozak/zsh-z

# ============================================================
# 下载/更新远程配置文件（仅首次）
# ============================================================
myzsh="${githubraw_url}/aslingguang/myzsh/HEAD"

_fetch_config() {
  # 用法: _fetch_config <远程路径> <本地路径>
  local content
  content=$(curl -fsSL "$1" 2>/dev/null)
  [[ -n "$content" ]] && echo "$content" > "$2"
}

[[ ! -f $HOME/.p10k.zsh ]]    && _fetch_config "${myzsh}/.p10k.zsh"    "$HOME/.p10k.zsh"
[[ ! -f $HOME/.gitconfig ]]   && _fetch_config "${myzsh}/.gitconfig"   "$HOME/.gitconfig"

mkdir -p "$HOME/.config/zsh/script"

[[ ! -f $HOME/.config/zsh/alias.zsh ]]  && _fetch_config "${myzsh}/.config/zsh/alias.zsh"  "$HOME/.config/zsh/alias.zsh"
[[ ! -f $HOME/.config/zsh/path.zsh ]]   && _fetch_config "${myzsh}/.config/zsh/path.zsh"   "$HOME/.config/zsh/path.zsh"
[[ ! -f $HOME/.config/zsh/script/package_installer.sh ]] && \
  _fetch_config "${myzsh}/.config/zsh/script/package_installer.sh" "$HOME/.config/zsh/script/package_installer.sh"

if command -v bat &>/dev/null; then
  mkdir -p "$HOME/.config/bat"
  [[ ! -f $HOME/.config/bat/config ]] && _fetch_config "${myzsh}/.config/bat/config" "$HOME/.config/bat/config"
fi

if command -v aichat &>/dev/null || [[ -f "$HOME/.config/aichat/aichat" ]]; then
  mkdir -p "$HOME/.config/aichat"
  [[ ! -f $HOME/.config/aichat/roles.yaml ]] && \
    _fetch_config "${myzsh}/.config/aichat/roles.yaml" "$HOME/.config/aichat/roles.yaml"
fi

# ============================================================
# 系统信息 & 平台检测
# ============================================================
system_info=$(uname -a)

# p10k 主题
[[ -f $HOME/.p10k.zsh ]] && source "$HOME/.p10k.zsh"

# ============================================================
# 平台特定配置
# ============================================================
if [[ $system_info == *Android* ]]; then
  # --- Termux (Android) ---
  mkdir -p "$HOME/.termux"
  _termux_props="$HOME/.termux/termux.properties"
  if [[ ! -f "${_termux_props}.bak" && -f "$_termux_props" ]]; then
    mv "$_termux_props" "${_termux_props}.bak"
    _fetch_config "${myzsh}/.termux/termux.properties" "$_termux_props"
  elif [[ ! -f "$_termux_props" ]]; then
    _fetch_config "${myzsh}/.termux/termux.properties" "$_termux_props"
  fi
  command -v sshd &>/dev/null && sshd
  command -v mosh &>/dev/null && mosh-server &>/dev/null

else
  # --- 标准 Linux（非 musl）---
  if [[ -z "$(ldd --version |& grep -Po musl)" ]]; then
    # Homebrew：使用中科大镜像
    _brew_bin="/home/linuxbrew/.linuxbrew/bin/brew"
    _brew_env() {
      export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
      export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/homebrew-core.git"
      export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
      export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"
    }
    if [[ ! -f "$_brew_bin" ]]; then
      _brew_env
      /bin/bash -c "$(curl -fsSL https://mirrors.ustc.edu.cn/misc/brew-install.sh)"
      eval "$($_brew_bin shellenv)"
      brew update
    elif [[ -f "$_brew_bin" ]]; then
      eval "$($_brew_bin shellenv)"
      _brew_env
    fi
  fi

  [[ ! -f $HOME/.config/zsh/script/manage_link.sh ]] && \
    _fetch_config "${myzsh}/.config/zsh/script/manage_link.sh" "$HOME/.config/zsh/script/manage_link.sh"
fi

# ============================================================
# 加载自定义配置（myconfig 目录优先）
# ============================================================
if [[ -d "$HOME/.config/zsh/myconfig" ]]; then
  for _cfg in "$HOME/.config/zsh/myconfig/"*.zsh(N); do
    source "$_cfg"
  done
fi

for _cfg in "$HOME/.config/zsh/"*.zsh(N); do
  source "$_cfg"
done

# aichat AI 脚本
if (command -v aichat &>/dev/null || [[ -f "$HOME/.config/aichat/aichat" ]]) && \
   [[ ! -f "$HOME/.config/zsh/script/myai.sh" ]]; then
  _fetch_config "${myzsh}/.config/zsh/script/myai.sh" "$HOME/.config/zsh/script/myai.sh"
fi

chmod +x -R "$HOME/.config/zsh/script/" 2>/dev/null

# ============================================================
# update_config：强制更新所有远程配置
# ============================================================
update_config() {
  echo "正在从 ${myzsh} 更新配置..."

  _fetch_config "${myzsh}/.zshrc"    "$HOME/.zshrc"
  _fetch_config "${myzsh}/.p10k.zsh" "$HOME/.p10k.zsh"
  _fetch_config "${myzsh}/.gitconfig" "$HOME/.gitconfig"

  mkdir -p "$HOME/.config/zsh/script"
  _fetch_config "${myzsh}/.config/zsh/alias.zsh"  "$HOME/.config/zsh/alias.zsh"
  _fetch_config "${myzsh}/.config/zsh/path.zsh"   "$HOME/.config/zsh/path.zsh"
  _fetch_config "${myzsh}/.config/zsh/script/package_installer.sh" \
                "$HOME/.config/zsh/script/package_installer.sh"

  if command -v aichat &>/dev/null || [[ -f "$HOME/.config/aichat/aichat" ]]; then
    _fetch_config "${myzsh}/.config/zsh/script/myai.sh" "$HOME/.config/zsh/script/myai.sh"
  fi

  if command -v bat &>/dev/null; then
    mkdir -p "$HOME/.config/bat"
    _fetch_config "${myzsh}/.config/bat/config" "$HOME/.config/bat/config"
  fi

  if command -v aichat &>/dev/null || [[ -f "$HOME/.config/aichat/aichat" ]]; then
    mkdir -p "$HOME/.config/aichat"
    _fetch_config "${myzsh}/.config/aichat/roles.yaml" "$HOME/.config/aichat/roles.yaml"
  fi

  if [[ $system_info == *Android* ]]; then
    mkdir -p "$HOME/.termux"
    _fetch_config "${myzsh}/.termux/termux.properties" "$HOME/.termux/termux.properties"
  else
    [[ ! -f $HOME/.config/zsh/script/manage_link.sh ]] && \
      _fetch_config "${myzsh}/.config/zsh/script/manage_link.sh" \
                    "$HOME/.config/zsh/script/manage_link.sh"
  fi

  chmod +x -R "$HOME/.config/zsh/script/" 2>/dev/null
  echo "配置更新完成，正在重新加载..."
  source "$HOME/.zshrc"
}

# ============================================================
# remove_config：清理所有配置文件
# ============================================================
remove_config() {
  local choice

  rm -rf "$HOME/.config/zsh" "$HOME/.config/bat"
  rm -f  "$HOME/.p10k.zsh" "$HOME/.gitconfig" "$HOME/.zshrc"
  rm -f  "$HOME/.config/aichat/roles.yaml"

  if [[ $system_info == *Android* ]]; then
    local props="$HOME/.termux/termux.properties"
    if [[ -f "${props}.bak" && -f "$props" ]]; then
      rm -f "$props"
      mv "${props}.bak" "$props"
    fi
  fi

  echo -n "是否删除 zinit 插件? (y/N): "
  read choice
  if [[ ${choice:l} == "y" ]]; then
    rm -rf "${ZINIT[HOME_DIR]}"
    echo "已删除 zinit 插件"
  else
    echo "保留 zinit 插件"
  fi

  echo -n "是否删除 nvim 配置? (y/N): "
  read choice
  if [[ ${choice:l} == "y" ]]; then
    rm -rf "${NVIM_HOME}" "$HOME/.local/share/nvim" "$HOME/.local/state/nvim"
    echo "已删除 nvim 配置及插件"
  else
    echo "保留 nvim 配置"
  fi

  if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    echo -n "是否删除 Homebrew? (y/N): "
    read choice
    if [[ ${choice:l} == "y" ]]; then
      /bin/bash -c "$(curl -fsSL ${githubraw_url}/Homebrew/install/HEAD/uninstall.sh)"
      sudo rm -rf /home/linuxbrew
      echo "已删除 Homebrew"
    else
      echo "保留 Homebrew"
    fi
  fi
}