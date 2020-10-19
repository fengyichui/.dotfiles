
#####################################################
#
# 如果termux出问题了，执行：
#   $ rm -rf $PREFIX
#   重启termux，以复位termux
#
#####################################################


# Update apt source:
#   $ apt edit-sources
#   帮助: https://mirror.tuna.tsinghua.edu.cn/help/termux/
sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list
sed -i 's@^\(deb.*games stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/game-packages-24 games stable@' $PREFIX/etc/apt/sources.list.d/game.list
sed -i 's@^\(deb.*science stable\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/science-packages-24 science stable@' $PREFIX/etc/apt/sources.list.d/science.list
apt update && apt upgrade

# Storage
apt install termux-tools
termux-setup-storage

# clipboard and other feature support
apt install termux-api

# Package
apt --yes install \
    git \
    zsh \
    vim \
    coreutils \
    python \
    silversearcher-ag \
    man \
    curl \
    wget \
    openssh \
    ncurses-utils \

# install my dotfiles
git clone --depth 1 https://github.com/fengyichui/.dotfiles.git
./.dotfiles/.bin/install-dotfiles

# default shell
chsh -s zsh
