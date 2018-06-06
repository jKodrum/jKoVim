#!/bin/bash
# Author: jKodrum
# Program: jKoVim.sh
# Description: Install powerline and jKodrum's vimrc
#
# Parameters:
# default: install powerline and vimrc locally
# -a: install powerline and vimrc globally (system wide)
# -u: uninstall powerline and vimrc
# TODO: global installation

INSTALLATION_OUTPUT_REDIRECT="/dev/stdout"
#INSTALLATION_OUTPUT_REDIRECT="/dev/null"
#INSTALLATION_OUTPUT_REDIRECT="-"

bold='\033[1m'
red='\033[31m'
green='\033[32m'
yellow='\033[33m'
blue='\033[34m'
magenta='\033[35m'
cyan='\033[36m'
reset='\033[m'
echoGreen() { echo -e "${green}$*${reset}"; }
echoRed() { echo -e "${red}$*${reset}"; }
echoYellow() { echo -e "${yellow}$*${reset}"; }
echoBlue() { echo -e "${blue}$*${reset}"; }
echoMagenta() { echo -e "${magenta}$*${reset}"; }
echoCyan() { echo -e "${cyan}$*${reset}"; }

JKOVIM_DIR="$( cd -P $( dirname $0 ) && pwd -P )"

# TODO: global install
# TODO: en/diable powerline
start() {
    #echo "arg: $*"
    LOCAL_OR_GLOBAL="LOCAL"
    case $1 in
        "install")
            shift
            if [ $# -ge 1 -a "${1:0:2}" == "-a" ]; then
                echo "[Globally Install]: system wide"
                LOCAL_OR_GLOBAL="GLOBAL"
            elif [ $# -eq 0 -o "${1:0:2}" == "-u" ]; then
                echo "[Default Install]: per user"
            else
                echoRed "Unknown option \"$1\"."
                exit -1
            fi
            platform
            installer
            installPowerline
            confShellRC
            installVimrc
            installNeoBundle
            installFonts
            echo "Please restart your termianl or enter the command:"
            echo -e "${bold}source $BASHRC${reset}"
            ;;
        "uninstall")
            shift
            if [ $# -ge 1 -a "${1:0:2}" == "-a" ]; then
                echoRed "[Globally Uninstall]: system wide"
                LOCAL_OR_GLOBAL="GLOBAL"
            elif [ $# -eq 0 -o "${1:0:2}" == "-u" ]; then
                echoRed "[Default Uninstall]: per user"
            else
                echoRed "${bold}unknown option \"$1\"."
            fi
            platform
            unconfShellRC
            uninstallVimrc
            uninstallPowerline
            uninstallNeoBundle
            uninstallFont
            echoRed "* * * * * * * * * * * * * * * * * * * * * * * * * * * *"
            echoRed "* * * * * * * * ${bold}PLEASE RESTART TERMINAL${reset}${red} * * * * * * * *"
            echoRed "* * * * * * * * * * * * * * * * * * * * * * * * * * * *"
            echo ""
            ;;
        *)
            echo -e "$0 install [${bold}option$reset]"
            echo -e "$0 uninstall [${bold}option$reset]"
            echo -e "${bold}Option$reset"
            echo "-a    install powerline and vimrc globally, system wide"
            echo "-u    install powerline and vimrc locally, per user (default)"
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
            PYTHON_PIP="python"
            PIP="pip3"
            if [ $LOCAL_OR_GLOBAL == "GLOBAL" ]; then
                VIMRC="/usr/share/vim/vimrc"
            elif [ $LOCAL_OR_GLOBAL == "LOCAL" ]; then
                VIMRC="$HOME/.vimrc"
                BASHRC="$HOME/.bash_profile"
                POWERLINE_PATH="$HOME/Library/Python/3.6/lib/python/site-packages/powerline/bindings"
                POWERLINE_BIN="$HOME/Library/Python/3.6/bin"
            fi
            ;;
        "Linux")
            ESSENTIAL="git vim curl fontconfig"
            INSTALL_CMD="sudo apt-get install -y"
            SED_CMD_PREFIX="sed -i"
            PYTHON_PIP="python-pip"
            PIP="pip"
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
    if [ "$OS" == "Darwin" ]; then
        echo "[OS]: Mac OS X"
    else
        echo "[OS]: $OS"
    fi
}

installer() {
    if [ "$OS" != "Darwin" ]; then return; fi
    type brew &>/dev/null
    if [ $? -eq 0 ]; then
        echoGreen "[Homebrew]: Checked."
        return;
    fi
    echoYellow "[Homebrew]: Installing..."
    echo -e "\015" | /usr/bin/ruby -e "$(curl \
    -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" \
    >$INSTALLATION_OUTPUT_REDIRECT \
    || (echoRed "Fails to install Homebrew. Installer aborts."; exit -1)
}

checkVim() {
    echo "Vim path: `which vim`"
}

