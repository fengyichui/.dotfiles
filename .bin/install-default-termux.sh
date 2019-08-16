
#####################################################
#
# 如果termux出问题了，执行：
#   $ rm -rf $PREFIX
#   重启termux，以复位termux
#
#####################################################


# Update apt source:
#   $ apt edit-sources
#   加入：deb [arch=all,aarch64] http://mirrors.tuna.tsinghua.edu.cn/termux stable main
#         ( [arch=all,aarch64]: aarch64=$(uname -m) )
sed -i 's@^\(deb.*stable main\)$@#\1\ndeb [arch=all,'"$(uname -m)"'] http://mirrors.tuna.tsinghua.edu.cn/termux stable main@' $PREFIX/etc/apt/sources.list
apt update && apt upgrade

# Storage
apt install termux-tools
termux-set-storage

# clipboard and other feature support
apt install termux-api

# Package
apt install git
apt install zsh
apt install tmux
apt install vim
apt install coreutils
apt install python
apt install silversearcher-ag
apt install man
apt install curl
apt install wget

# install my dotfiles
git clone --depth 1 https://github.com/fengyichui/.dotfiles.git storage/downloads/dotfiles
rm -rf .dotfiles
ln -s storage/downloads/dotfiles .dotfiles
./.dotfiles/.bin/install-dotfiles

# default shell
chsh -s zsh
