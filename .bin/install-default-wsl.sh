
#####################################################
#
# WSL windows 目录在:
#   \\wsl$\Ubuntu-18.04
#   \\wsl$\Ubuntu-20.04
#
# wsltty作为控制台
#   https://github.com/mintty/wsltty
#   安装位置：
#       %LOCALAPPDATA%\wsltty
#   wsltty使用.minttyrc:
#       wsltty同样使用mintty的配置文件, 位置在: %APPDATA%\wsltty\config
#       把.minttyrc里的内容拷贝到这个文件中
#   执行默认shell的快捷方式：
#        %LOCALAPPDATA%\wsltty\bin\mintty.exe --WSL= --configdir="%APPDATA%\wsltty" -~ -
#
# X support:
#   VcXsrv (https://sourceforge.net/projects/vcxsrv/)
#   可以将存储的配置文件放到‘启动’中，以实现开机启动
#
#####################################################

# windows system directory
userprofile="$(cmd.exe /c "<nul set /p=%USERPROFILE%" 2>/dev/null)"
appdata="$(cmd.exe /c "<nul set /p=%APPDATA%" 2>/dev/null)"
localappdata="$(cmd.exe /c "<nul set /p=%LOCALAPPDATA%" 2>/dev/null)"

# Update apt source:
# https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/

if [[ "$WSL_DISTRO_NAME" == "Ubuntu-18.04" ]]; then
    sudo mv -f /etc/apt/sources.list /etc/apt/sources.list.bak
    sudo bash -c 'cat >/etc/apt/sources.list <<EOF
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse
EOF'
elif [[ "$WSL_DISTRO_NAME" == "Ubuntu-20.04" ]]; then
    sudo mv -f /etc/apt/sources.list /etc/apt/sources.list.bak
    sudo bash -c 'cat >/etc/apt/sources.list <<EOF
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-proposed main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-proposed main restricted universe multiverse
EOF'
else
    echo "Not support WSL version: $WSL_DISTRO_NAME"
    exit 1
fi
sudo apt-get --yes update
sudo apt-get --yes upgrade

# Package (vim-gtk3 has more high performance than vim-gtk)
sudo apt-get --yes install \
    git \
    git-svn \
    git-extras \
    zsh \
    vim-gtk3 \
    silversearcher-ag \
    w3m \
    make \
    tree \
    moreutils \
    exuberant-ctags \
    xclip \
    net-tools \
    xfce4-notifyd \
    command-not-found \

# install my dotfiles and other package files
git clone --depth 1 https://gitee.com/fengyichui/dotfiles.git .dotfiles
git clone --depth 1 https://gitee.com/fengyichui/bin.linux.git .bin
git clone --depth 1 https://gitee.com/fengyichui/bin.windows.git .bin.windows
git clone --depth 1 https://gitee.com/fengyichui/linuxpackage.git .linuxpackage

# gitee to github
sed -i -e 's#https://gitee.com/fengyichui/dotfiles.git#https://github.com/fengyichui/.dotfiles.git#' .dotfiles/.git/config
sed -i -e 's#https://gitee.com/fengyichui/bin.linux.git#https://github.com/fengyichui/.bin.linux.git#' .bin/.git/config
sed -i -e 's#https://gitee.com/fengyichui/bin.windows.git#https://github.com/fengyichui/.bin.windows.git#' .bin.windows/.git/config
sed -i -e 's#https://gitee.com/fengyichui/linuxpackage.git#https://github.com/fengyichui/.linuxpackage.git#' .linuxpackage/.git/config

# install dotfiles
./.dotfiles/.bin/install-dotfiles

# wsltty config
wslconfigdir="$(wslpath -u "$appdata\\wsltty")"
cp ~/.dotfiles/.minttyrc $wslconfigdir/config

# Fixing WSL Mount Permissions
# https://www.turek.dev/post/fix-wsl-file-permissions/
sudo bash -c 'cat >/etc/wsl.conf <<EOF
[automount]
enabled = true
options = "metadata,umask=22,fmask=11"
EOF'
echo "Run: 'wsl --shutdown' in Powershell, make some changes take effect"

# zsh processes under tmux accumulate, eating CPU
# https://github.com/microsoft/WSL/issues/3914
echo "May enable 'Windows 10 Virtual Machine Platform' on 'Turn Windows Features on or off'"

# default shell
chsh -s /bin/zsh

