#!/usr/bin/env bash

readonly PIPELINE_NAME_PREFIX='pipeline-';
readonly JSON_FILE_EXT='.json';
readonly PIPELINE_FILENAME='pipeline'$JSON_FILE_EXT;

if [ $(dpkg-query -W -f='${Status}' jq 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    echo "This script requires jq library to be installed.";  
    echo "See https://stedolan.github.io/jq/download/ for installation options";
    exit;
fi

JSON_TEMPLATE=$1;
BRANCH='main';
OWNER='';
REPO='';
POLL_FOR_SOURCE_CHANGES='';
BUILD_CONFIGURATION='';

POSITIONAL_ARGS=();
while [[ $# -gt 0 ]]; do
  case $1 in
    --branch)
      BRANCH="$2";
      shift; shift;
      ;;
    --owner)
      OWNER="$2";
      shift; shift;
      ;;
    --repo)
      REPO="$2";
      shift; shift;
      ;;    
    --poll-for-source-changes)
      POLL_FOR_SOURCE_CHANGES="$2";
      shift; shift;
      ;;
    --configuration)
      BUILD_CONFIGURATION="$2";
      shift; shift;
      ;;
    -*|--*)
      echo "Unknown option $1";
      exit 1;
      ;;
    *)
      POSITIONAL_ARGS+=("$1");
      shift;
      ;;
  esac
done
set -- "${POSITIONAL_ARGS[@]}";

if [ "$OWNER" == "" ]; then
    echo "--owner parameter is required.";
    exit 1;
fi

if [ "$REPO" == "" ]; then
    echo "--repo parameter is required.";
    exit 1;
fi

if [ "$POLL_FOR_SOURCE_CHANGES" == "" ]; then
    echo "--poll-for-source-changes parameter is required.";
    exit 1;
fi

if [ "$BUILD_CONFIGURATION" == "" ]; then
    echo "--configuration parameter is required.";
    exit 1;
fi

if [ ! -f "$JSON_TEMPLATE" ]; then
    echo "$JSON_TEMPLATE is not an existing file. Please provide a valid path to JSON file as the first argument.";
    exit 1;
fi

saveAsName=$PIPELINE_NAME_PREFIX`date '+%Y-%m-%d'`$JSON_FILE_EXT;

jq 'del(.metadata) 
| ."pipeline"."version"+=1 
| (  .pipeline.stages[] 
    | select(.name == "Source") 
    | .actions[] 
    | select(.name == "Source") 
    | .configuration
  )+={Branch:"'$BRANCH'",Owner:"'$OWNER'",PollForSourceChanges:'$POLL_FOR_SOURCE_CHANGES',Repo:"'$REPO'"}
| (
    (   .pipeline.stages[] 
        |.actions[]
        |.configuration
        |.EnvironmentVariables
        |select(type=="string")
    )|=(
        fromjson
        |.[]
        |select(.name == "BUILD_CONFIGURATION")
        |.value
        |="'$BUILD_CONFIGURATION'"
        |tojson
    )
  )' $JSON_TEMPLATE > $saveAsName;

echo 'Saved as '$saveAsName;