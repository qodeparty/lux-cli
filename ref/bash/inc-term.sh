#!/usr/bin/env bash
##------------------------------------------------------------------------------
##==============================================================================

    red=$(tput setaf 1)
    red2=$(tput setaf 9)
    yellow=$(tput setaf 11)
    orange=$(tput setaf 214)
    green=$(tput setaf 2)
    blue=$(tput setaf 12)
    cyan=$(tput setaf 123)
    purple=$(tput setaf 213)
    grey=$(tput setaf 244)
    grey2=$(tput setaf 240)
    w=$(tput setaf 15)
    wz=$(tput setaf 248)
    lambda="\xCE\xBB"
    line="$(sed -n '2,2 p' $BASH_SOURCE)$nl"
    bline="$(sed -n '3,3 p' $BASH_SOURCE)$nl"
    x=$(tput sgr0)
    sp="   "
    tab=$'\t'
    nl=$'\n'
    diamond='\xE1\x9B\x9C'
    delim='\x01'
    delta="${orange}\xE2\x96\xB3"
    pass="${green}\xE2\x9C\x93"
    fail="${red}\xE2\x9C\x97$red2"
    dots='\xE2\x80\xA6'
    space='\x20'

    eol="$(tput el)"
    eos="$(tput ed)"
    cll="$(tput cuu 1 && tput el)"
    bld="$(tput bold)"
    rvm="$(tput rev)"

#-------------------------------------------------------------------------------
# Init Vars
#-------------------------------------------------------------------------------

    opt_quiet=1
    opt_force=1
    opt_verbose=1
    opt_silly=1
    opt_debug=1
    opt_local_conf=1
    opt_basis=
    opt_dump_col="$orange"
    opt_dump=1

    [[ "${@}" =~ "--debug" ]] && opt_debug=0 || :
    [[ "${@}" =~ "--info"  ]] && opt_verbose=0 || :
    [[ "${@}" =~ "--silly" ]] && opt_silly=0 || :
    [[ "${@}" =~ "--quiet" ]] && opt_quiet=0 || :
    [[ "${@}" =~ "--force" ]] && opt_force=0 || :
    [[ "${@}" =~ "--dev"   ]] && opt_dev_mode=0 || :
    [[ "${@}" =~ "--local" ]] && opt_local_conf=0 || :
    [[ "${@}" =~ "--dump"  ]] && opt_dump=0  || :


    [[ "${@}" =~ --?(b|basis)[=:]([0-9]+) ]]; #opt_debug=$?;

    opt_basis="${BASH_REMATCH[2]:-16}";

    [[ "${@}" =~ "--12"  ]] && opt_basis=12 || :;
    [[ "${@}" =~ "--16"  ]] && opt_basis=16 || :;

    if [ $opt_quiet   -eq 1 ]; then
       [ $opt_silly   -eq 0 ] && opt_verbose=0
       [ $opt_verbose -eq 0 ] && opt_debug=0
    fi

    __buf_list=1
#-------------------------------------------------------------------------------
# Sig / Flow
#-------------------------------------------------------------------------------

    function handle_sigint(){ s="$?"; kill 0; exit $s;  }
    function handle_sigtstp(){ kill -s SIGSTOP $$; }
    function handle_input(){ [ -t 0 ] && stty -echo -icanon time 0 min 0; }
    function cleanup(){ [ -t 0 ] && stty sane; }
    function fin(){
      local E="$?"
      cleanup
      #[ $opt_force -eq 0 ] && lux_usage || echo "$opt_force"
      [ $E -eq 0 ] && __print "${pass} ${green}${1:-Done}.${x}\n\n" \
                   || __print "$red$fail ${1:-${err:-Cancelled}}.${x}\n\n"
    }

#-------------------------------------------------------------------------------
# Traps
#-------------------------------------------------------------------------------

    trap handle_sigint INT
    trap handle_sigtstp SIGTSTP
    trap handle_input CONT
    trap fin EXIT

