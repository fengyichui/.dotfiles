#
# source me
#

# mirror
apt-cyg --mirror http://mirrors.neusoft.edu.cn/cygwin pathof mirror

# software
apt-cyg -X install gnupg
apt-cyg install zsh
apt-cyg install tmux
apt-cyg install ctags
apt-cyg install diffutils
apt-cyg install dos2unix
apt-cyg install gzip zip unzip
apt-cyg install python python-pip
apt-cyg install python3 python3-pip
apt-cyg install git
apt-cyg install git-svn # git svn clone ...
apt-cyg install git-gui gitk # git gui
apt-cyg install tig # git graph mode
apt-cyg install subversion # svn
apt-cyg install the_silver_searcher # ag search (termux: silversearcher-ag)
apt-cyg install vim
apt-cyg install wget
apt-cyg install curl
apt-cyg install xxd
apt-cyg install gawk
apt-cyg install sed
apt-cyg install bash-completion
apt-cyg install figlet  # show BIG characters
apt-cyg install aria2 # download tool
apt-cyg install astyle # for c/c++ format beautifully
apt-cyg install tidy # for xml format beautifully
apt-cyg install make
apt-cyg install qrencode # for QR encode
apt-cyg install zbar # for QR decode: zbarimg
apt-cyg install gcc-core #gcc c compiler
apt-cyg install w3m # web explorer in terminal
#apt-cyg install lynx # web explorer in terminal
apt-cyg install ruby rubygems # ruby and its package manager
apt-cyg install procps # for ps and top
apt-cyg install psmisc # for fuser and pstree
apt-cyg install gnuplot # for plot
#apt-cyg install inetutils # for telnet
#apt-cyg install xorg-server # for X window system
#apt-cyg install xinit # for X window system (start with: $ startxwin)
apt-cyg install fzf
#apt-cyg install multitail # better than tail
apt-cyg install moreutils # more utils for parallel,ts and so on
apt-cyg install ncdu # NCurses Disk Usage, like du: file system statistics (https://dev.yorhel.nl/ncdu)
apt-cyg install rlwrap # readline wrapper for unsupport readline command
apt-cyg install icoutils # ico tools: icotool and wrestool

# Python packages
pip3 install qrcode # QR encode
pip3 install html2text # html to text
#pip3 install you-get # Download media contents (videos, audios, images) from the Web
pip3 install streamlink # CLI for extracting streams from various websites to a video player of your choosing
pip3 install pudb # Python debuger
pip3 install bpython # good python shell
pip3 install tldr # A collection of simplified and community-driven man pages.

# Command-line translator using Google Translate, Bing Translator, Yandex.Translate, etc.
#git clone https://github.com/soimort/translate-shell
#cd translate-shell/
#make TARGET=zsh
#make install
#cd ..
#rm -rf translate-shell/

# gem
gem install tmuxinator

# link cygwin to windows (mklink must be sudo)
cmd /c mklink /D "$(cygpath -w $(cygpath -O)/../vimfiles)" "$(cygpath -w ~/.dotfiles/.vim)"  # .vim->vimfiles
cmd /c mklink "$(cygpath -w $(cygpath -O)/../.gitconfig)" "$(cygpath -w ~/.dotfiles/.gitconfig)"  # .gitconfig

# install perl version rename
git clone https://github.com/subogero/rename.git
cd rename
make install
cd ..
rm -rf rename

# install git-extras
git clone https://github.com/tj/git-extras.git
cd git-extras
git checkout $(git describe --tags $(git rev-list --tags --max-count=1))
make install
cp etc/git-extras-completion.zsh /etc
cd ..
rm -rf git-extras


###################################
# Install binary files BEGIN {
###################################

mkdir -p $HOME/.bin
mkdir -p /tmp/packages

# tmp
cd /tmp/packages

# ShellCheck, a static analysis tool for shell scripts (https://github.com/koalaman/shellcheck)
wget -c -O shellcheck.zip  https://storage.googleapis.com/shellcheck/shellcheck-stable.zip
# Gron, Make JSON greppable!
wget -c -O gron.zip        https://github.com/tomnomnom/gron/releases/download/v0.6.0/gron-windows-amd64-0.6.0.zip
# hyperfine, A command-line benchmarking tool
wget -c -O hyperfine.zip   https://github.com/sharkdp/hyperfine/releases/download/v1.6.0/hyperfine-v1.6.0-x86_64-pc-windows-msvc.zip
# shfmt, A shell parser, formatter, and interpreter
wget -c -O shfmt.exe       https://github.com/mvdan/sh/releases/download/v2.6.4/shfmt_v2.6.4_windows_amd64.exe
# UPX, the Ultimate Packer for eXecutables
wget -c -O upx.zip         https://github.com/upx/upx/releases/download/v3.95/upx-3.95-win64.zip
# unrar (https://www.rarlab.com/rar_add.htm)
wget -c -O unrar.exe       https://www.rarlab.com/rar/unrarw32.exe
# shadowsocks-libev
wget -c -O ss.zip          https://github.com/DDoSolitary/shadowsocks-libev-win/archive/release-x86_64.zip
# ffmpeg
#https://ffmpeg.zeranoe.com/builds/

# unzip its and move to .bin directory
find | awk '/zip/' | xargs -n1 unzip -o
find | awk '/exe$/' | xargs -I{} cp {} $HOME/.bin

# .bin
cd $HOME/.bin

# change mode
chmod +x *

# rename some
mv shellcheck-stable.exe shellcheck.exe

###################################
# Install binary files END }
###################################
