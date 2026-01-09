#!/bin/bash

ZSH_CUSTOM=$HOME/.oh-my-zsh/custom

ln -sf $(pwd)/.zshrc $HOME/.zshrc
ln -sf $(pwd)/custom/*.zsh $ZSH_CUSTOM/