#-------------------------------------------------------------------------------
# Printers
#-------------------------------------------------------------------------------

    function __print(){
      local text color prefix
      text=${1:-}; color=${2:-grey}; prefix=${!3:-};
      [ $opt_quiet -eq 1 ] && [ -n "$text" ] && printf "${prefix}${!color}%b${x}\n" "${text}" 1>&2 || :
    }

    function __printf(){
      local text color prefix
      text=${1:-}; color=${2:-grey}; prefix=${!3:-};
      [ $opt_quiet -eq 1 ] && [ -n "$text" ] && printf "${prefix}${!color}%b${x}" "${text}" 1>&2 || :
    }


    function    info(){ local text=${1:-}; [ $opt_debug   -eq 0 ] && __print "$lambda$text" "blue"; }
    function   silly(){ local text=${1:-}; [ $opt_silly   -eq 0 ] && __print "$dots$text" "purple"; }
    function   trace(){ local text=${1:-}; [ $opt_verbose -eq 0 ] && __print "$text"   "grey2"; }
    function  ftrace(){ local text=${1:-}; [ $opt_verbose -eq 0 ] && __print " $text"   "fail"; }
    function  ptrace(){ local text=${1:-}; [ $opt_verbose -eq 0 ] && __print " $text$x" "pass"; }
    function  wtrace(){ local text=${1:-}; [ $opt_verbose -eq 0 ] && __print " $text$x" "delta"; }

    function  dtrace(){ local text=${1:-}; [ $opt_dev_mode -eq 0 ] && __print "##[ $text ]##"   "purple"; }

    function   error(){ local text=${1:-}; __print " $text" "fail"; }
    function    warn(){ local text=${1:-}; __print " $text$x" "delta";  }
    function    pass(){ local text=${1:-}; __print " $text$x" "pass"; }
    function success(){ local text=${1:-}; __print "\n$pass $1 [$2] \n$bline\n\n\n"; }
    function   fatal(){ trap - EXIT; __print "\n$fail $1 [$2] \n$bline\n\n\n"; exit 1; }
    function   quiet(){ [ -t 1 ] && opt_quiet=${1:-1} || opt_quiet=1; }
    function  status(){
      local ret res msg
      ret=$1; res=$2; msg=$3; __print "$res";
      [ $ret -eq 1 ] && fatal "Error: $msg, exiting" "1";
      return 0
    }

  function confirm() {
    local ret;ret=1
    __printf "${1}? > " "white" #:-Are you sure ?
    while read -r -n 1 -s answer; do
      #info "try answer..."
      if [[ $answer = [YyNn10tf+\-q] ]]; then
        [[ $answer = [Yyt1+] ]] && __printf "${bld}${green}yes${x}" && ret=0 || :
        [[ $answer = [Nnf0\-] ]] && __printf "${bld}${red}no${x}" && ret=1 || :
        [[ $answer = [q] ]] && __printf "\n" && exit 1 || :
        break
      fi
    done
    __printf "\n"
    return $ret
  }


  function prompt_path(){
    local res ret next
    prompt="$1"
    prompt_sure="$2"
    default="$3"

    #fancy -> set defualt and escape prompt shell values and chars
    prompt=$(eval echo "$prompt")

    while [[ -z "$next" ]]; do
      read -p "$prompt? > ${bld}${green}" __NEXT_DIR
      res=$(eval echo $__NEXT_DIR)
      [ -z "$res" ] && res="$default"
      if [ -n "$res" ]; then

        if [ "$res" = '?' ]; then
          echo "cancelled"
          return 1
        fi

        if confirm "${x}${prompt_sure} [ ${blue}$res${x} ] (y/n)"; then
          if [ ! -d "$res" ]; then
            error "Couldn't find the directory ($res). Try Again. Or '?' to cancel."
          else
            next=1
          fi
        fi
      else
        warn "Invalid Entry! Try Again."
      fi
    done
    echo "$res"
  }


  function dump(){
    local len arr i this flag newl
    arr=("${@}"); len=${#arr[@]}
    [ $__buf_list -eq 0 ] && flag="\r" &&  newl="$eol" || newl="\n"
    if [ $len -gt 0 ]; then
      handle_input
      for i in ${!arr[@]}; do
        this="${arr[$i]}"
        [ -n "$this" ] && printf -v "out" "$flag$opt_dump_col$dots(%02d of %02d) $this $x" "$i" "$len"
        trace "$out"
        sleep 0.05
      done
      cleanup
      printf -v "out" "$flag$green$pass (%02d of %02d) Read. $x$eol" "$len" "$len"
      trace "$out"
    fi
  }

  #__print "$BASH_SOURCE from term $DIR yay $(dirname ${BASH_SOURCE[1]} && pwd) ||"

  [ $opt_dev_mode -eq 0 ] && dtrace "DEV MODE ENABLED"