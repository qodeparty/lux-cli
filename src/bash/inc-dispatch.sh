#!/usr/bin/env bash
#-------------------------------------------------------------------------------
#===============================================================================


#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------
	function dispatch(){
		#log_debug "[fx:$FUNCNAME] args:$#"
		local call ret
		skip=1

		# if [ -f "$LUX_USER_CONF" ]; then
		# 	add_var "local_conf:true" "local_conf_path:$LUX_USER_CONF"
		# fi
		lux_load_rc

		#set with --local
		if [ $opt_local_conf -eq 0 ]; then
			lux_user_config 'local-conf.json'
		fi

		if [ -f "$LUX_USER_CONF" ]; then
			add_var "local_conf:true" "local_conf_path:$LUX_USER_CONF"
		fi

		lux_var_refresh

		for call in "$@"; do
			shift
			if [ $skip -eq 0 ]; then
				skip=1; continue
			fi
			case $call in
				ch*)      opt_skip_input=0; lux_checkup; ret=$?;;
				rep*)     opt_skip_input=1; lux_repair; ret=$?;;
				fc)       dev_fast_clean;;
				cpub*)    lux_make_cli && lux_publish_dist;;
				cdist)    lux_make_cli;	break;;
				link)     profile_link;    ret=$?;;
				unlink)   profile_unlink;  ret=$?;;
				find)     lux_search_files; break;;
				rc)       lux_dump_rc;     ret=$?;;
				rrc*)     lux_make_rc;     ret=$?;;
				home)     quiet 0; echo -e "$LUX_HOME";;
				bin)      quiet 0; echo -e "$LUX_BIN";;
				cli)      quiet 0; echo -e "$LUX_CLI";;
				mods)     quiet 0; echo -e "${LUX_MODS[*]}";;
				self)     quiet 0; echo -e "$0";;
				here)     quiet 0; echo -e "$BIN_DIR";;
				rmods)    lux_res_mods;;
				list)     lux_genlist;;
				lconf)    lux_user_config 'local-conf.json';;
				watch)    lux_watch "$1"; shift;;
				only)     lux_watch_only "$1"; shift;;
				clean)    lux_clean ;;
				build|make)
					case $1 in
						each) shift; lux_build_each;;
						all)  shift; lux_build_all;;
						"")   shift; lux_build;;
						*)    lux_build_mod "$1";;
					esac
					break;
				;;
				a|all)  lux_build_all;;
				each)   lux_build_each;;
				res)    lux_copy_res;;
				vars)   lux_vars;;
				vers*)
					opt_quiet=0
					lux_version
					exit 0
				;;
				\?|help)   lux_usage;;
				skip)   break;;
				\.)     break;;
				--*)    break;;
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

