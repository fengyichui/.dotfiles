
#####################################################
#
# WSL windows 目录在:
#   \\wsl$\
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
#
#####################################################

# windows system directory
userprofile="$(cmd.exe /c "<nul set /p=%USERPROFILE%" 2>/dev/null)"
appdata="$(cmd.exe /c "<nul set /p=%APPDATA%" 2>/dev/null)"
localappdata="$(cmd.exe /c "<nul set /p=%LOCALAPPDATA%" 2>/dev/null)"

# Update apt source:
# https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/
if [[ "$WSL_DISTRO_NAME" == "Ubuntu-20.04" ]]; then
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
sudo apt update
sudo apt upgrade

# Package
sudo apt-get install git \
                     zsh \
                     vim-gtk \
                     silversearcher-ag \

# install my dotfiles
git clone --depth 1 https://github.com/fengyichui/.dotfiles.git
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

# default shell
chsh -s /bin/zsh
