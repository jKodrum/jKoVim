#!/bin/bash
# Author: jKodrum
# Program: jKoVim.sh
# Description: Install powerline and jKodrum's vimrc
#
# Parameters:
# default: install powerline and vimrc locally
# -a: install powerline and vimrc globally (system wide)
# -u: uninstall powerline and vimrc

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
magenta=`tput setaf 5`
cyan=`tput setaf 6`
reset=`tput sgr0`
echoGreen() { echo "${green}$*${reset}"; }
echoRed() { echo "${red}$*${reset}"; }
echoYellow() { echo "${yellow}$*${reset}"; }
echoBlue() { echo "${blue}$*${reset}"; }
echoMagenta() { echo "${magenta}$*${reset}"; }
echoCyan() { echo "${cyan}$*${reset}"; }

# TODO: global install
# TODO: en/diable powerline
start() {
    #echo "arg: $*"
    LOCAL_OR_GLOBAL="LOCAL"
    case $* in
        "-g")
            echo "install globally"
            LOCAL_OR_GLOBAL="GLOBAL"
            ;;
        "-u")
            echo "Uninstall"
            platform
            localUninstallPowerline
            uninstallVimrc
            echoRed "* * * * * * * * Please restart terminal. * * * * * * * *"
            echo ""
            ;;
        "-t")
            platform
            installPowerline
            installVimrc
            #uninstallVimrc
            ;;
        *)
            echoYellow "default install: per user"
            LOCAL_OR_GLOBAL="LOCAL"
            platform
            localInstallPowerline
            installVimrc
            installFonts
            ;;
    esac
}

platform() {
    OS=`uname -s`
    LOCAL_VIMRC="$HOME/.vimrc"
    case $OS in
        "Darwin")
            INSTALL_CMD="brew install"
            SED_CMD_PREFIX="sed -i ''"
            GLOBAL_VIMRC="/usr/share/vim/vimrc"
            LOCAL_BASHRC="$HOME/.bash_profile"
            LOCAL_POWERLINE_PATH="$HOME/Library/Python/2.7/lib/python/site-packages/powerline/bindings"
            LOCAL_POWERLINE_BIN="$HOME/Library/Python/2.7/bin"
            FONT_FILE="$HOME/Desktop/DejaVu_Sans_Mono.ttf"
            if [ $LOCAL_OR_GLOBAL == "GLOBAL" ]; then
                VIMRC="/usr/share/vim/vimrc"
            elif [ $LOCAL_OR_GLOBAL == "LOCAL" ]; then
                VIMRC="$HOME/.vimrc"
                BASHRC="$HOME/.bash_profile"
                POWERLINE_PATH="$HOME/Library/Python/2.7/lib/python/site-packages/powerline/bindings"
                POWERLINE_BIN="$HOME/Library/Python/2.7/bin"
            fi
            ;;
        "Linux")
            INSTALL_CMD="sudo apt-get install -y"
            SED_CMD_PREFIX="sed -i"
            GLOBAL_VIMRC="/etc/vim/vimrc.local"
            OS=`uname -o`
            LOCAL_BASHRC="$HOME/.bashrc"
            LOCAL_POWERLINE_PATH="$HOME/.local/lib/python2.7/site-packages/powerline/bindings"
            LOCAL_POWERLINE_BIN="$HOME/.local/bin"
            GLOBAL_POWERLINE_PATH="/usr/local/lib/python2.7/dist-packages/powerline/bindings/"
            if [ $LOCAL_OR_GLOBAL == "GLOBAL" ]; then
                VIMRC="/etc/vim/vimrc.local"
                POWERLINE_PATH="/usr/local/lib/python2.7/dist-packages/powerline/bindings/"
            elif [ $LOCAL_OR_GLOBAL == "LOCAL" ]; then
                VIMRC="$HOME/.vimrc"
                BASHRC="$HOME/.bashrc"
                POWERLINE_PATH="$HOME/.local/lib/python2.7/site-packages/powerline/bindings"
                POWERLINE_BIN="$HOME/.local/bin"
            fi
            ;;
        "FreeBSD")
            GLOBAL_VIMRC="/usr/local/share/vim/vimrc"
            ;;
        *)
            echo "$OS, not supported"
    esac
    echoGreen "[OS]: $OS"
}

checkVim() {
    echo "Vim path: `which vim`"
}

installPowerline() {
    # install pip
    type pip >/dev/null 2>&1 && echoGreen "[pip]: Checked."
    type pip >/dev/null 2>&1 \
        || (echoYellow "[pip]: Installing..." && $INSTALL_CMD python-pip)
    err=$((pip list >/dev/null) 2>&1)
    # if $err contains "upgrade"
    if [ "${err#*upgrade}" != "$err" ]; then
        echoYellow "[pip]: Upgrading..." && pip install --upgrade pip >/dev/null 2>&1;
    fi

    # install powerline
    pip show -f powerline-status | grep powerline >/dev/null
    # cannot use `grep --quiet` cuz `pip` does not handle
    # SIGPIPE and will generates error
    if [ $? -eq 0 ]; then echoGreen "[powerline]: Checked."
    else
        echoYellow "[powerline]: Installing..."
        pip install --user powerline-status
    fi

    confShellRC
}

