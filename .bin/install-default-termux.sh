
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
#   帮助: https://mirror.tuna.tsinghua.edu.cn/help/termux/
#sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux stable main@' $PREFIX/etc/apt/sources.list
sed -i 's@^\(deb.*stable main\)$@#\1\ndeb [arch=all,'"$(uname -m)"'] http://mirrors.tuna.tsinghua.edu.cn/termux stable main@' $PREFIX/etc/apt/sources.list
apt update && apt upgrade

# Storage
apt install termux-tools
termux-setup-storage

# clipboard and other feature support
apt install termux-api

# Package
apt install git \
            zsh \
            vim \
            coreutils \
            python \
            silversearcher-ag \
            man \
            curl \
            wget \
            openssh \

# install my dotfiles
git clone --depth 1 https://github.com/fengyichui/.dotfiles.git
./.dotfiles/.bin/install-dotfiles

# default shell
chsh -s zsh
