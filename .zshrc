: "Check Update"
	function zsh_update() {
		cd $HOME/.zsh
        OLD_ZSH_CONF_VERSION=$(git describe --abbrev=0 --tags)
        git pull origin > /dev/null 2>&1
        ZSH_CONF_VERSION=$(git describe --abbrev=0 --tags)
        if [[ $? -eq 0 ]]
        then
            if [ $OLD_ZSH_CONF_VERSION != $ZSH_CONF_VERSION ]
            then
                echo "ZSH UPDATED - NEW_VERSION: $ZSH_CONF_VERSION (Plz Reload Settings)"
            fi
        fi
    }
    zsh_update &! # bash $B$N(B & disown $BAjEv(B
: "Define Function"
cd $HOME
function chpwd() {
    ls -F
} # auto display list directory after changed director

function @(){
    if [ $# -eq 0 ];
    then
        unset MEMO
        return
    else
        for text in $@
        do
            declare -g MEMO="${MEMO} ${text}"
        done
    fi
}

zshaddhistory() {
    local line=${1%%$'\n'}
    local cmd=${line%% *}
	test $(echo $line|grep -o '\n'|wc -l) -lt 3

    # $B0J2<$N>r7o$r$9$Y$FK~$?$9$b$N$@$1$r%R%9%H%j$KDI2C$9$k(B
#    [[ ${#line} -ge 5
#       && ${cmd} != (l|l[sal])
#       && ${cmd} != (c|cd)
#       && ${cmd} != (m|man)
#   ]]
}

# 2020-02-24: cat$B%3%^%s%I$r3HD%;RJL$KJQ99(B
function cat(){
    if [ $# -eq 1 ];
    then
        if [ "`file $1 | grep 'text'`" ];
        then
            case "$1" in
                *.csv ) column -ts, $1 ;;
                *.md ) mdcat $1 ;;
                *) /bin/cat $1 ;;
            esac
        else
            echo "code: 2"
            /bin/cat $1
        fi
    else
       /bin/cat $@
    fi
}

function memo_write(){
    if test "$MEMO" = ""
    then
        echo '' > ${ZDOTDIR}/MEMO.txt
    else
        for i in $(echo $MEMO | xargs)
        do
            local exist_flag=0
            for x in $(cat ${ZDOTDIR}/MEMO.txt | xargs)
            do
                if test "$i" = "$x"
                then
                    exist_flag=1
                fi
            done
            if test $exist_flag -eq 0
            then
                 echo "memo: add - $i"
                 echo $i >> ${ZDOTDIR}/MEMO.txt
            else
                echo "memo: exist - $i"
            fi
        done
    fi
}
alias @write='memo_write'

function @reload(){
  export  MEMO=$(cat ${ZDOTDIR}/MEMO.txt | xargs)
}
trap "memo_write" EXIT INT
declare -g  MEMO=$(cat ${ZDOTDIR}/MEMO.txt | xargs)

