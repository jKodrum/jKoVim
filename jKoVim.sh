#!/bin/sh
# Author: jKodrum
# Program: jKoVim.sh
# Description: Install powerline and jKodrum's vimrc
#
# Parameters:
# default: install powerline and vimrc locally
# -a: install powerline and vimrc globally (system wide)
# -u: uninstall powerline and vimrc

start() {
    #echo "arg: $*"
    case $* in
        "-a")
            echo "install globally"
            LOCAL_OR_GLOBAL="GLOBAL"
            ;;
        "-u")
            echo "Uninstall"
            platform
            localUninstallPowerline
            UninstallVimrc
            echo "* * * * * * * * Please restart terminal. * * * * * * * *"
            echo ""
            ;;
        *)
            echo "default install: per user"
            LOCAL_OR_GLOBAL="LOCAL"
            platform
            localInstallPowerline
            InstallVimrc
            installFonts
            ;;
    esac
}

platform() {
    OS=`uname -s`
    LOCAL_VIMRC="$HOME/.vimrc"
    case $OS in
        "Darwin")
            GLOBAL_VIMRC="/usr/share/vim/vimrc"
            LOCAL_BASHRC="$HOME/.bash_profile"
            LOCAL_POWERLINE_PATH="$HOME/Library/Python/2.7/lib/python/site-packages/powerline/bindings"
            LOCAL_POWERLINE_BIN="$HOME/Library/Python/2.7/bin"
            FONT_FILE="$HOME/Desktop/DejaVu_Sans_Mono.ttf"
            ;;
        "Linux")
            GLOBAL_VIMRC="/etc/vim/vimrc.local"
            OS=`uname -o`
            LOCAL_BASHRC="$HOME/.bashrc"
            LOCAL_POWERLINE_PATH="$HOME/.local/lib/python2.7/site-packages/powerline/bindings"
            LOCAL_POWERLINE_BIN="$HOME/.local/bin"
            GLOBAL_POWERLINE_PATH="/usr/local/lib/python2.7/dist-packages/powerline/bindings/"
            ;;
        "FreeBSD")
            GLOBAL_VIMRC="/usr/local/share/vim/vimrc"
            ;;
        *)
            echo "$OS, not supported"
    esac
    echo "OS: $OS"
}

checkVim() {
    echo "Vim path: `which vim`"
}

# TODO: powerline for vim
InstallVimrc() {
    echo "InstallVimrc..."
    if [ $LOCAL_OR_GLOBAL == "GLOBAL" ]; then
        ;
    elif [ $LOCAL_OR_GLOBAL == "LOCAL" ]; then
        # checkVim
        grep "JKODRUM SECTION" $LOCAL_VIMRC >/dev/null \
            && echo "localVimrc: Been installed before."
        grep "JKODRUM SECTION" $LOCAL_VIMRC >/dev/null \
            || (cat .vimrc >> $LOCAL_VIMRC && echo "localVimrc: Configured.")
    fi
    #if [ `grep "JKODRUM SECTION" $LOCAL_VIMRC >/dev/null` -eq 0 ]; then
    #fi
}
UninstallVimrc() {
    if [ $LOCAL_OR_GLOBAL == "GLOBAL" ]; then
        ;
    elif [ $LOCAL_OR_GLOBAL == "LOCAL" ]; then
        #echo "UninstallVimrc"
        sed -i '' '/JKODRUM/,/JKODRUM/d' $LOCAL_VIMRC
        echo "localVimrc: Unconfigured."
    fi
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
export PATH=\"\$LOCAL_POWERLINE_BIN:\$PATH\"
if [ -f $LOCAL_POWERLINE_PATH/bash/powerline.sh ]; then
    source $LOCAL_POWERLINE_PATH/bash/powerline.sh
fi
# JKODRUM SECTION END"
    grep "JKODRUM SECTION" $LOCAL_BASHRC >/dev/null \
        && echo "bashrcConf: Been configured before."
    grep "JKODRUM SECTION" $LOCAL_BASHRC >/dev/null \
        || (echo "$powerlineConf" >> $LOCAL_BASHRC && echo "bashrcConf: Configured.")
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

requireSudo
start $*
# echo "Operating System: `platform`"
# checkVim

# sed -i '' '/jKodrum/,/jKodrum/d' $vimrc
