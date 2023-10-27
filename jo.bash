#############################################################startjo
myjocompletion () {
        local f;
        for f in ~/ru/"$2"*;
        do [[ -f $f ]] && COMPREPLY+=( "${f##*/}" );
        done
}
complete -F myjocompletion jo
function jo() { 
####################################################################
# Jump Off ( jo ) - a very simple bash function that lets you 
# 					quickly cd to another directory
# HOW IT WORKS:
#   Files are stored in $HOME/jo/ directory ($HOME/jo more precisely)
#
# INSTALL:
#  AUTOMATED INSTALL
#   You can use git and php for a simple automated install as below:
#   $ git clone https://github.com/relipse/jojumpoff_bash_function.git jojumpoff
#   $ php jojumpoff/joinstall.php
#
#  MANUAL INSTALL
#	1. Add jo function to your .bashrc file (please
#	    include comments for possible inthefuture auto-upgrade script)
#   2. Type: source $HOME/.bashrc or close/reopen prompt
#   3. mkdir -p $HOME/jo
#  
# USAGE:
#    ADD/REPLACE JUMP OFF DIRECTORIES
#      1. You can do it the easy way using jo -a or --add
#         jo -a foo path/to/foo
#         jo -a bar path/to/bar/dir
#      2. Or the other easy way, 
#		  cd $HOME/jo 
#         echo "path/to/foo" > foo
#      	  echo "path/to/bar/dir" > bar
#    AND YOU ARE OFF:
#      1. Type "jo <shortname>" to jump to the directory added!
#      2. For example:
#      	$ jo foo   
#      	path/to/foo
#      	$ jo bar
#      	path/to/bar/dir
#    
# @author relipse
# @see #bash on freenode, python go script written by a komodoide developer
# @license Dual License: Public Domain and The MIT License (MIT) 
#        (Use either one, whichever you prefer)
# @version 1.6.200
####################################################################
	# Reset all variables that might be set
	local verbose=0
	local list=0
	local rem=""
	local add=0
	local adddir=""
    local allsubcommands="--list -l, --add -a, --help -h ?, -r -rm, -p --mkp"
	local mkdirp=""
	local mkdircount=0
	local printpath=0

	if (( $# == 0 )); then
	    #echo "Try jo --help for more, but here are the existing jos:"
		ls $HOME/jo
		#echo "Jo arguments: $allsubcommands"
	    return 0
	fi
 
 
	while :
	do
	    case $1 in
	        -h | --help | -\?)
	            #  Call your Help() or usage() function here.
	            echo "Usage: jo <foo>, where <foo> is a file in $HOME/jo/ containing the full directory path."
	            echo "Jo Command line arguments:"
	            echo "    <foo> or <foo>/more/path - cd to dir stored in contents of file $HOME/jo/<foo> (normal usage) "
	            echo "    --show|-s <foo>        - echo jump to path"
	            echo "    --list|-l              - show jump files, (same as 'ls $HOME/jo') "
	            echo "    --add|-a <sn> [<path>] - add/replace <sn> shortname to $HOME/jo with jump path <path> or current dir if not provided."
	            echo "    --rm|-r <sn>           - remove/delete short link."
	            echo "    --mkp|-p <sn>/path/to/more - jump to directory but auto-create it if it doesnt exist"
	            return 0      # This is not an error, User asked help. Don't do "exit 1"
	            ;;
	        -s | --show)
	            printpath=1
	            shift
	            ;;
	        -p | --mkp)
				mkdirp=1
				mkdircount=0
				echo "Jo will force-create directories..."
				shift
				;;
	        -l | --list)
				echo $(ls $HOME/jo)
				return 0
				;;
			 -r | -rm | --rm)
				 if [[ -n $2 ]]; then
				 	rem=$2
				 else
				 	echo Invalid usage. Correct usage is: jo --rm '<sn>'
				 	return 0
				 fi
				 shift 1
				 ;;
    		 -a | --add)
    		 	if [[ -n $2 ]]; then
	              add=$2     # You might want to check if you really got FILE
	            else
	            	echo Invalid usage. Correct usage is: jo --add '<sn> [<path>]'
	            	return 0
	            fi
	             
	            #by default add current pwd, if not given
	            if  [[ -n $3 ]]; then
	            	adddir=$3
	            	shift 1
	            else
	            	adddir=$(pwd)
	            fi

	            if [ ! -d $adddir ]; then
	            	echo "Warning: directory $adddir does not exist."
	            fi
	            shift 2
	            ;;
        	--add=*)
	            add=${1#*=}        # Delete everything up till "="
	            #by default add current pwd, if not given
	            if [[ -n $3 ]]; then
	            	adddir=$3
	            	shift 1
	            else
	            	adddir=$(pwd)
	            fi

	            if [ ! -d $adddir ]; then
	             	echo "Warning: directory $adddir does not exist."
	            fi
	            shift 1
            ;;
	        -v | --verbose)
	            # Each instance of -v adds 1 to verbosity
	            verbose=$((verbose+1))
	            shift
	            ;;
	        --) # End of all options
	            shift
	            break
	            ;;
	        -*)
	            echo "WARN: Unknown option (ignored): $1" >&2
	            shift
	            ;;
	        *)  # no more options. Stop while loop
	            break
	            ;;
	    esac
	done
 
    if [[ "$rem" ]]; then
        if [ -f $HOME/jo/"$rem" ]; then
        	echo "Removing $rem -> $(cat $HOME/jo/$rem)"
        	rm $HOME/jo/"$rem"
        else
         	echo "$rem does not exist"
         	local possible=$(ls $HOME/jo | grep $rem)
	    	if [[ $possible ]]; then
	    		echo Did you mean: $possible
	    	fi
        fi  
        return 0; 
    fi

    if  [[ "$adddir" ]]; then
        echo "$adddir" > $HOME/jo/"$add"
        if [ -f $HOME/jo/"$add" ]; then
        	echo "$add - $adddir added, try: jo $add"
        else
         	echo "problem adding $add"
        fi
        return 0;
    fi
 
	if (( list > 0 )); then
	    echo "Listing jos:"
		local lsjos=$(ls $HOME/jo)
		if [[ "$lsjos" ]]; then
		   echo $lsjos
		else
		   echo There are not yet any jos. try for example: jo --add foo path/to/bar
		fi
		return 0
	fi
 
	#check if jump file exists in $HOME/jo/ directory
	local file=$HOME/jo/"$1"
	if [ -f "$file" ]; then
		local fullpath=$(cat $file)
		if [[ "$printpath" -eq 1 ]];
		then
		    printf "%s" $fullpath
		    return 0
		fi
    else
    	local fullpath=""
    	# item contains / so attempting to cd and split
    	if [[ $1 == *"/"* ]]
    	then
    	   
    	    oIFS="$IFS"
    		IFS="/" read -ra SEGS <<< "$1"
	    	for i in "${SEGS[@]}" 
	    	do 
				    if [ -z "$fullpath" ]
				    then
						    if [ -f "$HOME/jo/$i" ]
						    then
						    	fullpath=$(cat $HOME/jo/$i)
						    	cd "$fullpath"
						    else
						    	break
						    fi
					else
						if [ -d "$(pwd)/$i" ]
						then
						   cd "$i"
						else
						   if [ $verbose -ge 1 ]
						   then
						   		echo $(pwd)/$i does not exist.
						   fi

						   if [[ "$mkdirp" ]]
						   then
						   		if [ $verbose -ge 1 ]
						   		then
						   		   echo "Creating and entering $i..."
						   		fi
						   		mkdir $i
						   		mkdircount=$((mkdircount+1))
						   		cd "$i"
							else
								echo "Use -p or --mkp to automagically create the directory next time."
								break
							fi
						fi
				    fi
				 done
				 IFS="$oIFS"
		fi

		if [ ! -z "$fullpath" ]
		then
			#jumped already to location
			if [[ "$mkdirp" ]]
			then
				if [ $mkdircount -eq 1 ]
				then
					echo "Created 1 directory."
				else
					echo "Created $mkdircount directories."
				fi
			fi

			return 1
		fi

    	if [ -d "$1" ]
    	then
    		echo "$1 is a valid directory. Jumping off..."
            cd "$1"
    	else
	    	echo Error: "'$1'" does not exist.
	    	local possible=$(ls $HOME/jo | grep $1)
	    	if [[ $possible ]]; then
	    		echo Did you mean: $possible
	    	else
	    	   echo 'Type this to add it:'
	    	   echo jo --add $1 path/to/dir
	    	fi
	    fi
 
    	#echo "$file does not exist. Use jo --add $file to add it."
    	return 1
    fi 
 
 
	if [ -d "$fullpath" ]
	then
        cd "$fullpath"
	else
		echo $file exist, but $fullpath does not exist. Staying in same directory
 
		#echo "To add/replace a jo jump file, type either: "
		#echo "jo --add <foo> <long-path-to-dir>"
		#echo "echo '<long-path-to-dir>' > $HOME/jo/<foo> "
	fi
}
###############################################################endjo
