#!/usr/bin/env bash
#-------------------------------------------------------------------------------
#===============================================================================

dtrace "loading ${BASH_SOURCE[0]}"

#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------
	function dispatch(){
		#log_debug "[fx:$FUNCNAME] args:$#"
		local call ret c= c2= cmd_str= arg

		# if [ -f "$LUX_USER_CONF" ]; then
		# 	add_var "local_conf:true" "local_conf_path:$LUX_USER_CONF"
		# fi
		lux_load_rc

		#set with --local
		if [ $opt_local_conf -eq 0 ]; then
			lux_user_config 'local-conf.json'
		fi

		if [ -f "$LUX_USER_CONF" ]; then
			add_var "local_conf:true" "conf_path:$LUX_USER_CONF"
		fi

		lux_var_refresh
		call="$1"

		dtrace "call($call)"

		case $call in
			ch*)      opt_skip_input=0; c='lux_checkup'; ret=$?;;
			rep*)     opt_skip_input=1; c='lux_repair'; ret=$?;;
			fc|fclean)dev_fast_clean;;
			dist)     c='lux_make_cli';;
			pub*)     c='lux_publish_dist';;
			cphome)   c='deploy_dist_home';;
			cgen)     ;;
			gen)      ;;
			link)     c='profile_link';;
			unlink)   c='profile_unlink';;
			find)     c='lux_search_files';;
			rc)       c='lux_dump_rc';;
			rrc*)     c='lux_make_rc';;
			json) 		c='json_maker_run';;
			home)     c='echo_var';arg="$LUX_HOME";;
			bin)      c='echo_var';arg="$LUX_BIN";;
			cli)      c='echo_var';arg="$LUX_CLI";;
			mods)     c='echo_var';arg="${LUX_MODS[*]}";;
			self)     c='echo_var';arg="$0";;
			here)     c='echo_var';arg="$BIN_DIR";;
			rmods)    c='lux_res_mods';;
			list)     c='lux_genlist';;
			lconf)    c='lux_user_config' arg='local-conf.json';;
			watch)    c='lux_watch' arg="$2";;
			only)     c='lux_watch_only' arg="$2";;
			fxq) 			c='list_fx'; arg="$2";;
			clean)    c='lux_clean';;
			build|make)
				case $1 in
					each) c='lux_build_each';;
					all)  c='lux_build_all';;
					"")   c='lux_build';;
					*)    c='lux_build_mod'; arg="$2";;
				esac
				break;
			;;
			www)    c='lux_make_www';;
			a|all)  c='lux_build_all';;
			each)   c='lux_build_each';;
			res)    c='lux_copy_res';;
			vars)   c='lux_vars';;
			gvers)  c='lux_gen_version';;
			vers*)  opt_quiet=0; c='lux_version';;
			\?|help) c='lux_usage';;
			\.)     break;;
			--*)    break;;
			*)
				if [ ! -z "$call" ]; then
					err="Invalid command ($call)";
					c='lux_usage';
				fi
			;;
		esac


    cmd_str+=$c;

    [ -n "$arg" ] && cmd_str+=" $arg";

    dtrace "CMD:$cmd_str"
    #stderr "fx=> $cmd_str";
    $cmd_str;ret=$?;
    [ -n "$err" ] && return 1;
    return $ret;
	}

	dtrace "Basis $opt_basis"

