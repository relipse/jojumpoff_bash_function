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
#   $ git clone https://gist.github.com/e9dc3fd55436976360d3.git jojumpoff
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
# @version 1.5.900
####################################################################
	# Reset all variables that might be set
	local verbose=0
	local list=0
	local add=0
	local adddir=0
    local allsubcommands="--list -l, --add -a, --help -h ?"
	if (( $# == 0 )); then
	    #echo "Try jo --help for more, but here are the existing jos:"
		ls $HOME/jo
		#echo "Jo arguments: $allsubcommands"
	    return 0;
	fi
 
 
	while :
	do
	    case $1 in
	        -h | --help | -\?)
	            #  Call your Help() or usage() function here.
	            echo "Usage: jo <foo>, where <foo> is a file in $HOME/jo/ containing the full directory path."
	            echo "Jo Command line arguments:"
	            echo "    <foo> - cd to dir stored in contents of file $HOME/jo/<foo> (normal usage) "
	            echo "    --list -l             -  show jump files, (same as 'ls $HOME/jo') "
	            echo "    --add  -a <sn> [<path>] -  add/replace <sn> shortname to $HOME/jo with jump path <path> or current dir if not provided."
	            return 0      # This is not an error, User asked help. Don't do "exit 1"
	            ;;
	        -l | --list)
				list=$((list+1))
				shift
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

	            if [[ -d $adddir ]]; then
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

	            if [[ -d $adddir ]]; then
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
 
    if  (( $adddir != 0 )); then
        echo "$adddir" > $HOME/jo/"$add"
        if [ -f $HOME/jo/"$add" ]; then
        	echo $add - $adddir added, try: jo $add
        else
         	echo problem adding $add
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
	if [ -f $file ]; then
		local fullpath=$(cat $file)
    else
    	echo Error: "'$1'" does not exist.
    	local possible=$(ls $HOME/jo | grep $1)
    	if [[ $possible ]]; then
    		echo Did you mean: $possible
    	else
    	   echo 'Type this to add it:'
    	   echo jo --add $1 path/to/dir
    	fi
 
    	#echo "$file does not exist. Use jo --add $file to add it."
    	return 1
    fi 
 
 
	if [ -d $fullpath ]
	then
		echo "jumping off >>"
		cd $fullpath
		pwd
	else
		echo $file exist, but 
		echo $fullpath does not exist
 
		#echo "To add/replace a jo jump file, type either: "
		#echo "jo --add <foo> <long-path-to-dir>"
		#echo "echo '<long-path-to-dir>' > $HOME/jo/<foo> "
	fi
}
###############################################################endjo
