#!/usr/bin/env bash

printHelp (){
    echo "Commands: add, backup, restore, find, list, help";

    echo "";

    echo "add";
    echo "Add user to users.db";

    echo "";

    echo "backup";
    echo "Creates a new file, named %date%-users.db.backup which is a copy of current users.db";

    echo "";

    echo "restore";
    echo "Takes the last created backup file and replaces users.db with it";
    
    echo "";
    
    echo "find";
    echo "Search user by username";
    
    echo "";

    echo "list [--inverse]";
    echo "Show all users";    
    
    echo "";

    echo "help";
    echo "Show available commands";
}

add(){
    echo "add"
}

find(){
    echo "find"
}

list(){
    echo "list";

    case $1 in 
        --inverse) echo 'inverse';;
        *) printNotSupportedMessage $1;;
    esac
}

backup(){
    echo "backup"
}

restore(){
    echo "restore"
}

printNotSupportedMessage(){
    echo "$1 is not supported"
}

case $1 in
  help) printHelp;;
  add) add;;
  find) find;;
  list) list $2;;
  backup) backup;;
  restore) restore;;
  *) printHelp;;
esac
