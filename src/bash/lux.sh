#rainbow
#!/usr/bin/env bash
#===============================================================================
##     Lux CLI  > lux watch 2 > lux.out  2>&1
##       __
##       \ \
##        \ \
##         > \
##        / ^ \
##       /_/ \_\
##
##  QodeParty (c) 2018
#===============================================================================


#-----------------------------------------------------------
## Script
#-----------------------------------------------------------
	readonly script_pid=$$
	readonly script_author="qodeparty"
	readonly script_id="lux"
	readonly script_prefix="LUX"
	readonly script_rc_file=".luxrc"
	readonly script_log_file="$script_id.log"
	readonly script_lic="MIT License"

	script_vers="$(git describe --abbrev=0 --tags)"
	script_build="$(cd $LUX_HOME;git rev-list HEAD --count)"

#-------------------------------------------------------------------------------
# Term
#-------------------------------------------------------------------------------

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
	x=$(tput sgr0)
	sp="   "
	tab=$'\t'
	nl=$'\n'
	blambda="$(sed -n '5,11 p' $BASH_SOURCE)$nl"
	blambda="${blambda//#/}"
	line="$(sed -n '16,16 p' $BASH_SOURCE)$nl"
	bline="$(sed -n '13,13 p' $BASH_SOURCE)$nl"
	diamond='\xE1\x9B\x9C'
	delim='\x01'
	delta="${orange}\xE2\x96\xB3"
	pass="${green}\xE2\x9C\x93"
	fail="${red}\xE2\x9C\x97$red2"
	dots='\xE2\x80\xA6'
	space='\x20'


	#-----------------------
	# Term Helper Functions
	#-----------------------

	function __print(){
		local text color prefix
		text=${1:-}; color=${2:-grey}; prefix=${!3:-};
		[ $opt_quiet -eq 1 ] && [ -n "$text" ] && printf "${prefix}${!color}%b${x}\n" "${text}" 1>&2 || :
	}

	function  info(){ local text=${1:-}; [ $opt_verbose -eq 0 ] || [ $opt_debug -eq 0 ]  && __print "$lambda$text" "blue"; }
	function silly(){ local text=${1:-}; [ $opt_verbose -eq 0 ] && __print "$dots$text" "purple"; }
	function trace(){ local text=${1:-}; [ $opt_verbose -eq 0 ] && __print "$text" "grey2"; }
	function ftrace(){ local text=${1:-}; [ $opt_verbose -eq 0 ] && __print " $text" "fail"; }
	function ptrace(){ local text=${1:-}; [ $opt_verbose -eq 0 ] && __print " $text$x" "pass"; }
	function error(){ local text=${1:-}; __print " $text" "fail";	}
	function  warn(){ local text=${1:-}; __print " $text$x" "delta";	}
	function  pass(){ local text=${1:-}; __print " $text$x" "pass";	}
	function success(){ local text=${1:-}; __print "\n$pass $1 [$2] \n$bline\n\n\n"; }
	function fatal(){ trap - EXIT; __print "\n$fail $1 [$2] \n$bline\n\n\n"; exit 1; }
	function quiet(){ [ -t 1 ] && opt_quiet=${1:-1} || opt_quiet=1; }
	function status(){
		local ret res msg
		ret=$1; res=$2; msg=$3; __print "$res";
		[ $ret -eq 1 ] && fatal "Error: $msg, exiting" "1";
 		return 0
	}