localInstallPowerline() {
    type pip >/dev/null 2>&1 && echo "pip: Checked."
    type pip >/dev/null 2>&1 \
        || (echo "pip: Installing..." && brew install python)
    err=$((pip list >/dev/null) 2>&1)
    # if $err contains "upgrade"
    if [ "${err#*upgrade}" != "$err" ]; then
        echo "pip: Upgrading..." && pip install --upgrade pip >/dev/null 2>&1;
    fi

    pip show -f powerline-status >/dev/null 2>&1 && echo "powerline: Checked."
    pip show -f powerline-status >/dev/null 2>&1 \
        || (echo "powerline: Installing..." && pip install --user powerline-status >/dev/null 2>&1)

    confShellRC
}

confShellRC() {
    # Bash
    powerlineConf="# JKODRUM POWERLINE SECTION START
export PATH=\"$LOCAL_POWERLINE_BIN:\$PATH\"
if [ -f $LOCAL_POWERLINE_PATH/bash/powerline.sh ]; then
    source $LOCAL_POWERLINE_PATH/bash/powerline.sh
fi
# JKODRUM SECTION END"
    grep "JKODRUM SECTION" $LOCAL_BASHRC >/dev/null \
        && echoBlue "[$LOCAL_BASHRC]: Been configured before."
    grep "JKODRUM SECTION" $LOCAL_BASHRC >/dev/null \
        || (echo "$powerlineConf" >> $LOCAL_BASHRC && echoGreen "[$LOCAL_OR_GLOBAL]: Configured.")
}

# TODO: powerline for vim
installVimrc() {
    # checkVim
    grep "JKODRUM SECTION" $VIMRC >/dev/null
    if [ $? -eq 0 ]; then
        echoBlue "[$VIMRC]: Been installed before."
    else
        echo "\" JKODRUM SECTION START `date +%Y%m%d\ %a.`" >> $VIMRC
        echo "\" DO NOT EDIT THIS SECTION" >> $VIMRC
        cat .vimrc >> $VIMRC
        echo -e "\n\n\" {***** Powerline *****" >> $VIMRC
        echo "set rtp+=$POWERLINE_PATH/vim/" >> $VIMRC
        echo "\" }***** Powerline *****" >> $VIMRC
        echo "\" JKODRUM SECTION END" >> $VIMRC
        echoGreen "[$VIMRC]: Configured."
    fi

    installNeoBundle
}

# TODO: global neobundle
installNeoBundle() {
    # Install Shougo NeoBundle
    # curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh | sh
    BUNDLE_DIR=~/.vim/bundle
    INSTALL_DIR="$BUNDLE_DIR/neobundle.vim"
    if [ -e "$INSTALL_DIR" ]; then
        echoGreen "[NeoBundle]: Checked!"
    else
        echoYellow "[NeoBundle]: Installing..."
        git clone https://github.com/Shougo/neobundle.vim "$INSTALL_DIR"
    fi
}

uninstallVimrc() {
    $SED_CMD_PREFIX '/JKODRUM/,/JKODRUM/d' $VIMRC
    echoRed "[$VIMRC]: Unconfigured."
}

localUninstallPowerline() {
    type pip >/dev/null 2>&1 \
    && (pip show -f powerline-status >/dev/null 2>&1 \
      && pip uninstall powerline-status -y >/dev/null 2>&1) \
    && echo "powerline: Uninstalled."
    unconfShellRC
}


unconfShellRC() {
    #echo "unconfShellRC"
    sed -i '' '/JKODRUM/,/JKODRUM/d' $LOCAL_BASHRC
    echo "bashrcConf: Unconfigured."
}

installFonts() {
    if [ ! -f "$FONT_FILE" ]; then
        type wget >/dev/null 2>&1 && echo "wget: Checked."
        if [ $OS == "Darwin" ]; then
            type wget >/dev/null 2>&1 \
                || (echo "wget: Installing..." && brew install wget)

            echo "font: Downloading..."  && wget https://github.com/powerline/fonts/raw/master/DejaVuSansMono/DejaVu%20Sans%20Mono%20for%20Powerline.ttf -O $FONT_FILE >/dev/null 2>&1
            echo "* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *"
            echo "* Please install powerline font manually.                         *"
            echo "* Double click \"DejaVu_Sans_Mono.ttf\" on Desktop to install.      *"
            echo "* Open terminal preferences and select the font.                  *"
            echo "* For more fonts, https://github.com/powerline/fonts              *"
            echo "* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *"
        elif [ $OS == "GNU/Linux" ]; then
            wget https://github.com/Lokaltog/powerline/raw/develop/font/PowerlineSymbols.otf https://github.com/Lokaltog/powerline/raw/develop/font/10-powerline-symbols.conf
            mkdir -p ~/.fonts/ && mv PowerlineSymbols.otf ~/.fonts/
            fc-cache -vf ~/.fonts
            mkdir -p ~/.config/fontconfig/conf.d/ && mv 10-powerline-symbols.conf ~/.config/fontconfig/conf.d/
        fi
    fi
}

requireSudo() {
    echo "Require sudo"
    sudo echo "hello" >/dev/null
}

start $*
# installNeoBundle

# echo "Operating System: `platform`"
# checkVim

# sed -i '' '/jKodrum/,/jKodrum/d' $vimrc