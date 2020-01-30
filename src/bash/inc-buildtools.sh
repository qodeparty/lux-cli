#!/usr/bin/env bash





	function lux_user_config(){
		local list this i
		info "Loading user config..."
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
				 add_var "local_conf:true" "conf_path:$this"
				 break
			else
				 ftrace "Cant find a config file at ($this)$dots"
			fi
		done


	}



	function lux_res_mods(){
		local i css_path clean this this_file
		trace "Copy modules to res folder..."
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
				[ -f "$this_file" ] && cp "$this_file" "$that_file"  || error "Didnt copy lux-module file for $this ($that_file)"
			fi
		done

		[ $clean -eq 0 ] && info "Cleaning (${LUX_MODS[*]}) styles" || trace "Copying (${LUX_MODS[*]}) styles";
	}

	function lux_prep(){
		local src data
		src="$1"
		data+=""
		data="$(cat <<-EOF
			/* $script_id $script_vers | $script_lic (c)2019 $script_author | https://qodeparty.com/get/lux */
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

			#lux_gen_version "$LUX_WWW" #gen version file
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
		#lux_gen_version "$LUX_WWW" #gen version file again after push
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
		#lux_res_mods

		lux_copy_www
	}


	function lux_compile(){
		local this thisd thisb thisf d f p buildtype
		this="$1"
		btype="$2"

		lux_mods
		#info "COMPILE $btype ${#this} $this"
		if [ ${#this} -gt 0 ] && [ -f "$this" ]; then

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
			#lux_gen_version
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
			core)  		 [ -z "$mode" ] && val='main' || val="$LUX_CORE";;
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

			#osx find?
			[ -d "$this" ] && files=($($cmd_find $this -type f -name *.styl -printf "%f\n" )) || err="Invalid directory ($d)"

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
					if [[ "$f" =~ ^"${d}" ]]; then
						 _f="${f/${d}-/}";
						 p="${d}-${_f}";
						 silly "File has redundant prefix (correcting...) $p";
					fi
					silly "Rebuilding ($p) ..."
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

#-------------------------------------------------------------------------------
# Watch
#-------------------------------------------------------------------------------

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

			chsum2=`$cmd_find $LUX_HOME/src -type f \( -name "*.styl" -o -name "*.css*" -o -name "*.js*" \) -mmin -0.3 -exec md5sum {}  \;`


			if [[ $chsum1 != $chsum2 ]] ; then

				res=$(echo "$chsum2")
				IFS=' ' read -r -a array <<< "$res"
				this="${array[1]}"

				info "${array[0]}";

				#this="${chsum2#*  }" #not sure why this is two spaces!!?

				#that="${this[0]}"
				#warn "$that <$chsum2>"

				#this=$(echo $chsum2 | tr -d '[:space:]')
				[ ${#this} -gt 0 ] && warn "Change detected... <${this}>";

				#FIX COMPILE PATHS
				[[ "$this" =~ ".styl" ]] && res=$(lux_compile "$this") && ret=$? || ret=1;
				[[ "$this" =~ ".js" ]]   && res=$(lux_compile "$LUX_UTIL/index.styl") || :
				chsum1=$chsum2

				chval="${chsum2%% *}"

				if [ $ret -eq 0 ]; then
					[ -n "$chval" ] && pass "${green}Watch job ($orange$chval$green) completed!$x$nl$line" || :
				fi

			fi


			# if [[ $chsum1 != $chsum2 ]] ; then
			# 	res=$(echo "$chsum2")
			# 	IFS=' ' read -r -a array <<< "$res"
			# 	trace "${array[0]}"; this="${array[1]}"
			# 	lux_compile "$this"
			# 	chsum1=$chsum2
			# fi


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


				chsum2=`$cmd_find $LUX_HOME/src/styl -type f \( -name "$only" \) -mmin -1 -exec md5sum {}  \;`
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

#these sed functions need some love but they work

	function search_replace_bash(){
		target="$1"
		no_comments="$2"
		res=($(grep -E '^[[:space:]]*include' $target -n | awk '{print $1 $3}'))
		lines=()
		files=()
		real=()

		tmp_target="${target}.copy"

		cp "$target" "$tmp_target"

		#first pass split up lines into buckets cuz im neurotic
		for i in ${!res[@]}; do
			this=${res[$i]}
			file_ref=${this##*:}
			line_no=${this%%:*}
			lines+=("$line_no")
			files+=("$file_ref")
			real_file=$(eval echo "$file_ref")
			real+=("$real_file")
		done

		#second pass actualize paths and inject file content
		for i in ${!lines[@]}; do
			this=${lines[$i]}
			ref=${files[$i]}
			val=${real[$i]}

			qref=$(quoteRe "include $ref")

			#info "$ref $qref"
			insert_wh_replace "$val" "$tmp_target" "$qref"

			#sed -i.bak -e "/${qref}/d" "$target" #delete line number
			name=$(basename $ref)
			data="$bline\n## import file:${name%%\.sh*} ##\n$bline"

			#info "Sed Replace Marker ${qref}"
			$cmd_sed -i.bak -e "s|.*${qref}.*|${data}|i" $tmp_target


			#remore leading shebang after line 15
			if [ -z "$no_comments" ]; then
				qref=$(quoteRe "#!")
			else
				qref=$(quoteRe "#")
				qref="^[[:space:]]*${qref}[^#]"
			fi

			#info "$qref"
			$cmd_sed -i.bak -e "15,\${ /${qref}/d }" "$tmp_target"

		done

		#lookahead dont work in sed
		# s|(?=[[:print:]]+)[[:space:]]*[#].*||i
		#sed -i.bak -e "15,\${ s/[[:space:]][^\W#]*[#][^#|\n]+.*//i }" "$tmp_target"
		$cmd_sed -i.bak "/^$/d" "$tmp_target"
		echo "$tmp_target"
	}

	#note:this only makes sense in cli dir
	function make_cli_dist(){
		#dtrace "$ROOT_DIR"
		build="$(cd $ROOT_DIR && git rev-list HEAD --count).$(date +%s)"
		wtrace "Lux CLI Dist build is $build"

		src_file="${1:-$ROOT_DIR/src/bash/luxbin}" #this is where main template
		tmp_file=$(search_replace_bash "$src_file" "$2")
		dist_file="$ROOT_DIR/dist/lux"

		mkdir -p "$ROOT_DIR/dist"
		mv "$tmp_file" "$dist_file"

		#set permissions
		chmod +x "$dist_file"
		#cp "$dist_file" "$dist_file-${build}"

		[ -f "$tmp_file.bak" ] && rm "$tmp_file.bak"
		echo "CLI Build $build"
	}


	function deploy_dist_home(){
		info "deploy_dist_home"

    dist_file="$ROOT_DIR/dist/lux"

    if [ -d "$LUX_HOME" ]; then
	    target="$LUX_HOME/bin"
	    if [ -f "$dist_file" ]; then
	    	silly "Make Target $target"
		    mkdir -p "$target"
		    cp "$dist_file" "$target/lux"
		    return 0
		  else
		  	warn "Dist File not exists $dist_file"
		  fi
		fi
		return 1
	}

