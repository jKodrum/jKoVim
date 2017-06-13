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

JKOVIM_DIR="$( cd -P $( dirname $0 ) && pwd -P )"

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
        "-t")
            echoGreen "Install test"
            platform
            installPowerline
            confShellRC
            installVimrc
            installNeoBundle
            ;;
        "-y")
            echoRed "Uninstall test"
            platform
            uninstallFont
            ;;
        "-u")
            echoRed "Uninstall"
            platform
            uninstallPowerline
            uninstallVimrc
            uninstallNeoBundle
            unconfShellRC
            uninstallFont
            echoRed "* * * * * * * * * * * * * * * * * * * * * * * * * * * *"
            echoRed "* * * * * * * * PLEASE RESTART TERMINAL * * * * * * * *"
            echoRed "* * * * * * * * * * * * * * * * * * * * * * * * * * * *"
            echo ""
            ;;
        *)
            echoGreen "[Default Install]: per user"
            LOCAL_OR_GLOBAL="LOCAL"
            platform
            installPowerline
            confShellRC
            installVimrc
            installNeoBundle
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
            FONT_FILE="$HOME/Desktop/DejaVu_Sans_Mono.ttf"
            FONT_FILE="$HOME/Library/Fonts/DejaVu\ Sans\ Mono\ for\ Powerline.ttf"
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
            ESSENTIAL="git vim curl fontconfig"
            INSTALL_CMD="sudo apt-get install -y"
            SED_CMD_PREFIX="sed -i"
            OS=`uname -o`
            if [ $LOCAL_OR_GLOBAL == "GLOBAL" ]; then
                VIMRC="/etc/vim/vimrc.local"
                POWERLINE_PATH="/usr/local/lib/python2.7/dist-packages/powerline/bindings/"
            elif [ $LOCAL_OR_GLOBAL == "LOCAL" ]; then
                VIMRC="$HOME/.vimrc"
                BASHRC="$HOME/.bashrc"
                POWERLINE_PATH="$HOME/.local/lib/python2.7/site-packages/powerline/bindings"
                POWERLINE_BIN="$HOME/.local/bin"
                FONT_PATH="$HOME/.font"
                FONT_FILE="$HOME/.font/PowerlineSymbols.otf"
                FONT_CONFIG_PATH="$HOME/.config/fontconfig/conf.d"
                FONT_CONFIG_FILE="$HOME/.config/fontconfig/conf.d/10-powerline-symbols.conf"
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
    #err=$((pip list >/dev/null) 2>&1)
    ## if $err contains "upgrade"
    #if [ "${err#*upgrade}" != "$err" ]; then
    #    echoYellow "[pip]: Upgrading..." && pip install --upgrade pip >/dev/null 2>&1;
    #fi

    # install powerline
    pip show -f powerline-status | grep powerline >/dev/null
    # cannot use `grep --quiet` cuz `pip` does not handle
    # SIGPIPE and will generates error
    if [ $? -eq 0 ]; then echoGreen "[powerline]: Checked."
    else
        echoYellow "[powerline]: Installing..."
        pip install --user powerline-status
        POWERLINE_CONFIG_FILE="$POWERLINE_PATH/../config_files/config.json"
        #SUBTITUTE_PATTERN='/shell/,/}/s/"theme": "default"/"theme": "default_leftonly"/'
        #SUBTITUTE_PATTERN="'/shell/,/}/s/\"theme\": \"default\"/\"theme\": \"default_leftonly\"/'"
        #$SED_CMD_PREFIX `echo $SUBTITUTE_PATTERN` $POWERLINE_CONFIG_FILE
        $SED_CMD_PREFIX '/shell/,/}/s/"theme": "default"/"theme": "default_leftonly"/' $POWERLINE_CONFIG_FILE
        echoGreen "[powerline/config.json]: Modified."
    fi
}

confShellRC() {
    # Bash
    powerlineConf="# JKODRUM POWERLINE SECTION START `date +%Y%m%d\ %a.`\n"
    powerlineConf+="# DO NOT EDIT THIS SECTION\n"
    powerlineConf+="export PATH=\"$POWERLINE_BIN:\$PATH\"\n"
    powerlineConf+="if [ -f $POWERLINE_PATH/bash/powerline.sh ]; then\n"
    powerlineConf+="\tsource $POWERLINE_PATH/bash/powerline.sh\n"
    powerlineConf+="fi\n"
    powerlineConf+="# JKODRUM SECTION END"
    if $(grep --quiet "JKODRUM SECTION" $BASHRC); then
        echoBlue "[$BASHRC]: Been configured before."
    else
        powerlineConf=$(echo $powerlineConf | sed "s|$HOME|\$HOME|g")
        echo -e "$powerlineConf" >> $BASHRC
        echoGreen "[$BASHRC]: Configured."
    fi
}

