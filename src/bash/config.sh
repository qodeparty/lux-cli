#rainbow
#!/usr/bin/env bash
#tab_size:2
#===============================================================================
# Lux Config
# QodeParty (c) 2018
#===============================================================================


#--------------------------------------------------------------
# Vars - these will be unset on exit
#--------------------------------------------------------------

    __bin="$PWD/bin"
    __lib="$PWD/lib"
    __ch='\xE2\x9C\x94'
    __bx='\xE2\x9C\x97'
    __ll='\xCE\xBB'
    __ul=$(tput smul)
    __rul=$(tput rmul)
    __g=$(tput setaf 2)
    __gr=$(tput setaf 241)
  	__y=$(tput setaf 11)
  	__o=$(tput setaf 9)
  	__bl=$(tput setaf 12)
    __x=$(tput sgr0)

#--------------------------------------------------------------
# Funcs - these will be unset on exit
#--------------------------------------------------------------


    function luxconf_cleanup(){
      local arr=( ll ul rul g gr y o bl ch bx x bin lib)
      for i in ${!arr[@]}; do
        __="${arr[$i]}"
        this="__${__}"
        unset $this
      done
      unset -f luxconf_cleanup
      unset -f luxconf_usage
      unset -f luxconf_inst
      unset -f luxconf_uninst
      return 0
    }


    #----------


    function luxconf_usage(){
    	[ "$0" != "-bash" ] && __iss="\t${__o}Warn: config file must be sourced!${__x}\n" || __iss=
			__msg="$(cat <<-EOF
				\n${__bl}${__ll}Lux Config${__x}\n
				${__iss}
				\t${__x}Usage:
				\t  ${__bl}source ./config install ${__x}
				\t  ${__bl}source ./config uninstall ${__x}
				\t  ${__bl}source ./config help ${__x}\n\n
			EOF
			)";
			printf "${__msg}"
    }


    #----------


    function luxconf_inst(){
			__msg="$(cat <<-EOF
				\n${__bl}${__ll}Lux CLI${__x}
				\n\t${__o}${__bx} Removed!${__x} ${__ul}lux/bin${__x} was completely scrubbed from your \$PATH. \n
				\t${__x}To re-install:\n
				\t  ${__g}source ./config install ${__x}\n\n
			EOF
			)";
		  printf "${__msg}"
    }


    #----------


    function luxconf_uninst(){
			__msg="$(cat <<-EOF
				\n${__bl}${__ll}Lux CLI${__x}
				\n\t${__g}${__ch} Added!${__x} ${__ul}lux/bin${__x} was temporarily appended to your \$PATH.
				\n\tNow you can do stuff with the Lux CLI. Try one of these commands:\n
				\t  ${__y}lux link  ${__x}${__gr}# add LUX to your profile ${__x}
				\t  ${__y}lux build ${__x}${__gr}# build LUX.css
				\t  ${__y}lux help  ${__x}${__gr}# view usage info\n
				\t${__x}To uninstall:\n
				\t  ${__o}source ./config uninstall ${__x}\n\n
			EOF
			)";
	    printf "${__msg}"
    }


#--------------------------------------------------------------
# Driver -  file must be sourced
#--------------------------------------------------------------

  if [ "$0" = "-bash" ]; then

  	#uninstall
		if [[ "${@}" =~ "un" ]]; then
				if [[  "$PATH" =~ "$__bin" ]]; then
					./bin/lux unlink
					printf -v PATH '%s\n' "${PATH//:${__bin}/}"
					#printf -v PATH '%s\n' "${PATH//:${__lib}/}"
					luxconf_inst
				else
					printf "${__o}${__bx} Lux CLI is not on your \$PATH ${__x}\n"
				fi

		#install
		elif [[ "${@}" =~ "in" ]]; then
			if [[ ! "$PATH" =~ "$__bin" ]]; then
					export PATH="$PATH:${__bin}:"
					./bin/lux link
					luxconf_uninst
			 else
			 		printf "${__g}${__ch} Lux CLI is already on your \$PATH ${__x}\n"
			 fi

		#help
		else
			luxconf_usage
		fi

		#remove namespace pollution
    luxconf_cleanup

  else
  	luxconf_usage
  fi