#-------------------------------------------------------------------------------
# Sig / Flow
#-------------------------------------------------------------------------------

	function handle_sigint(){ s="$?"; kill 0; exit $s;	}
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
# Help / Debug
#-------------------------------------------------------------------------------


	function lux_usage_sh(){
		data="$(cat <<-EOF
			${n}${x}${grey}
			Usage: lux cmd [cmd, ...] --info --debug
			try lux help to get a list of commands
			${x}
		EOF
		)";
		__print "$data"
	}


	function lux_usage(){
		local b u y g n t p data;
		b=$blue;y=$orange;g=$green;p=$cyan;
		s=$sp;t=$tab;n=$nl;sc=$script_id;
		data="$(cat <<-EOF
			${n}
			${b}${blambda}${x}
			${b}${line//#/}
			${s}${b}${lambda}Lux Command Line Tool v$script_vers${x}
			${n}
			${s}${b}User NPM Commands${x}${n}
			${s}${p}npm run make${x}  npm wrapper for ${y}lux make${x}
			${s}${p}npm run clean${x} npm wrapper for ${y}lux clean${x}
			${n}
			${s}${b}Dev Commands${x}${n}
			${s}${p}${sc} make   ${x}${t}   generate lux.css and lux.min.css dist
			${s}${p}${sc} clean  ${x}${t}   clean all generated dirs and files
			${s}${p}${sc} link   ${x}${t}   makes lux-cli available on command line
			${s}${p}${sc} unlink ${x}${t}   remove lux-cli from command line
			${s}${p}${sc} rcfile ${x}${t}   regenerate .luxrc file in [${y}$HOME${x}]
			${s}${p}${sc} dev    ${x}${t}   compile styles and copy to dev dist
			${s}${p}${sc} res    ${x}${t}   copy build to dev/res for testing
			${s}${p}${sc} each   ${x}${t}   generate lux sub module files for testing
			${s}${p}${sc} watch ${y}t${x}${t}   watch dev files for changes every [${y}t-seconds${x}]
			${n}
			${s}${b}Info Commands${x}${n}
			${s}${p}${sc} dir    ${x}${t}   output lux home path for use in scripts
			${s}${p}${sc} vars   ${x}${t}   output lux variables
			${s}${p}${sc} mods   ${x}${t}   output lux style mods
			${n}
			${s}${b}Flags${x}${n}
			${s}${p}${sc} --debug${x}${t}   enable debug mode
			${s}${p}${sc} --info ${x}${t}   enable verbose output
			${s}${p}${sc} --lang ${x}${t}   translate class and ids for specified lang
			${s}${p}${sc} --12/16${x}${t}   set grid basis to basis-12 or basis-16
			${n}
			${b}${line//#/}${x}
		EOF
		)";
		__print "$data"
		[ $LUX_INST -eq 1 ] && __print "Lux isnt configured fully" || :
	}


	function lux_vars(){
		local data b w g p y s t n;
		b=$blue;w=$wz;g=$grey2;p=$cyan;y=$orange;
		s=$sp;t=$tab;n=$nl;
		lux_var_refresh
		data="$(cat <<-EOF
			$line
			${s}${yellow}$script_id $script_vers build:$(lux_build_version 'build') www:$(lux_build_version 'www')

			${s}${b}USR_CONF   = ${yellow}${LUX_USER_CONF//$THIS_ROOT/.}

			${s}${b}LUX_ID     = ${w}$LUX_ID
			${s}${b}LUX_RC     = ${w}$LUX_RC
			${s}${b}LUX_HOME   = ${w}${LUX_HOME//$LUX_HOME/.}
			${s}${b}LUX_BIN    = ${w}${LUX_BIN//$LUX_HOME/.}

			${s}${b}LUX_CORE   = ${w}${LUX_CORE//$LUX_HOME/.}
			${s}${b}LUX_VARS   = ${w}${LUX_VARS//$LUX_HOME/.}
			${s}${b}LUX_UTIL   = ${w}${LUX_UTIL//$LUX_HOME/.}
			${s}${b}LUX_DIST   = ${w}${LUX_DIST//$LUX_HOME/.}
			${s}${b}LUX_BUILD  = ${w}${LUX_BUILD//$LUX_HOME/.}

			${s}${b}LUX_RES    = ${w}${LUX_RES//$LUX_HOME/.}
			${s}${b}LUX_RBUILD = ${w}${LUX_RBUILD//$LUX_HOME/.}

			${s}${b}LUX_LIB    = ${w}${LUX_LIB//$LUX_HOME/.}
			${s}${b}LUX_EXT    = ${w}${LUX_EXT//$LUX_HOME/.}
			${s}${b}LUX_DEFS   = ${w}${LUX_DEFS//$LUX_HOME/.}

			${s}${p}THIS_ROOT  = ${w}$THIS_ROOT
			${s}${p}THIS_DIR   = ${w}$THIS_DIR
			${s}${p}BIN_DIR    = ${w}$BIN_DIR

			${s}${b}LUX_WWW    = ${y}$LUX_WWW
			${s}${b}LUX_MODS   = ${y}${LUX_MODS[*]}

			${x}
			$line
		EOF
		)";

		__print "$data"
	}
#-------------------------------------------------------------------------------
# Traps
#-------------------------------------------------------------------------------

	trap handle_sigint INT
	trap handle_sigtstp SIGTSTP
	trap handle_input CONT
	trap fin EXIT

#-------------------------------------------------------------------------------
# Vars
#-------------------------------------------------------------------------------
	opt_quiet=1
	opt_force=1
	opt_verbose=1
	opt_debug=1
	opt_basis=

	CPID="$$"
	BIN_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
	THIS_DIR="$( cd $BIN_DIR && cd ..; pwd -P )"

	LUX_HOME="${LUX_HOME:-$THIS_DIR}"
	THIS_ROOT="$(dirname $LUX_HOME)"

	LUX_RC="$HOME/.luxrc"
	LUX_BIN="$PWD/bin"

	LUX_ID="$script_id"
	LUX_BUILD="$LUX_HOME/build"
	LUX_DIST="$LUX_HOME/dist"
	LUX_RES="$LUX_HOME/www/res"
	LUX_RBUILD="$LUX_RES/build"
	LUX_INST=1

	LUX_LIB="$LUX_HOME/src/lib"
	LUX_EXT="$LUX_LIB/ext"
	LUX_DEFS="$LUX_LIB/defs"

	LUX_CORE="$LUX_HOME/src/styl/lux"
	LUX_VARS="$LUX_HOME/src/styl/vars"
	LUX_UTIL="$LUX_HOME/src/styl/util"

	LUX_WWW="$( cd $THIS_DIR && cd ../lux-www; pwd -P )"

	LUX_META_JS="$LUX_RES/js/lux-meta.js"
	LUX_HELPER_JS="$LUX_RES/js/lux-helper.js"

	LUX_MODS=
	LUX_CLI_VARS=( "build:$script_build" "vers:$script_vers" )
	LUX_USER_CONF=

	OPT_INCLUDE="--include $LUX_EXT --include $LUX_UTIL --include $LUX_VARS --include $LUX_CORE"
	OPT_IMPORT="--import $LUX_UTIL --import $LUX_VARS " #order matters
	OPT_USE="" #update with lux_var_refresh
	OPT_ALL="" #update with lux_var_refresh

	BASH_RC="$HOME/.bashrc"
	[ -f "$HOME/.profile" ] && BASH_PROFILE="$HOME/.profile" || BASH_PROFILE="$HOME/.bash_profile"

	#echo $OPT_USE
  #stylus --use f.js --with='{ k:v }'
  #
#-------------------------------------------------------------------------------
# Utils
#-------------------------------------------------------------------------------
	function in_string(){ [ -z "${2##*$1*}" ]; }

	function in_array(){
		local e
		for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
		return 1
	}

	function pop_array(){
		local match="$1"; shift
		local temp=()
		local array=($@)
		for val in "${array[@]}"; do
		    [[ ! "$val" =~ "$match" ]] && temp+=($val)
		done
		array=("${temp[@]}")
		unset temp
		echo "${array[*]}"
	}

	function sub_dirs(){
		local path=$1
		res=($(find "$path" -type d -printf '%P\n' ))
		echo "${res[*]}"
	}

	function json_maker(){
		vars=( ${LUX_CLI_VARS[@]} ${@})
		str=""
		len=$((${#vars[@]}-1));
		for i in ${!vars[@]}; do
			this="${vars[$i]}"
			this_var="${this#*:}"
			this=${this%%:*}
			printf -v "this" '%s:\"%s\"' "lux_$this" $this_var
			[ $i -lt $len ] && this="${this},"
			str="$str$this"
		done
		printf -v "str" "{%s}" $str #stylus is picky about json format
		echo "$str"

	}

	function add_var(){
		LUX_CLI_VARS+=($@)
	}

#-------------------------------------------------------------------------------
# Lang
#-------------------------------------------------------------------------------

	function lux_trans(){
		:
		#class=>new_class
		#id=>new_d
	}

#-------------------------------------------------------------------------------
# JS Generator
#-------------------------------------------------------------------------------

	#list excludes files starting with _*
	function lux_listfile(){
		var=$1
		path=$2
		ftype=$3
		jsfile="$LUX_HOME/www/res/js/${var}.js"
		list=($(find "$LUX_HOME/www/${path}" -type f -name "*.${ftype}" ! -name '_*.*' -printf '%P\n' ))
		len=$((${#list[@]}-1));

		printf "%s\\n" "////found $(($len+1)) $ftype files" > $jsfile
		printf "%s\\n" "var ${var} = [" >> $jsfile
		for i in ${!list[@]}; do
			this="'${list[$i]}'"
			[ $i -lt $len ] && this="${this},"
			printf "%s\\n" "$this" >> $jsfile
		done
		printf "%s\\n" "];" >> $jsfile

		#info $LUX_HOME
	}

	#deletes subfiles after compiling
	function lux_genlist(){
		info "Compiling file lists..."
		#touch "$LUX_RES/js/js_list.js"
		lux_listfile "js_list" "res/js" "js"
		lux_listfile "css_list" "res/css" "css"
		lux_listfile "html_list" "test" "html"
		lux_make_js
	}

	function lux_js_str(){
		data+=""
		data="$(cat <<-EOF
			//// lux generated javascript file $(date)
			const LUX_VERSION="$script_vers"
			const LUX_BUILD="$script_build"
			const LUX_BASIS="$opt_basis"
			const LUX_THEME="archxray"
			const LUX_TIMESTAMP="$(date +%s)"

			////\n
		EOF
		)";
		echo "$data"
	}


	function lux_make_js(){
		info "Generating lux-meta.js file!"
		path="$LUX_RES/js"
		src="${1:-$LUX_META_JS}"
		js_str="$(lux_js_str)"
		echo -e "$js_str" > ${src}
		cat ${path}/js_list.js ${path}/css_list.js ${path}/html_list.js  >> ${src}
		rm ${path}/*list.js
	}


	function lux_rc_str(){
		data+=""
		data="$(cat <<-EOF
			#!/usr/bin/bash
			${line}
			### lux generated config file $(date)

			export LUX_HOME="$LUX_HOME"
			export LUX_BIN="$LUX_BIN"
			export LUX_RC="$LUX_RC"
			export LUX_INST=0
			export LUX_USER_CONF="$LUX_USER_CONF"

			if [ -n "\$LUX_BIN" ]; then
				[[ ! "\$PATH" =~ "\$LUX_BIN" ]] && export PATH=\$PATH:\$LUX_BIN;
			fi

			alias luxcd="cd \$LUX_HOME; ls -la; [ -t 1 ] && printf \"\n${blue}${lambda}Lux directory.${x}\n\"||:"
			${line}
		EOF
		)";
		echo "$data"
	}



	function lux_make_rc(){
		local show src rc_str
		info "Saving .luxrc file..."
		src="${LUX_RC}"
		rc_str="$(lux_rc_str)"
		echo "$rc_str" > ${src}
		[ -n "$1" ] && echo $line${nl} && cat "$LUX_RC" || :
	}
#-------------------------------------------------------------------------------
# Utils
#-------------------------------------------------------------------------------
	function lux_theme_build(){
		:
	}

	function lux_get_themes(){
		:
	}

#-------------------------------------------------------------------------------
# Utils
#-------------------------------------------------------------------------------

	#OPT_USE="--use $LUX_EXT/cli-vars.js --with {lux_build:\"$script_build\",lux_vers:\"$script_vers\"}"
	function lux_var_refresh(){
		script_vers="$(cd $LUX_HOME;git describe --abbrev=0 --tags)"
		script_build="$(cd $LUX_HOME;git rev-list HEAD --count)"
		www_build="$(cd $LUX_WWW;git rev-list HEAD --count)"

		OPT_USE="--use $LUX_EXT/pre-vars.js --with $(json_maker)"

		[ -f "$LUX_USER_CONF" ] && OPT_USE="$OPT_USE --use $LUX_EXT/pre-config.js" || :

		OPT_ALL="$OPT_USE $OPT_IMPORT $OPT_INCLUDE"
		lux_mods
	}



	function lux_build_version(){
		case $1 in
			www)   echo $(cd $LUX_WWW;git rev-list HEAD --count);;
			build) echo $(cd $LUX_HOME;git rev-list HEAD --count);;
			*)     echo $(cd $LUX_HOME;git describe --abbrev=0 --tags --exact-match);;
		esac
	}

	function lux_version(){
		lux_var_refresh
		printf "$script_vers-$script_build"
	}

	function lux_user_config(){
		local list this i
		opt_debug=0
		if [ "$1" == "rm" ]; then
			warn "Clearing cached user config."
			LUX_USER_CONF=
			lux_make_rc
			return 0
		fi

	  list=( "$LUX_HOME/$1" "./conf/$1" "$HOME/$1" "$LUX_HOME/local-config.json" "./lux-config.json" "$HOME/lux-config.json" "$LUX_USER_CONF")
		for i in ${!list[@]}; do
			this="${list[$i]}"
			if [ -f "$this" ]; then
				 if [ "$this" != "$LUX_USER_CONF" ]; then
				 	 ptrace "New config file at $this"
				 	 LUX_USER_CONF=$this
				 	 lux_make_rc
				 else
				 	 warn "Found existing config file (${this//$LUX_HOME/.})."
				 fi
				 add_var "local_conf:true" "local_conf_path:$this"
				 break
			else
				 ftrace "Cant find a config file at ($this)$dots"
			fi
		done


	}

	function lux_mods(){
		LUX_MODS=($(find "$LUX_CORE" -type d -printf '%P\n' ))
	}


	function lux_res_mods(){
		local i css_path clean this this_file
		lux_mods
		css_path="$LUX_RES/css"
		clean=${1:-1}
		for i in ${!LUX_MODS[@]}; do
			this="${LUX_MODS[$i]}"
			this_file="${LUX_BUILD}/${this}.css"
			that_file="$css_path/lux-${this}.css"
			if [ $clean -eq 0 ]; then
				[ -f "$that_file" ] && rm -rf "$that_file" || :
			else
				[ -f "$this_file" ] && cp "$this_file" "$that_file"  || error "Didnt copy $this"
			fi
		done

		[ $clean -eq 0 ] && info "Cleaning (${LUX_MODS[*]}) styles" || info "Copying (${LUX_MODS[*]}) styles";
	}

	function lux_prep(){
		local src data
		src="$1"
		data+=""
		data="$(cat <<-EOF
			/* $script_id $script_vers | $script_lic (c)2018 $script_author | https://qodeparty.com/get/lux */
		EOF
		)";
		printf '%s\n%s' "$data" "$(cat $src)" > $src
	}



	function lux_clean(){
		info "Cleaning... dist build res/build"
		[ -d $LUX_DIST ]  && rm -rf $LUX_DIST  || :
		[ -d $LUX_BUILD ] && rm -rf $LUX_BUILD || :
		[ -d $LUX_RBUILD ] && rm -rf $LUX_RBUILD || :
		[ -f $LUX_META_JS ] && rm $LUX_META_JS || :
		lux_res_mods 0
	}



	function lux_copy_res(){
		info "Copying build & dist to res..."
		mkdir -p "$LUX_RBUILD"
		[ -d "$LUX_BUILD" ] && cp $LUX_BUILD/*.css $LUX_RBUILD || error "Missing build directory, cant copy res"
		[ -d "$LUX_DIST"  ] && cp $LUX_DIST/*.css  $LUX_RBUILD || error "Missing dist directory, cant copy res"
	}


	function lux_copy_www(){
		local res ret
		info "Copying resouce and generated files to www..."
		if [ -d "$LUX_WWW" ]; then
			mkdir -p $LUX_WWW/res/build
			cp -r $LUX_RES $LUX_WWW
			cp -r $LUX_HOME/www/test $LUX_WWW
			cp -r $LUX_HOME/www/index.html $LUX_WWW
		else
			error "Problem copying build files"
		fi
	}

	function lux_push_www(){
		local res ret build_id www_id
		msg=${1:-gem}
		build_id="$(lux_build_version 'build')";
		#www_id="$(lux_build_version 'build')";
		www_id=$(date +%s)
		msg="auto build $build_id.$www_id :$msg:"
		info "Pushing automated build... <$msg>"
		res=$(cd $LUX_WWW; git add -A .;git commit -m "$msg"; git push origin; ); ret=$?
		__print "$res"
	}



	function lux_parse_styl(){
		local this="$1"
		if [ -n "$this" ]; then
			thisd=$(dirname $this)
			thisb=$(basename $thisd)
			thisf=$(basename $this)
			d="$thisb"
			f="${thisf//\.styl/}" #remove extension
			case $f in
				index)     p="${d}";;
				[a-zA-Z]*) p="${d}-${f}";;
				*) return 1;;
			esac
			echo "$p"
			return 0
		fi
		return 1
	}


	function lux_build_all(){
		info "Building All!"
		lux_mods
		lux_var_refresh
		lux_build_all_mods
		lux_build
		lux_copy_res
		lux_res_mods
		lux_genlist
		lux_copy_www
	}


	function lux_compile(){
		local this thisd thisb thisf d f p buildtype
		this="$1"
		btype="$2"

		lux_mods

		if [ ${#this} -gt 0 ] && [ -f $this ]; then

			thisd=$(dirname $this)
			thisb=$(basename $thisd)
			thisf=$(basename $this)

			buildtype=${btype:-$(lux_buildtype $thisb)} #passed btype is type
			info "Compiling... ($thisb/$thisf) $buildtype"

			case $buildtype in
				main)
						silly "Rebuild main! ($thisb)"
						lux_build
					;;
				only)
						silly "Rebuild this only! ($thisb)"
						lux_build_submod "$this"
						lux_build_mod "debug"
					;;
				each)
						silly "Rebuild each! ($thisb)"
						lux_build_each
						lux_build
					;;
				mod)
						silly "Rebuild mod! ($thisb)"
						lux_build_submod "$this"
						lux_build
					;;
				*)
						silly "Woops!"
					;;
			esac
			lux_copy_res
			lux_res_mods
			lux_genlist
		fi
	}

	function lux_buildtype(){
		local mod mode val
		mod=$1
		mode=$2
		case $mod in
			lux)  		 [ -z "$mode" ] && val='main' || val="$LUX_CORE";;
			util) 		 [ -z "$mode" ] && val='each' || val="$LUX_UTIL";;
			fx|mixins) [ -z "$mode" ] && val='each' || val="$LUX_UTIL/$mod";;
			vars)		   [ -z "$mode" ] && val='each' || val="$LUX_VARS";;
			*) 				 [ -z "$mode" ] && val='mod'  || val="$LUX_CORE/$mod";;
			#TODO:smarter mod check to support watch only
		esac
		echo $val;
	}


	function lux_build_path(){
		[ ! -d $LUX_BUILD ] && mkdir -p $LUX_BUILD
	}


	function lux_build(){
		info "Rebuilding Lux..."
		[ ! -d $LUX_DIST ] && mkdir -p $LUX_DIST
		touch "$LUX_DIST/lux.css" "$LUX_DIST/lux.min.css"

		[ -n "$opt_basis" ] && this_name="lux-$opt_basis" || this_name='lux'

		#FIX COMPILE PATHS
		res=$(stylus $OPT_ALL -r "$LUX_CORE" --out "$LUX_DIST/$this_name.css"); ret=$?;
		status $ret "$res" "Compile Error"

		res=$(stylus -c $OPT_ALL -r "$LUX_CORE" --out "$LUX_DIST/$this_name.min.css");ret=$?;
		status $ret "$res" "Compile Error"

		lux_prep "$LUX_DIST/$this_name.css"
		lux_prep "$LUX_DIST/$this_name.min.css"

		lux_res_mods
		lux_genlist
	}



	function lux_build_each(){
		local files arr d i f j p err;

		info "Rebuilding each..."
		index='index.styl'
		files=();
		lux_mods
		arr=("${LUX_MODS[@]}");

		lux_build_path

		for i in ${!arr[@]}; do

			d="${arr[$i]}"
			this="$LUX_CORE/$d"

			[ -d "$this" ] && files=($(find $this -type f -name *.styl -printf "%f\n" )) || err="Invalid directory ($d)"

			if [ -z "$err" ]; then

				res=$(in_array "$index" "${files[@]}"); ret=$?

				if [ $ret -eq 0 ]; then
					#index in array
					files=($(pop_array "$index" "${files[@]}"))
					files+=("$index"); #move to end
				fi

				info "Files ($orange$d$x$blue)=> ${files[*]}"

				for j in ${!files[@]}; do
					f="${files[$j]//\.styl/}" #remove extension
					[ "$f" = "index" ] && p="${d}" || p="${d}-${f}";
					silly "Rebuilding ($d-$f) ..."
					stylus $OPT_ALL -r "$LUX_CORE/$d/${f}.styl" --out "$LUX_BUILD/${p}.css";ret=$?;
					status $ret "$res" "Compile Error"
				done
			else
				error "$err"
			fi

			err=
		done
		lux_res_mods
		lux_genlist
	}

	function with_basis(){
		local this_name
		[[ "$2" =~ $1 ]] &&	[ -n "$opt_basis" ] && this_name="$2-$opt_basis" || this_name="$2"
		echo $this_name
	}


	function lux_build_submod(){
		local this name res ret;
		this="$1"
		name=$(lux_parse_styl $this); ret=$?

		[[ "$name" =~ "flex" ]]

		if [ $ret -eq 0 ]; then
			lux_build_path
			if in_string '-' "$name"; then
				info "[SUB] Rebuilding Sub... ${name}.css"
				res=$(stylus $OPT_ALL "$this" --out "$LUX_BUILD/${name}.css"); ret=$?;
				status $ret "$res" "Compile Error"

				rm -f "$LUX_RBUILD/${name}.css"
				cp "$LUX_BUILD/${name}.css" "$LUX_RBUILD/${name}.css"

				bname=$(with_basis "flex" "$name")
				if [[ "$bname" != "$name" ]]; then
					cp "$LUX_BUILD/${name}.css" "$LUX_BUILD/${bname}.css"
					cp "$LUX_BUILD/${name}.css" "$LUX_RBUILD/${bname}.css"
				fi

			fi
			lux_build_mod "${name%%\-*}"
		else
			error "Problem building $this";
		fi

	}


	function lux_build_all_mods(){
		for i in ${!LUX_MODS[@]}; do
			this="${LUX_MODS[$i]}"
			lux_build_mod "$this"
		done
	}

	function lux_build_mod(){
		local res ret mod modpath;
		mod="$1"
		res=$(in_array "$mod" "${LUX_MODS[@]}"); ret=$?;


		if [ $ret -eq 0 ]; then
			lux_build_path
			modpath=$(lux_buildtype $mod true)
			if [ -d $modpath ]; then
				info "[MOD] Rebuilding... ${mod}.css"
				res=$(stylus $OPT_ALL "${modpath}/index.styl" --out "$LUX_BUILD/${mod}.css");
				status $ret "$res" "Compile Error"
				rm -f "$LUX_RBUILD/${mod}.css"
				cp "$LUX_BUILD/${mod}.css" "$LUX_RBUILD/${mod}.css"

				bname=$(with_basis "layout" "$mod")
				if [[ "$bname" != "$mod" ]]; then
					cp "$LUX_BUILD/${mod}.css" "$LUX_BUILD/${bname}.css"
					cp "$LUX_BUILD/${mod}.css" "$LUX_RBUILD/${bname}.css"
				fi


			else
				error "Invalid module directory ($mod)";
			fi
		else
			error "Unknown module ($mod)";
		fi
	}



	function lux_watch(){
		local IFS sec chsum1 chsum2 chval res this;
		sec="${1:-5}"
		only="$2"

		#printf -v "diff_time" "%.2f" "-$(echo "$sec/60"|bc -l)" #this isnt working now?
		chsum1=""; opt_debug=0
		__print "\n\n\n$line"
		info "Watching ./src ..." # $diff_time"
		while [[ true ]];
		do

			chsum2=`find $LUX_HOME/src -type f \( -name "*.styl" -o -name "*.css*" -o -name "*.js*" \) -mmin -0.5 -exec md5sum {}  \;`

			if [[ $chsum1 != $chsum2 ]] ; then


				this="${chsum2#*  }" #not sure why this is two spaces!!?
				[ ${#this} -gt 0 ] && trace "Change detected $(basename ${this})...";

				#FIX COMPILE PATHS
				[[ "$this" =~ ".styl" ]] && res=$(lux_compile "$this") && ret=$? || ret=1;
				[[ "$this" =~ ".js" ]]   && res=$(lux_compile "$LUX_UTIL/index.styl") || :
				chsum1=$chsum2

				chval="${chsum2%% *}"

				if [ $ret -eq 0 ]; then
					[ -n "$chval" ] && pass "${green}Watch job ($orange$chval$green) completed!$x$nl$line" || :
				fi

			fi

			sleep 1

		done
	}


	#TODO consolidate the two functions, only differ by find and build commmands for now it works
	function lux_watch_only(){
		local IFS  chsum1 chsum2 chval res this;
		only="$1"
		count=0
		__print "\n\n\n$line"
		info "Watching ./src $only ..."
		chsum1=""; opt_debug=0
		if [ -n "$only" ]; then
			while [[ true ]];
			do


				chsum2=`find $LUX_HOME/src/styl -type f \( -name "$only" \) -mmin -1 -exec md5sum {}  \;`
				if [[ $chsum1 != $chsum2 ]] ; then
					this="${chsum2#*  }" #not sure why this is two spaces!!?

					[[ "$this" =~ ".styl" ]] && res=$(lux_compile "$this" "only") && ret=$? || ret=1;

					chsum1=$chsum2
					chval="${chsum2%% *}"

					if [ $ret -eq 0 ]; then
						count=$(($count+1));
						[ -n "$chval" ] && success "Watch job ($count) completed!" "$orange$chval$green" || :
					else
						error "Job cancelled due to error! Restarting..."
						info "Watching ./src $only [$count]\n\n\n"
					fi
				fi
			sleep 1

			done
		else
			fail "Watch failed, missing filename"
		fi
	}

#-------------------------------------------------------------------------------
# Utils
#-------------------------------------------------------------------------------
	function template_vars(){
		local found res ret buf
		buf=($(find $LUX_HOME -type f \( -name "*.html" -o -name "*.tpl*" \))); ret=$?;
		for this in ${buf[@]}; do
			vars=($(grep --color=always "$@" -o -P "%.+%" $this))
			#do stuff but im lazy
		done
	}


	function file_marker(){
		local delim dst dend mode lbl
		mode="$1"
		lbl="$2"
		delim="$3"
		dst='#'; dend='#';
		[ "$delim" = "js" ] && dst='\/\*'; dend='\*\/' || :
		if [ "$mode" = "str" ]; then
			str="${dst}----${block_lbl}:str----${dend}"
		else
			str="${dst}----${block_lbl}:end----${dend}"
		fi
		# __print "$str"
		echo "$str"
	}


	function file_add_block(){
		local newval src block_lbl match_st match_end data res ret
		newval="$1"; src="$2"; block_lbl="$3"; delim="$4"; ret=1;
		match_st=$(file_marker "str" "${block_lbl}" "${delim}" )
		match_end=$(file_marker "end" "${block_lbl}" "${delim}" )

		#check if block already exists...
		res=$(file_find_block "$src" "$block_lbl" "${delim}" )
		ret=$?

		if [ $ret -gt 0 ]; then #nomatch
			data="$(cat <<-EOF
				${match_st}
				#added:$(date +%d-%m-%Y" "%H:%M:%S)
				${newval}
				${match_end}
			EOF
			)";
			echo "$data" >> $src
			ret=$?
		fi
		return $ret
	}



	function file_del_block(){
		local src block_lbl match_st match_end data res ret dst dend
		src="$1"
		block_lbl="$2"
		delim="$3";

		match_st=$(file_marker "str" "${block_lbl}" "${delim}" )
		match_end=$(file_marker "end" "${block_lbl}" "${delim}" )

		sed -i.bak "/${match_st}/,/${match_end}/d" "$src" #this works on ubuntu
		ret=$?
		#make sure it was removed
		res=$(file_find_block "$src" "$block_lbl" "${delim}" )
		ret=$?

		#flip ret, if notfound then success
		[ $ret -gt 0 ] && ret=0 || ret=1

		#log "$(res $ret) Cannot Find? (Delete Complete)"
		rm -f "${src}.bak"
		return $ret
	}


	function file_find_block(){
		local src block_lbl match_st match_end data res ret
		src="$1"; block_lbl="$2"; delim="$3"; ret=1
		match_st=$(file_marker "str" "${block_lbl}" "${delim}")
		match_end=$(file_marker "end" "${block_lbl}" "${delim}")
		res=$(sed -n "/${match_st}/,/${match_end}/p" "$src")
		[ -z "$res" ] && ret=1 || ret=0;
		echo "$res"
		return $ret;
	}


	function profile_link(){
		local ret res data
		[ ! -f "$LUX_RC" ] && lux_make_rc || :
		if [ -f "$LUX_RC" ]; then
			src="$BASH_PROFILE" #link to bashrc so vars are available to subshells?
			[ ! -f "$src" ] && touch "$src"
			lbl="$script_id"
			res=$(file_find_block "$src" "$lbl" ); ret=$?
			if [ $ret -eq 1 ]; then
				data="$(cat <<-EOF
					${tab} if [ -f "$LUX_RC" ] ; then
					${tab}   source "$LUX_RC"
					${tab} else
					${tab}   [ -t 1 ] && echo "\$(tput setaf 214).luxrc is missing, lux link or unlink to fix ${x}" ||:
					${tab} fi
				EOF
				)";
				res=$(file_add_block "$data" "$src" "$lbl" )
				ret=$?
			fi
		else
			error "Profile doesnt exist @ $BASH_PROFILE"
		fi

	}


	function profile_unlink(){
		local ret res data src lbl
		src="$BASH_RC"
		lbl="$LUX_ID"
		[ -f "$LUX_RC" ] && rm -f "$LUX_RC"
		res=$(file_del_block "$src" "$lbl" )
		ret=$?
		[ $ret -eq 0 ] && __print ".luxrc removed from $BASH_RC" "red" ||:
	}



#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------
	function __dispatch(){
		#log_debug "[fx:$FUNCNAME] args:$#"
		local call ret
		skip=1

		#call=$1; shift

		[ -f "$LUX_RC" ] && source $LUX_RC

		if [ -f "$LUX_USER_CONF" ]; then
			add_var "local_conf:true" "local_conf_path:$LUX_USER_CONF"
		fi

		lux_var_refresh

		for call in "$@"; do
			#echo "$# $call"
			shift
			if [ $skip -eq 0 ]; then
				skip=1
				#echo "skipping $call"
				continue
			fi
			case $call in
				all)
					lux_build_all;;
				json)
					add_var "test:1" "eat:candy"
					lux_var_refresh
					json_maker "nile:queen"
					#echo "$OPT_USE"
					shift;;
				help) lux_usage;;
				vars) lux_vars;;
				mods) opt_debug=0; info "=> ${LUX_MODS[*]}";;
				rmods) opt_debug=0; lux_res_mods;;
				dir)  quiet 0; echo "$LUX_HOME";;
				dev)
					lux_build_each
					lux_copy_res
					;;
				link)   profile_link;   ret=$?;;
				unlink) profile_unlink; ret=$?;;
				rc*)    lux_make_rc 1; ret=$?;;
				each)   lux_build_each;;
				res)    lux_copy_res;;
				build|make)
					case $1 in
						each) shift; lux_build_each;;
						all)  shift; lux_build_all;;
						"")   shift; lux_build;;
						*)    lux_build_mod "$1";;
					esac
					break;
				;;
				find)
					IFS=
					flags="-HiREl"
					case $1 in
						files) shift; res=$(grep -HiREl --color=always "$1" .);;
						html) shift; res=$(grep -HiRE --include=\*.html --color=always "$1" .);;
						styl) shift; res=$(grep -HiRE --include=\*.styl --color=always "$1" .);;
						*) res=$(grep -HiREn --color=always "$1" .);;
					esac
					#query=`find $LUX_HOME/src -type f \( -name "*.styl" -o -name "*.css*" -o -name "*.js*" \) \;`
					#res=$(grep ${flags} --include= --color=always "$1" .)
					echo "$res"
					break;
					;;
				clean) lux_clean ;;
				list) lux_genlist	;;
				watch) lux_watch "$1"; shift;;
				only) lux_watch_only "$1"; shift;;
				www)
					opt_debug=0;
					case $1 in
						push) shift; lux_copy_www; lux_push_www "$1";;
						*)    lux_copy_www "$1";;
					esac
					break;
					;;
				tpl) template_vars;;
				vers*)
					opt_quiet=0
					lux_version
					exit 0
				;;
				skip) break;;
				--*)
					case $call in
						--conf*)
							lux_user_config $1
							skip=0
							;;
						--local*)
							lux_user_config 'local-conf.json'
							;;
						*) : ;;
					esac
				;;
				*)
					if [ ! -z "$call" ]; then
						fatal "Invalid command" $call;
						lux_usage;  ret=1
					fi
				;;
			esac
		done

		return $ret
	}


	function main(){
		__dispatch "$@"
	}


#-------------------------------------------------------------------------------
# Driver
#-------------------------------------------------------------------------------
if [ "$0" = "-bash" ]; then
	:
else

	args=("${@}")

	[[ "${@}" =~ "--debug" ]] && opt_debug=0 || :
	[[ "${@}" =~ "--info"  ]] && opt_verbose=0 || :
	[[ "${@}" =~ "--quiet" ]] && opt_quiet=0 || :
	[[ "${@}" =~ "--force" ]] && opt_force=0 || :
	[[ "${@}" =~ "--12"    ]] && add_var "basis:12" && opt_basis=12 || :
	[[ "${@}" =~ "--16"    ]] && add_var "basis:16" && opt_basis=16 || :
	[[ "${@}" =~ "--vers"  ]] && opt_quiet=0 && lux_version && exit 0 || :
	#[ -t 1 ] && [ $opt_force -eq 0 ] && opt_quiet=1 ||:

	#args=( "${args[@]/\-*}" ); #delete anything that looks like an option

	main "${args[@]}";ret=$?
fi