# TODO: powerline for vim
installVimrc() {
    # checkVim
    grep "JKODRUM SECTION" $VIMRC >/dev/null
    if [ $? -eq 0 ]; then
        echoBlue "[$VIMRC]: Been installed before."
    else
        vimrcConf="\" JKODRUM SECTION START `date +%Y%m%d\ %a.`\n"
        vimrcConf+="\" DO NOT EDIT THIS SECTION\n"
        vimrcConf+="`cat $JKOVIM_DIR/.vimrc`"
        vimrcConf+="\n\n\" {***** Powerline *****\n"
        vimrcConf+="set runtimepath+=$POWERLINE_PATH/vim/\n"
        vimrcConf+="\" }***** Powerline *****\n"
        vimrcConf+="\" JKODRUM SECTION END"
        vimrcConf=$(echo "$vimrcConf" | sed "s|$HOME|\$HOME|g")
        echo -e "$vimrcConf" >> $VIMRC
        echoGreen "[$VIMRC]: Configured."
    fi
}

# TODO: global neobundle
installNeoBundle() {
    # Install Shougo NeoBundle
    # curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh | sh
    BUNDLE_DIR=~/.vim/bundle
    INSTALL_DIR="$BUNDLE_DIR/neobundle.vim"
    if [ -e "$INSTALL_DIR" ]; then
        echoGreen "[NeoBundle]: Checked."
    else
        echoYellow "[NeoBundle]: Installing..."
        git clone https://github.com/Shougo/neobundle.vim "$INSTALL_DIR"
    fi
}

uninstallVimrc() {
    $SED_CMD_PREFIX '/JKODRUM/,/JKODRUM/d' $VIMRC
    echoRed "[$VIMRC]: Unconfigured!"
}

uninstallNeoBundle() {
    BUNDLE_DIR=~/.vim/bundle
    if [ -e "$BUNDLE_DIR" ]; then
        rm -rf $BUNDLE_DIR
        echoRed "[NeoBundle]: Uninstall!"
    fi
}

uninstallPowerline() {
    type pip >/dev/null 2>&1 \
    && (pip show -f powerline-status >/dev/null 2>&1 \
      && pip uninstall powerline-status -y >/dev/null 2>&1) \
    && echoRed "[powerline]: Uninstalled."
    unconfShellRC
}

unconfShellRC() {
    $SED_CMD_PREFIX '/JKODRUM/,/JKODRUM/d' $BASHRC
    echoRed "[$BASHRC]: Unconfigured!"
}

# TODO: check curl
installFonts() {
    FONT_OTF_URL="https://github.com/Lokaltog/powerline/raw/develop/font/PowerlineSymbols.otf"
    FONT_CONF_URL="https://raw.githubusercontent.com/powerline/powerline/develop/font/10-powerline-symbols.conf"

    if [ -f "$FONT_FILE" ]; then
        echoGreen "[font]: Checked."
    else
        echoYellow "[font]: Installing..."
        if [ $OS == "Darwin" ]; then
            FONT_TTF_URL="https://github.com/powerline/fonts/raw/master/DejaVuSansMono/DejaVu%20Sans%20Mono%20for%20Powerline.ttf"
            curl $FONT_TTF_URL > $FONT_FILE
            echo "* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *"
            echo "* Please install powerline font manually.                         *"
            echo "* Double click \"DejaVu_Sans_Mono.ttf\" on Desktop to install.      *"
            echo "* Open terminal preferences and select the font.                  *"
            echo "* For more fonts, https://github.com/powerline/fonts              *"
            echo "* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *"
        elif [ $OS == "GNU/Linux" ]; then
            mkdir -p $FONT_PATH && curl $FONT_OTF_URL > $FONT_FILE
            mkdir -p $FONT_CONFIG_PATH && curl $FONT_CONF_URL > $FONT_CONFIG_FILE
            fc-cache --force $FONT_PATH
        fi
    fi
}

uninstallFont() {
    [ -f "$FONT_FILE" ] && rm "$FONT_FILE"
    if [ $OS == "GNU/Linux" ]; then
        [ -f $FONT_CONFIG_FILE ] && rm $FONT_CONFIG_FILE
    fi
    echoRed "[font]: Uninstall!"
}

start $*
