#!/usr/bin/env bash

	LUX_HOME="${LUX_HOME:-$THIS_DIR}"
	THIS_ROOT="$(dirname $LUX_HOME)"

	LUX_RC="$HOME/.luxrc"
	LUX_BIN="$BIN_DIR"

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

	LUX_SEARCH_PATH=

	LUX_WWW= #$( cd $THIS_DIR && cd ../lux-www; pwd -P )
	LUX_CLI=
	LUX_DEV=
	LUX_CSS=

	LUX_META_JS="$LUX_RES/js/lux-meta.js"

	#LUX_HELPER_JS="$LUX_RES/js/lux-helper.js"

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