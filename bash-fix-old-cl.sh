#!/bin/env bash

do_subst () {
    sed -i -- "s/(flet /(cl-flet /g" "$1"
    sed -i -- "s/(labels /(cl-labels /g" "$1"
    sed -i -- "s/(loop for /(cl-loop for /g" "$1"
    sed -i -- "s/(defstruct /(cl-defstruct /g" "$1"
    sed -i -- "s/require 'cl)/require 'cl-lib)/g" "$1"
}

do_files() {
    
    echo "$PWD"
    for file in *.el
    do
        echo "$file"
        do_subst "$file"
    done
}

do_files

[ -d tests ] && {
    cd tests
    do_files 
    cd ..
}
