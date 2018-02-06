#!/bin/bash

# mirror
apt-cyg --mirror http://mirrors.neusoft.edu.cn/cygwin pathof mirror

# software
apt-cyg -X install gnupg
apt-cyg install zsh
apt-cyg install ctags
apt-cyg install diffutils
apt-cyg install dos2unix
apt-cyg install gzip zip unzip
apt-cyg install python
apt-cyg install python3
apt-cyg install git
apt-cyg install git-svn # git svn clone ...
apt-cyg install subversion # svn
apt-cyg install the_silver_searcher # ag search
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

# Install pip for python
wget https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
rm -rf get-pip.py

# Python packages
pip3 install qrcode # QR encode
pip3 install html2text # html to text
pip3 install you-get # Download media contents (videos, audios, images) from the Web
pip3 install pudb # Python debuger

# Command-line translator using Google Translate, Bing Translator, Yandex.Translate, etc.
#git clone https://github.com/soimort/translate-shell
#cd translate-shell/
#make TARGET=zsh
#make install
#cd ..
#rm -rf translate-shell/

# gem
gem install tmuxinator

# install perl version rename
git clone https://github.com/subogero/rename.git
cd rename
make install
cd ..
rm -rf rename
