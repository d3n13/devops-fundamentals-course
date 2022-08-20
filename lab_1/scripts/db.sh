#!/usr/bin/env bash

readonly USERS_DB_FILENAME='users.db';
readonly USERS_DB_FILE_PATH="../data/$USERS_DB_FILENAME";
readonly USERS_BACKUP_FOLDER="../data/backup/";
readonly BACKUP_FILENAME_SUFFIX="-$USERS_DB_FILENAME.backup";

readonly DB_DIVIDER=', ';

createDBFile(){
    touch "$USERS_DB_FILE_PATH";
    echo "$USERS_DB_FILENAME was generated."
}

ensureDBFileExists(){
    if [ ! -f "$USERS_DB_FILE_PATH" ]; then
        while true; do
            read -p "Required $USERS_DB_FILENAME file does not exist. Would you like to generate it first? (y/n)" yn
            case $yn in
                [Yy]* ) createDBFile; break;;
                [Nn]* ) 
                    echo "Failed: No $USERS_DB_FILENAME file exists."
                    exit;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi
}

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
    echo "$1$DB_DIVIDER$2" >> $USERS_DB_FILE_PATH;
}

add(){

    ensureDBFileExists;

    until [[ $username =~ ^[[:alnum:]]+$ ]]; do
        read -p "Please provide a username (Must be alphanumeric): " username;
    done

    local amount=`countUsers $username`;

    if [ $amount -gt 0 ]; then
        local user=`searchUser $username`;
        echo "This user already exists:";
        echo "$user";

        while true; do
            read -p "Do you want to create it anyway? (y/n)" yn
            case $yn in
                [Yy]* ) break;;
                [Nn]* ) exit;;
                * ) echo "Please answer yes or no.";;
            esac
        done  
    fi

    until [[ $role =~ ^[[:alnum:]]+$ ]]; do
        read -p "Please type in $username's role (Must be alphanumeric): " role;
    done

    saveUser $username $role;

    echo "User $username with role $role was added.";
}

countUsers(){
    grep -c "$1$DB_DIVIDER" $USERS_DB_FILE_PATH;
}

searchUser(){
    grep "$1$DB_DIVIDER" $USERS_DB_FILE_PATH;
}

find(){

    ensureDBFileExists;

    until [[ $username =~ ^[[:alnum:]]+$ ]]; do
        read -p "Please provide a username (Must be alphanumeric): " username;
    done

    local amount=`countUsers $username`;

    if [ $amount -eq 0 ]; then
        echo "User was not found";
        exit;
    fi

    local result=`searchUser $username`;

    echo  "$result";
}

list(){

    ensureDBFileExists;

    echo "list";

    case $1 in 
        --inverse) echo 'inverse';;
        *) printNotSupportedMessage $1;;
    esac
}

generateBackupName(){
    echo $(date '+%Y-%m-%d')$BACKUP_FILENAME_SUFFIX;
}

backup(){
    ensureDBFileExists;

    local backupName=`generateBackupName`;
    cp $USERS_DB_FILE_PATH $USERS_BACKUP_FOLDER$backupName;
    echo "Saved to $backupName";
}

findLastBackupName(){
    local lastBackupName=`ls -r $USERS_BACKUP_FOLDER | head -1`;
    echo $lastBackupName;
}

restore(){
    local lastBackupName=`findLastBackupName`;

    if [[ $lastBackupName == "" ]]; then
        echo "No backups found";
        exit;
    fi

    cp $USERS_BACKUP_FOLDER$lastBackupName $USERS_DB_FILE_PATH;
    echo "Restored from $lastBackupName";
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
