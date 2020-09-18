#!/bin/bash
git config --global color.ui true
git config --global core.editor vim
git config --global core.pager 'less -x1,5'
git config --global alias.lg "log --color --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --author-date-order --abbrev-commit --"
