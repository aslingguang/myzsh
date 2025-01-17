# 命令快捷方式
if command -v exa &>/dev/null; then
  alias ls='exa'
  alias l='exa -lbah --icons'
  alias la='exa -labgh --icons'
  alias ll='exa -lbg --icons'
  alias lsa='exa -lbagR --icons'
  alias lst='exa -lTabgh --icons' # 输入lst,将展示类似于tree的树状列表。
elif command -v eza &>/dev/null; then
  alias ls='eza'
  alias l='eza -lbah --icons'
  alias la='eza -labgh --icons'
  alias ll='eza -lbg --icons'
  alias lsa='eza -lbagR --icons'
  alias lst='eza -lTabgh --icons' # 输入lst,将展示类似于tree的树状列表。
else 
  alias ls='ls --color=auto'
  alias lst='tree -pCsh'
  alias l='ls -lah'
  alias la='ls -lAh'
  alias ll='ls -lh'
  alias lsa='ls -lah'
fi

if command -v git &>/dev/null; then
  alias gi="git init"
  alias gs="git status"
  alias ga="git add"
  alias gc="git clone"
  alias gm="git commit -m"
  alias go="git checkout"
  alias gph="git push"
  alias gpl="git pull"
  alias gplo="git pull origin"
  alias gpho="git push origin"
  alias gd="git diff"
  alias gr="git remote add"
  alias gro="git remote add origin"
  alias gl="git log"
fi

if command -v bat &>/dev/null; then
  alias cat='bat -pp'
fi

#if command -v nvim &>/dev/null; then
#  alias vim="nvim"
#fi

if command -v pip &>/dev/null; then
  alias pipi="pip -i https://pypi.org/simple"
fi

if command -v xclip &>/dev/null; then
  alias scb="xclip -selection c" # 复制内容到剪贴板(屏幕不显示输出)
  alias gcbo="tee /dev/tty | xclip -selection clipboard" # 复制内容到剪贴板(屏幕显示输出)
  alias gcb="xclip -selection clipboard -o" # 粘贴剪贴板内容
fi

alias ..='cd ..' 
alias ...='cd ../..' 
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

alias mk="mkdir"
alias cls="clear"
# alias cd="z"

# alias xlsx="(xlsx2csv '$1') | xsv table | bat -ltsv --color=always "


# 应用快捷方式
# alias cursor="/opt/Cursor-0.1.6.AppImage &>/dev/null &"
# alias linuxqq="linuxqq &>/dev/null &"

if command -v locate &>/dev/null; then
  alias f="locate"
fi

if command -v dbeaver &>/dev/null; then
  alias dbeaver="dbeaver &>/dev/null &"
fi
# alias feishu="/opt/bytedance/feishu/feishu  &>/dev/null &"
# alias qqmusic="/opt/qqmusic/qqmusic --no-sandbox &>/dev/null &"
# alias lx-music="/opt/appimages/lx-music-desktop.AppImage &>/dev/null &"
# alias clash="/opt/clash-for-windows-chinese-git/cfw &>/dev/null &"

if command -v cfw &>/dev/null; then
  alias cfw="cfw &>/dev/null &"
fi

if command -v microsoft-edge-stable &>/dev/null; then
  alias edge="microsoft-edge-stable &>/dev/null &"
fi
# alias juicebox="java -jar /opt/juicebox.jar"
if command -v aichat &>/dev/null; then
  alias ai="aichat"
fi

proxy_port=2080
alias proxyw="export https_proxy=http://192.168.0.1:$proxy_port && export http_proxy=http://192.168.0.1:$proxy_port && echo Proxy On"
alias proxy-on="export https_proxy=http://127.0.0.1:$proxy_port && export http_proxy=http://127.0.0.1:$proxy_port && echo Proxy On"
alias proxy-off="unset http_proxy https_proxy && echo Proxy Off"

if command -v yt-dlp &>/dev/null && command -v ffmpeg &>/dev/null; then
    alias ytb='yt-dlp -S tbr --cookies cookies -N 16 --embed-thumbnail -o "[%(resolution)s] [%(uploader)s] %(title).50s [%(id)s].%(ext)s"'
    alias yt="yt-dlp -f 'bv*+ba' --merge-output-format mp4 --cookies cookies -N 8 --embed-thumbnail -o '[%(resolution)s] [%(uploader)s] %(title).50s [%(id)s].%(ext)s' "
    yb() { yt-dlp -S tbr --cookies cookies -N 16 --embed-thumbnail -o "[%(resolution)s] [%(uploader)s] %(title).50s [%(id)s].%(ext)s" "https://www.bilibili.com/video/$1" }
fi

if [[ -f $HOME/.config/zsh/script/package_installer.sh ]]; then
  alias pi="$HOME/.config/zsh/script/package_installer.sh"
fi

if [[ -f $HOME/.config/zsh/script/manage_link.sh ]]; then 
  alias ml="$HOME/.config/zsh/script/manage_link.sh"
fi

if command -v mysql &>/dev/null; then
  alias sqlr="mysql -u root -p"
fi

if command -v trans &>/dev/null; then
  alias fyb="trans -e bing -b"
fi

if command -v mount.davfs &>/dev/null; then
  alias mount_onedrive="mount.davfs https://app.koofr.net/dav/OneDrive/  /mnt/onedrive"
fi

if command -v reflector &>/dev/null; then
  alias update="sudo reflector --verbose -c China -l 200 -p https --sort rate --save /etc/pacman.d/mirrorlist"
fi

if command -v git &>/dev/null; then
  alias set_git_url="git config --global url."${github_mirror_url}".insteadOf "https://github.com""
  alias unset_git_url="git config --global --unset-all url."${github_mirror_url}".insteadOf"
fi

if command -v thefuck &>/dev/null; then
  eval $(thefuck --alias)
fi  





