#!/bin/bash
display_usage() { 
    echo "This script must be run as follows (without file extension): " 
    echo "./_compileLatex.sh Filename"
    } 
# check whether user had supplied -h or --help . If yes display usage 
if [[ ( $# == "--help") ||  $# == "-h" ]] 
    then 
    display_usage
    exit 0
    fi 
 
File=$1
Filetex=$File.tex
#echo $File $Filetex
latex $File
bibtex $File
latex $File
pdflatex $Filetex
pdflatex $Filetex
