#!/bin/bash
display_usage() { 
    echo "This should be used to start google-chrome" 
    } 
# check whether user had supplied -h or --help . If yes display usage 
if [[ ( $# == "--help") ||  $# == "-h" ]] 
    then 
    display_usage
    exit 0
    fi 

pkill -9 chrome
google-chrome &
