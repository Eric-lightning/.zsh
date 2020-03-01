: "PROMPT"
# 20200301: 
# - /etc/zshrc $B$K(BPROMPT$BJQ?t$,Dj5A$5$l$F$$$k!#(B
# - ${ZDOTDIR}/.zshenv $B$N$"$H$K(B /etc/zshrc$B$rFI$_9~$`(B
# - $B$h$C$F!"(B.zshenv $B$@$H>e=q$-$5$l$F$7$^$&;v>]!J(BCentOS 7)
PROMPT="%K{black}%F{3}${HOST} %F{cyan}<"$IP_ADDRESSES"> "'${vcs_info_msg_0_}'"%F{reset}%K{reset}
%K{0}%F{7} [%~] %#%K{reset}%F{reset} "
RPROMPT="%K{black}%F{red}"'${MEMO}'"%F{reset}%K{reset}"
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
    if [ $# -eq 0 ]
    then
        # $B6u$G;XDj$7$?$i%j%;%C%H(B
        unset MEMO
        return
    else
        for text in $@
        do
            #$BF,$K(B-$B$,$D$$$F$?$i:o=|!#(B
            if test $(echo "$text" | grep '^-' )
            then
                local keywd=`echo  $text | sed -e 's/^-//'`
                declare -g MEMO=`echo $MEMO | sed "s/\s$keywd/ /" | sed "s/${keywd}\s//"`
                echo "memo buffer removed: $keywd"
            else
                local exist_flag=0
                for i in $(echo $MEMO | xargs)
                do
                    test "$i" = "$text" && exist_flag=1 && break
                done
                if test $exist_flag -eq 0
                then
                    declare -g MEMO="${MEMO} ${text}"
                    echo "memo buffer added: ${text}"
                else
                    echo "memo buffer exist: ${text}"
                fi
            fi
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
    if test "`echo $@ | grep 'EOF' | grep '<<' `"  -eq 0
    then
        # $B%R%"%I%-%e%a%s%HBP:v(B
        /bin/cat $@
        return
    else
        if [ $# -eq 1 ];
        then
            if [ "`file $1 | grep 'text'`" ];
            then
                case "$1" in
                    *.csv ) column -ts, $1 | nl ;;
                    *.md ) mdcat $1 | nl ;;
                    *) /bin/cat $1 | nl ;;
                esac
            else
                echo "Type 1"
                /bin/cat $1 | nl
            fi
        else
            echo "Type 3"
            /bin/cat  $@ | nl
        fi
    fi
}

function lscd {
    local dir="$( ls -1A | grep "/" |  peco )"
    if [ ! -z "$dir" ] ; then
        cd "$dir"
    fi
}
function memo_write(){
    if test "$MEMO" = ""
    then
        # $BJQ?t$,6u$J$i$P!"%j%;%C%H$9$k!#(B
        echo '' > ${ZDOTDIR}/MEMO.txt
    else
        for i in $(echo $MEMO | xargs)
        do
            local exist_flag=0
            # $BB8:_%A%'%C%/(B
            for x in $(/bin/cat ${ZDOTDIR}/MEMO.txt | xargs)
            do
                if test "$i" = "$x"
                then
                    exist_flag=1
                fi
            done
            if test $exist_flag -eq 0
            then #$BB8:_$7$J$$$J$i$P(B
                 echo "memo: add - $i"
                 echo $i >> ${ZDOTDIR}/MEMO.txt
            else
                echo "memo: exist - $i"
            fi
        done
        # $B%U%!%$%k$K$"$k$,!"JQ?t$KB8:_$7$J$$J8;zNs$r:o=|(B
        local MEMO_LIST=`echo $MEMO | tr ' ' '\n'`
        for i in $(/bin/cat ${ZDOTDIR}/MEMO.txt | xargs)
        do
            # $B%U%!%$%k$N(BMEMO_LIST$B$r(BGrep($B40A40lCW!K$7$F!"40A40lCW$7$J$1$l$P!J(BRevirse) Grep$B$G9T:o=|(B
            if test ! "$( echo $MEMO_LIST | grep -x $i)"
            then
                grep -v "^${i}" ${ZDOTDIR}/MEMO.txt | tee ${ZDOTDIR}/MEMO.txt > /dev/null
                test "$?" -eq 0  && echo "memo: removed - $i"
            fi
        done
    fi
}
alias @write='memo_write'
# For Hyper Terminal
function title() { echo -e "\033]0;${1:?please specify a title}\007" ; }
function @reload(){
  export  MEMO=$(/bin/cat ${ZDOTDIR}/MEMO.txt | xargs)
}
trap "memo_write" EXIT INT
declare -g  MEMO=$(/bin/cat ${ZDOTDIR}/MEMO.txt | xargs)

