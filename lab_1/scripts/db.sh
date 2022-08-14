#!/usr/bin/env bash

readonly USERS_DB_FILE="../data/users.db";
readonly USERS_BACKUP_FOLDER="../data/backup/";

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

saveUser(){
    echo "$1:$2" >> $USERS_DB_FILE;
}

add(){
    until [[ $username =~ ^[[:alnum:]]+$ ]]; do
        read -p "Please provide a username (Must be alphanumeric): " username;
    done

    until [[ $role =~ ^[[:alnum:]]+$ ]]; do
        read -p "Please type in $username's role (Must be alphanumeric): " role;
    done
    
    saveUser $username $role;

    echo "User $username with role $role was added.";
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

getBackupName(){
    echo $(date '+%Y-%m-%d')'-users.db.backup';
}

backup(){
    cp $USERS_DB_FILE $USERS_BACKUP_FOLDER`getBackupName`
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
