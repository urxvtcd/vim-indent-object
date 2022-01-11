#!/usr/bin/env sh

vim -Nu NONE '+packadd vim-indent-object' '+packadd vader.vim' '+Vader! tests/*'
