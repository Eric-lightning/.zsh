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
    # $B%P%C%/%0%i%&%s%I$G<B9T(B
    zsh_update &! # bash $B$N(B & disown $BAjEv(B
: "Define Function"
    function chpwd() {
        ls -F
    }
: "Note Command"
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
: "zshaddhistory Process"
zshaddhistory() {
    local line=${1%%$'\n'}
    local cmd=${line%% *}
    #$B!!;09T0J2<$N%3%^%s%I$N$_3JG<(B
	test $(echo ${line} |grep -o '\n' |wc -l)  -lt 3
}

# 2020-02-24: cat$B%3%^%s%I$r3HD%;RJL$KJQ99(B
function cat(){
    # $B%R%"%I%-%e%a%s%HH=Dj(B
    if test "`echo $@ | grep 'EOF' | grep '<<' `"  -eq 0
    then
        /bin/cat $@
        return
    else
        # $BJ#?t%U%!%$%k$rH=Dj$7$J$$(B
        if [ $# -eq 1 ];
        then
            # PlainText$B$J%U%!%$%k(B
            if [ "`file $1 | grep 'text'`" ];
            then
                # $B3HD%;RJL$K?6$jJ,$1(B
                case "$1" in
                    *.csv ) column -ts, $1 | nl ;;
                    *.md  ) mdcat $1 | nl ;;
                    *     ) /bin/cat $1 | nl ;;
                esac
            else
                /bin/cat $1 | nl
            fi
        else
            /bin/cat  $@ | nl
        fi
    fi
}

# Peco$B$rMQ$$$?(Blisted Change Directory.
function lscd {
    local dir="$( ls -1A | grep "/" |  peco )"
    if [ ! -z "$dir" ] ; then
        cd "$dir"
    fi
}
# Memo$B=q$-9~$_4X?t(B(alias @write)
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
# $B%U%!%$%k>e$N%a%b$r;2>H(B
declare -g  MEMO=$(/bin/cat ${ZDOTDIR}/MEMO.txt | xargs)
# Show Latest Date
echo "Latest Update -> $(git log | head -n6 | grep 'Date' | sed 's/Date:   //')"

