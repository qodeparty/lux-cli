#!/usr/bin/env bash
#-------------------------------------------------------------------------------
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
#  Script
#-----------------------------------------------------------
	readonly script_pid=$$
	readonly script_author="qodeparty"
	readonly script_id="lux"
	readonly script_prefix="LUX"
	readonly script_rc_file=".luxrc"
	readonly script_log_file="$script_id.log"
	readonly script_lic="MIT License"


#-------------------------------------------------------------------------------
# Vars
#-------------------------------------------------------------------------------

	CPID="$$"
	BIN_DIR="$( cd "$(dirname "$0")" || exit; pwd -P )"
	THIS_DIR="$( cd $BIN_DIR && cd .. || exit; pwd -P )"


	missing=()
	__repo_list=( )
	__alias_list=( )
#-------------------------------------------------------------------------------
# Term
#-------------------------------------------------------------------------------
	source $BIN_DIR/inc-term.sh "${@}"

  #__print "Basic Print Available"
  #info "Info Available"
  #silly "Silly Available"
#-------------------------------------------------------------------------------
# Help / Debug
#-------------------------------------------------------------------------------
	source $BIN_DIR/inc-doc.sh

#-------------------------------------------------------------------------------
# Vars
#-------------------------------------------------------------------------------
	source $BIN_DIR/inc-vars.sh

#-------------------------------------------------------------------------------
# Utils
#-------------------------------------------------------------------------------
	source $BIN_DIR/inc-utils.sh

#---------------if ----------------------------------------------------------------
# JS Generator
#-------------------------------------------------------------------------------
	source $BIN_DIR/inc-meta.sh

#-------------------------------------------------------------------------------
# Utils
#-------------------------------------------------------------------------------
	source $BIN_DIR/inc-buildtools.sh

	script_vers="$(lux_build_version 'vers')";
	script_build="$(lux_build_version 'build')";

	source $BIN_DIR/inc-filetools.sh


#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------
	function __dispatch(){
		#log_debug "[fx:$FUNCNAME] args:$#"
		local call ret
		skip=1

		#call=$1; shift

		if [ -f "$LUX_USER_CONF" ]; then
			add_var "local_conf:true" "local_conf_path:$LUX_USER_CONF"
		fi

		#printf "$# $call $1 $2"

		#lux_var_refresh

		for call in "$@"; do

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
				reset)
					lux_reset_rc;
					check_rc_repos;
				;;
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
				repos)

					lux_need_align_repos;ret=$?

					if [ $ret -eq 0 ]; then
						silly "find repos in $1"
						lux_find_repos "$1"
					fi

					lux_align_repos; shift;
					break;;
				find)
					IFS=
					flags="-HiREl"
					case $1 in
						files) shift; res=$(grep -HiREl --color=always "$1" .);;
						html) shift; res=$(grep -HiRE --include=\*.html --color=always "$1" .);;
						styl) shift; res=$(grep -HiRE --include=\*.styl --color=always "$1" .);;
						*) res=$(grep -HiREn --color=always "$1" .);;
					esac
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
				search)
					this=$(search_replace_bash "$1")
					__print "$this"
				;;
				makebin)
					makebin "$1" "$2"
					info "$1 $2"
					shift;
				;;
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

		# if check_rc_repos; then
		# 	__dispatch "$@"
		# fi
	}


#-------------------------------------------------------------------------------
# Driver
#-------------------------------------------------------------------------------
if [ "$0" = "-bash" ]; then
	:
else

	args=("${@}")

	[[ "${@}" =~ "--12"    ]] && add_var "basis:12" && opt_basis=12 || :
	[[ "${@}" =~ "--16"    ]] && add_var "basis:16" && opt_basis=16 || :
	[[ "${@}" =~ "--vers"  ]] && opt_quiet=0 && lux_version && exit 0 || :
	#[ -t 1 ] && [ $opt_force -eq 0 ] && opt_quiet=1 ||:

	#args=( "${args[@]/\-*}" ); #delete anything that looks like an option

	main "${args[@]}";ret=$?
fi