installPowerline() {
    # install pip
    type $PIP &>/dev/null
    if [ $? -eq 0 ]; then
        echoGreen "[pip]: Checked."
    else
        echoYellow "[pip]: Installing..."
        $INSTALL_CMD $PYTHON_PIP >$INSTALLATION_OUTPUT_REDIRECT
    fi

    # install powerline
    $PIP list powerline-status | grep powerline &>/dev/null
    if [ $? -eq 0 ]; then
        echoGreen "[powerline]: Checked."
    else
        echoYellow "[powerline]: Installing..."
        $PIP install --user powerline-status >$INSTALLATION_OUTPUT_REDIRECT


        POWERLINE_CONFIG_FILE="$POWERLINE_PATH/../config_files/config.json"
        #SUBTITUTE_PATTERN='/shell/,/}/s/"theme": "default"/"theme": "default_leftonly"/'
        #SUBTITUTE_PATTERN="'/shell/,/}/s/\"theme\": \"default\"/\"theme\": \"default_leftonly\"/'"
        #$SED_CMD_PREFIX `echo $SUBTITUTE_PATTERN` $POWERLINE_CONFIG_FILE
        #$SED_CMD_PREFIX '/shell/,/}/s/"theme": "default"/"theme": "default_leftonly"/' $POWERLINE_CONFIG_FILE
		if [ "$OS" == "Darwin" ]; then
			sed -i '' '/shell/,/}/s/"theme": "default"/"theme": "default_leftonly"/' $POWERLINE_CONFIG_FILE
		else
			sed -i '/shell/,/}/s/"theme": "default"/"theme": "default_leftonly"/' $POWERLINE_CONFIG_FILE
		fi
        echoGreen "[powerline/config.json]: Modified."

    fi
}

confShellRC() {
    # Bash
    powerlineConf="# JKODRUM POWERLINE SECTION START `date +%Y%m%d\ %a.`\n"
    powerlineConf+="# DO NOT EDIT THIS SECTION\n"
    powerlineConf+="export LC_LANG=en_US.UTF-8\n"
    powerlineConf+="export LC_ALL=en_US.UTF-8\n"
    powerlineConf+="export PATH=\"$POWERLINE_BIN:\$PATH\"\n"
    powerlineConf+="if [ -f $POWERLINE_PATH/bash/powerline.sh ]; then\n"
    powerlineConf+="\tsource $POWERLINE_PATH/bash/powerline.sh\n"
    powerlineConf+="fi\n"
    powerlineConf+="# JKODRUM SECTION END"
    if $(grep --quiet "JKODRUM SECTION" $BASHRC); then
        echoCyan "[$BASHRC]: Been configured before."
    else
        powerlineConf=$(echo $powerlineConf | sed "s|$HOME|\$HOME|g")
        echo -e "$powerlineConf" >> $BASHRC
        echoGreen "[$BASHRC]: Configured."
    fi
}

installVimrc() {
    # checkVim
    grep "JKODRUM SECTION" $VIMRC &>/dev/null
    if [ $? -eq 0 ]; then
        echoCyan "[$VIMRC]: Been installed before."
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

installNeoBundle() {
    # curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh | sh
    BUNDLE_DIR=~/.vim/bundle
    INSTALL_DIR="$BUNDLE_DIR/neobundle.vim"
    if [ -e "$INSTALL_DIR" ]; then
        echoGreen "[NeoBundle]: $INSTALL_DIR exists."
    else
        echoYellow "[NeoBundle]: Installing..."
        git clone https://github.com/Shougo/neobundle.vim "$INSTALL_DIR"
    fi
}

uninstallVimrc() {
    #$SED_CMD_PREFIX '/JKODRUM/,/JKODRUM/d' $VIMRC
	if [ "$OS" == "Darwin" ]; then
		sed -i '' '/JKODRUM/,/JKODRUM/d' $VIMRC
	else
		sed -i '/JKODRUM/,/JKODRUM/d' $VIMRC
	fi
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
    type $PIP &>/dev/null
    if [ $? -eq 0 ]; then
        $PIP list | grep powerline-status &>/dev/null
        if [ $? -eq 0 ]; then
            $PIP uninstall powerline-status -y &>/dev/null \
            && echoRed "[powerline]: Uninstalled."
        else
            echoRed "[powerline]: Already uninstalled."
        fi
    fi
}

unconfShellRC() {
    #$SED_CMD_PREFIX '/JKODRUM/,/JKODRUM/d' $BASHRC
	if [ "$OS" == "Darwin" ]; then
		sed -i '' '/JKODRUM/,/JKODRUM/d' $BASHRC
	else
		sed -i '/JKODRUM/,/JKODRUM/d' $BASHRC
	fi
    echoRed "[$BASHRC]: Unconfigured!"
}

checkCurl() {
    type curl &>/dev/null
    if [ $? -ne 0 ]; then
        $INSTALL_CMD curl >$INSTALLATION_OUTPUT_REDIRECT
    fi
}

installFonts() {
    FONT_OTF_URL="https://github.com/Lokaltog/powerline/raw/develop/font/PowerlineSymbols.otf"
    FONT_CONF_URL="https://raw.githubusercontent.com/powerline/powerline/develop/font/10-powerline-symbols.conf"

    if [ -f "$FONT_FILE" ]; then
        echoGreen "[font]: $FONT_FILE exists."
    else
        echoYellow "[font]: Installing..."
        checkCurl
        if [ $OS == "Darwin" ]; then
            FONT_TTF_URL="https://raw.githubusercontent.com/powerline/fonts/master/DejaVuSansMono/DejaVu%20Sans%20Mono%20for%20Powerline.ttf"
            curl $FONT_TTF_URL > $FONT_FILE 2>/dev/null
            echo "* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *"
            echo "* Please install powerline font manually.                   *"
            echo -ne "* Double click ${bold}DejaVu_Sans_Mono.ttf${reset} on "
            echo "Desktop to install.  *"
            echo "* Open terminal preferences and select the font.            *"
            echo "* For more fonts, https://github.com/powerline/fonts        *"
            echo "* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *"
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
