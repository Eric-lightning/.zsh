##################################################
export  TASK_DIR="$HOME/.task"
export _indexFile="${TASK_DIR}/index.psv"
export _doneFile="${TASK_DIR}/done.psv"
##################################################
mkdir -p "$TASK_DIR/done.d/"

if [[ ! -e ${TASK_DIR}/.git ]]
then
  git init $TASK_DIR
fi


function _task_list_verbose() {
  cnt=0
  if [[ "$1" == "verbose" ]]
  then
    echo "No.|task|add date|detail|tags|uuid"
    echo "-----|----------------------|---------------------|---------|--------|----------------------"
  else
    echo "No.|task|add date|detail|tags"
    echo "-----|----------------------|---------------------|---------|--------"
  fi
  for file in $(cut -d'|' -f1 $_indexFile )
  do
    cnt=$(echo "$cnt + 1" | bc)
    source "${TASK_DIR}/${file}.source"
    if [ "$1" = "verbose" ]
      then echo " $cnt| $_task_name| $_task_add_date $_task_add_time| $_task_more| $_task_tags| $file"
      else echo " $cnt| $_task_name| $_task_add_date $_task_add_time| $_task_more| $_task_tags"
    fi
  done
}

function _task_add(){
  if [[ $1 == '' ]]; then echo "plz name."; return 1; fi
  _id=$(uuidgen)
  echo "$_id|$1" >> $_indexFile
  _targetFile="${TASK_DIR}/${_id}.source"
  fix_name="$(echo $1 | sed -e "s;\';;g" )"
  fix_more="$(echo $2 | sed -e "s;\';;g")"
  echo "_task_name=\"$fix_name\"" >> $_targetFile
  echo "_task_more=\"$fix_more\"" >> $_targetFile
  echo "_task_add_date='$(date +%Y-%m-%d)'" >> $_targetFile
  echo "_task_add_time='$(date +%H:%M:%S)'" >> $_targetFile
  echo "_task_tags=" >> $_targetFile
  echo "New Task to $_targetFile"
  git -C ${TASK_DIR} add $_targetFile $_indexFile
  git -C ${TASK_DIR} commit -m"ADD: $1 <$_id>"
}


function _task_done(){
  if [[ $1 == '' ]]; then echo "plz id."; return 1; fi
  _id=$(awk "NR==$1" $_indexFile | cut -d'|' -f1)
  _name=$(awk "NR==$1" $_indexFile | cut -d'|' -f2)
  git -C ${TASK_DIR} mv "${TASK_DIR}/${_id}.source" "${TASK_DIR}/done.d/${_id}.source"
  awk "NR==$1" $_indexFile >> $_doneFile
  sed -i "${1}d" $_indexFile
  echo "done $_name"
  git -C ${TASK_DIR} add $_indexFile $_doneFile
  git -C ${TASK_DIR} commit -m"DONE: $_name <$_id>"
  if [[ "$_name" == "$TASK" ]]
  then
    TASK=""
  fi
}

function _task_delete(){
  if [[ $1 == '' ]]; then echo "plz id."; return 1; fi
  _id=$(awk "NR==$1" $_indexFile | cut -d'|' -f1)
  _name=$(awk "NR==$1" $_indexFile | cut -d'|' -f2)
  git -C ${TASK_DIR} rm "${TASK_DIR}/${_id}.source"
  sed -i "${1}d" $_indexFile
  echo "deleted $_name <$_id>"
  git -C ${TASK_DIR} add $_indexFile
  git -C ${TASK_DIR} commit -m"DEL: $_name"
  if [[ "$_name" == "$TASK" ]]
  then
      TASK=""
  fi
}
##################################################
function _task_get(){
  if [[ $1 == '' ]]; then echo "plz id."; return 1; fi
  _id=$(awk "NR==$1" $_indexFile | cut -d'|' -f1)
  source "${TASK_DIR}/${_id}.source"
  echo "New Task to $_targetFile"
  echo "Detail:    $_task_more"
  echo "Add Date:  $_task_add_date $_task_add_time"
  echo "TAGS: $_task_tags"
}

function _task_tags(){
  if [[ $1 == '' ]]; then echo "plz id."; return 1; fi

  _id=$(awk "NR==$1" $_indexFile | cut -d'|' -f1)
  source "${TASK_DIR}/${_id}.source"
  if [[ $2 == '' ]]
  then
    echo "$_task_tags"
    return 0
  fi

  for tag in ${@:2}
  do
    [ "$_task_tags" != '' ] && _task_tags=" $_task_tags"
    tag_name=$(echo $tag | cut -c 2- )
    tag_prefix=$(echo $tag | cut -c 1 )
    [ "$tag_prefix" = "+" ] && _task_tags="$tag_name$_task_tags"
    [ "$tag_prefix" = "-" ] && _task_tags="$(echo $_task_tags | sed -e s;\ $tag_name\ ;\ ;g )"
  done

  _targetFile="${TASK_DIR}/${_id}.source"
  echo -n '' > $_targetFile
  echo "_task_name=\"$_task_name\"" >> $_targetFile
  echo "_task_more=\"$_task_more\"" >> $_targetFile
  echo "_task_add_date=\"$_task_add_date\"" >> $_targetFile
  echo "_task_add_time=\"$_task_add_time\"" >> $_targetFile
  echo "_task_tags=\"$_task_tags\"" >> $_targetFile
}

function _task_pin(){
  if [[ $1 == '' ]]
  then
    TASK=""
  else
    TASK=$(awk "NR==$1" $_indexFile | cut -d'|' -f2)
  fi
}
##################################
function _task_show(){
  if [[ $(wc -l $_indexFile | awk '{print $1}') -gt 10 ]]
  then
    clear
  fi
  if [ "$1" = "raw" ]
  then
    _task_list_verbose $@
  else
    if [ "$1" = "grep" ]
    then
      _task_list_verbose $@ | column -ts'|' | head -n1
      _task_list_verbose $@ | column -ts'|' | grep ${@:2}
    else
      _task_list_verbose $@ | column -ts'|'
    fi
  fi
}
function _task_sync(){
  echo "sync .task git-repo."
  git -C "${TASK_DIR}" pull
  test $? -ne 0 && return 1
  git -C "${TASK_DIR}" push
}

function _task_log(){
  git -C ${TASK_DIR} log
}
function  _task_help(){
/bin/cat << HELP_TEXT
usage: t [COMMAND] [SUFFIX]

COMMAND:
 add  TITLE [detail]
 done id
 del  id
 get  id
 pin [id]
 sync
 log
 tags [id] [+ADD_TAG] [-REMOVE_TAG]
 grep [grep_some_opt]
 help
HELP_TEXT
}

function t(){
  case "$1" in
    "add")  _task_add ${@:2} ;;
    "done") _task_done $2 ;;
    "del")  _task_delete $2 ;;
    "get")  _task_get $2 ;;
    "pin")  _task_pin $2 ;;
    "sync") _task_sync ;;
    "log")  _task_log  ;;
    "tags")  _task_tags ${@:2} ;;
    "help") _task_help ;;
    *)      _task_show $@;;
  esac
}
