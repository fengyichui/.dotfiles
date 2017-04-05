#!/bin/bash

# mirror
apt-cyg --mirror http://mirrors.neusoft.edu.cn/cygwin pathof mirror

# software
apt-cyg -X install gnupg
apt-cyg install zsh
apt-cyg install ctags
apt-cyg install diffutils
apt-cyg install dos2unix
apt-cyg install gzip
apt-cyg install python
apt-cyg install python3
apt-cyg install git
apt-cyg install subversion # svn
apt-cyg install the_silver_searcher # ag search
apt-cyg install vim
apt-cyg install wget
apt-cyg install curl
apt-cyg install xxd
apt-cyg install zip
apt-cyg install unzip
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

# Install pip for python
wget https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
rm -rf get-pip.py

# Python packages
pip3 install qrcode # QR encode
pip3 install html2text # html to text
pip3 install you-get # Download media contents (videos, audios, images) from the Web

# Command-line translator using Google Translate, Bing Translator, Yandex.Translate, etc.
git clone https://github.com/soimort/translate-shell
cd translate-shell/
make TARGET=zsh
make install
cd ..
rm -rf translate-shell/

