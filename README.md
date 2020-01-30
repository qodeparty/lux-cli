# lux-cli
Cli Binary for Lux Dev/Dist

Migrating binary from lux => lux-cli

Supports only Bash 3.x ATM (Linux/Mac OSX)

Work on providing Windows support via gulp/pack later


shar -z -s qodeparty@moocow config.sh > config.shar



logo=$(sed -n '3,8 p' $BASH_SOURCE)
  logo=${logo//#/ };

  printf "$logo$nl"


  sed_block(){
    local id="$1" pre="^[#]+[=]+" post=".*" str end;
    str="${pre}${id}[:]?[^\!=\-]*\!${post}";
    end="${pre}\!${id}[:]?[^\!=\-]*${post}";
    sed -rn "1,/${str}/d;/${end}/q;p" $BASH_SOURCE | tr -d '#';
  }


  block_parse(){
    local lbl="$1" IFS res;
    res=$(sed_block $lbl);
    if [ ${#res} -gt 0 ]; then
      while IFS= read -r line; do
        [[ $lbl =~ doc*|inf* ]] && line=$(eval "echo -e \"$line\"");
        echo "$line"
      done  <<< "$res";
    else
      return 1;
    fi
  }

  block_parse 'doc:help';
#====================================doc:help!==================================
#
#  \n\t${b}hellow --option [<n>ame] [<p>ath]${x}
#
#  \t${w}Find:${x}
#
#  \t     --hi   <?>     ${b}Say Hello!${x}
#  \t     --no   <p>     ${b}Dont Say Hello!${x}
#  \t     --kk   <p>     ${b}Thumbs up!${x}
#
#=================================!doc:help=====================================