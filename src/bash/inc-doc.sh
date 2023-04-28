#rainbow
#!/usr/bin/env bash

	function lux_usage_sh(){
		local data
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
		local b y g n t p data;
		b=$blue;y=$orange;g=$green;p=$cyan;v=$purple;
		s=$sp;t=$tab;n=$nl;sc='';

		if [[ "$script_entry" =~ "luxbin" ]]; then
			block_print 'doc:help' "$0" "$BIN_DIR/doc.txt";
		else
			block_print 'doc:help' "$0"; 
		fi

		[ $LUX_INST -eq 1 ] && __print "${delta}Lux isnt configured fully" || :
	}


	function lux_vars(){
		local data b w g p y s t n;
		b=$blue;w=$wz;g=$grey2;p=$cyan;y=$orange;
		s=$sp;s2=$sp$sp;t=$tab;n=$nl;
		#lux_var_refresh
		lux_var_refresh
		data="$(cat <<-EOF
			$line


			${s2}${b}USR_CONF   = ${yellow}${LUX_USER_CONF//$THIS_ROOT/.}

			${s2}${b}LUX_ID     = ${w}$LUX_ID
			${s2}${b}LUX_RC     = ${w}$LUX_RC

			${s2}${p}THIS_ROOT  = ${w}$THIS_ROOT
			${s2}${p}THIS_DIR   = ${w}$THIS_DIR
			${s2}${p}BIN_DIR    = ${w}$BIN_DIR

			${s2}${b}LUX_MODS   = ${y}${LUX_MODS[*]}${x}

			${s2}${b}BASH_USR_BIN= ${y}${BASH_USR_BIN}${x}

			${s}---------------------------------
			${s}Repos

			${s2}${b}LUX_SEARCH_PATH = ${w}$LUX_SEARCH_PATH

			${s2}${b}LUX_WWW    = ${y}$LUX_WWW
			${s2}${b}LUX_CLI    = ${y}$LUX_CLI
			${s2}${b}LUX_DEV    = ${y}$LUX_DEV
			${s2}${b}LUX_CSS    = ${y}$LUX_CSS${x}

			${s}---------------------------------
			${s}Main

			${s2}${b}LUX_HOME   = ${w}${LUX_HOME}

			${s}---------------------------------
			${s}Derived

			${s2}${b}LUX_BIN    = ${w}${LUX_BIN//$LUX_HOME/.}

			${s2}${b}LUX_CORE   = ${w}${LUX_CORE//$LUX_HOME/.}
			${s2}${b}LUX_VARS   = ${w}${LUX_VARS//$LUX_HOME/.}
			${s2}${b}LUX_UTIL   = ${w}${LUX_UTIL//$LUX_HOME/.}
			${s2}${b}LUX_DIST   = ${w}${LUX_DIST//$LUX_HOME/.}
			${s2}${b}LUX_BUILD  = ${w}${LUX_BUILD//$LUX_HOME/.}

			${s2}${b}LUX_RES    = ${w}${LUX_RES//$LUX_HOME/.}
			${s2}${b}LUX_RBUILD = ${w}${LUX_RBUILD//$LUX_HOME/.}

			${s2}${b}LUX_LIB    = ${w}${LUX_LIB//$LUX_HOME/.}
			${s2}${b}LUX_EXT    = ${w}${LUX_EXT//$LUX_HOME/.}
			${s2}${b}LUX_DEFS   = ${w}${LUX_DEFS//$LUX_HOME/.}

			${s}#--------------------------------

			${x}
			$line
		EOF
		)";

		__print "$data"
	}


	#			${s}${yellow}$script_id $script_vers build:$(lux_build_version 'build') www:$(lux_build_version 'www')
