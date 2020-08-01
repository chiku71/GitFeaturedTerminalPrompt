
################################################################################################################################################################################################################################################
##               						Start  of Terminal Prompt Customisation
################################################################################################################################################################################################################################################
## Some Collected Characters to use
## 𝇡𝇡ᗗᗖ𐋇↑↓↥↧⇑⇓⇫⩠⩢︽︾＋＊𝍣𝍨𝋯𝋲𝝣𝞝𝇡𐄯⯭⯯⬱⫸⭆⭅⨁⧯✎✍⛳☢☠☔⚑ⵜ
## ⁉⁂※⁕⇑⇞⇯⏫☄⚒⛃⛢☠☢☔✎❓❗➠➽⤊⟰⟱⤒⥉⦽⨀⨁⧊⩕⨶⮸⮹�
## 


##############################################
# Method for Git Info Prompt
##############################################
prompt_git_info() {

	# Find the Git Branch in the repo
	local LOCAL_GIT_BRANCH=$(git branch 2>/dev/null | grep '^*' | colrm 1 2)
	
	# In scenario such as when a new repo has just been initiated, the above code can't detect the branch.
	if [ ! $LOCAL_GIT_BRANCH ]  && [ -d ".git" ]; then
		LOCAL_GIT_BRANCH=$(git status 2>/dev/null | grep "^On branch " | colrm 1 10)
	fi
	
	if [ $LOCAL_GIT_BRANCH ]; then
		
		# Add Branch Name
		GIT_BRANCH_IN_DIR="  $LOCAL_GIT_BRANCH "
		local TEST_SYMBOLS=false

		# Customisation for Git Branch
		local EXPECTED_REMOTE_BRANCH_NAME="remotes/origin/$LOCAL_GIT_BRANCH"
		local IS_BRANCH_IN_REMOTE=$(git branch -a | grep -o -m 1 $EXPECTED_REMOTE_BRANCH_NAME)
		local NUM_COMMITS_AHEAD="0"
		local NUM_COMMITS_BEHIND="0"
		
		if [ $IS_BRANCH_IN_REMOTE ];then
			NUM_COMMITS_AHEAD=$(git rev-list origin/$LOCAL_GIT_BRANCH..$LOCAL_GIT_BRANCH --count)  # To Push
			NUM_COMMITS_BEHIND=$(git rev-list $LOCAL_GIT_BRANCH..origin/$LOCAL_GIT_BRANCH --count)  # To Pull
		else
			GIT_BRANCH_IN_DIR="${GIT_BRANCH_IN_DIR} "
			NUM_COMMITS_AHEAD=$(git shortlog $LOCAL_GIT_BRANCH --not --remotes 2>/dev/null | wc -l ) 
			
			if [ $NUM_COMMITS_AHEAD != "0" ]; then
				NUM_COMMITS_AHEAD=$(($NUM_COMMITS_AHEAD-2))
			fi
		fi
		
		local NUM_MODIFIED=$(git diff --name-only --diff-filter=M | wc -l)
		local NUM_DELETED=$(git diff --name-only --diff-filter=D | wc -l)
		local NUM_UNTRACKED=$(git status --porcelain 2>/dev/null| grep "^??" | wc -l)
    		local NUM_STAGED=$(git diff --staged --name-only --diff-filter=AM | wc -l)
    		local NUM_CONFLICT=$(git diff --name-only --diff-filter=U | wc -l)
    		
    		local NUM_STASHES="0"
    		local GIT_STASH_FOUND="$(git stash list 2>/dev/null | grep -o -m 1 "^stash@{")"
    		if [ $GIT_STASH_FOUND ];then
    			NUM_STASHES=$(git rev-list --walk-reflogs --count refs/stash)
    		fi
    		
		# Add Number of Commits behind
		if [ $NUM_COMMITS_BEHIND != "0" ] || $TEST_SYMBOLS; then
			GIT_BRANCH_IN_DIR="${GIT_BRANCH_IN_DIR} $NUM_COMMITS_BEHIND " 
		fi
		
		# Add Number of Commits Ahead
		if [ $NUM_COMMITS_AHEAD != "0" ] || $TEST_SYMBOLS; then
			GIT_BRANCH_IN_DIR="${GIT_BRANCH_IN_DIR} $NUM_COMMITS_AHEAD " 
		fi
		
		# Add Number of Staged Files
		if [ $NUM_STAGED != "0" ] || $TEST_SYMBOLS; then
			GIT_BRANCH_IN_DIR="${GIT_BRANCH_IN_DIR}𝋲 $NUM_STAGED " 
		fi
		
		# Add Number of Modified Files
		if [ $NUM_MODIFIED != "0" ] || $TEST_SYMBOLS; then
			GIT_BRANCH_IN_DIR="${GIT_BRANCH_IN_DIR} $NUM_MODIFIED " 
		fi
		
		# Add Numbder of Newly Added Files
		if [ $NUM_UNTRACKED != "0" ] || $TEST_SYMBOLS; then
			GIT_BRANCH_IN_DIR="${GIT_BRANCH_IN_DIR}＋$NUM_UNTRACKED " 
		fi
		
		# Add Numbder of Deleted Files
		if [ $NUM_DELETED != "0" ] || $TEST_SYMBOLS; then
			GIT_BRANCH_IN_DIR="${GIT_BRANCH_IN_DIR}$NUM_DELETED " 
		fi
		
		# Add Number of Conflicts
		if [ $NUM_CONFLICT != "0" ] || $TEST_SYMBOLS; then
			GIT_BRANCH_IN_DIR="${GIT_BRANCH_IN_DIR}$NUM_CONFLICT " 
		fi
		
		# Add Number of Stashes
		if [ $NUM_STASHES != "0" ] || $TEST_SYMBOLS; then
			GIT_BRANCH_IN_DIR="${GIT_BRANCH_IN_DIR}⚑$NUM_STASHES " 
		fi
			
	else
		GIT_BRANCH_IN_DIR=""
	fi
}


###################################################
# Method for Working Directory Info
###################################################
prompt_pwd_info() {
	# Set max length to show for $PWD
	local pwdmaxlen=25
	# echo "Test 2"
	
	# Indicate that there has been dir truncation
	local trunc_symbol=".."

	# Store local dir
	local dir=${PWD##*/}

	# Which length to use
	pwdmaxlen=$(( ( pwdmaxlen < ${#dir} ) ? ${#dir} : pwdmaxlen ))

	NEW_PWD=${PWD/#$HOME/\~}
	local pwdoffset=$(( ${#NEW_PWD} - pwdmaxlen ))

	# Generate name
	if [ ${pwdoffset} -gt "0" ]; then
		NEW_PWD=${NEW_PWD:$pwdoffset:$pwdmaxlen}
		NEW_PWD=${trunc_symbol}/${NEW_PWD#*/}
	fi
	
	# NEW_PWD=""
}


############################################
# Method to control the Bash Prompt Info
############################################
bash_prompt_command() {
	
	# Trigger for Present Working Directory
	prompt_pwd_info
	
	# Trigger for Git Info for this Directory
	prompt_git_info
	
}


########################################################
#	GENERATE A FORMAT SEQUENCE
########################################################
format_font() {
	## FIRST ARGUMENT TO RETURN FORMAT STRING
	local output=$1

	case $# in
	2)
		eval $output="'\[\033[0;${2}m\]'"
		;;
	3)
		eval $output="'\[\033[0;${2};${3}m\]'"
		;;
	4)
		eval $output="'\[\033[0;${2};${3};${4}m\]'"
		;;
	*)
		eval $output="'\[\033[0m\]'"
		;;
	esac
}


#######################################
# COLORIZE BASH PROMT
######################################
bash_prompt() {

	############################################################################
	## COLOR CODES                                                            ##
	## These can be used in the configuration below                           ##
	############################################################################
        # Do a git fetch
        if [ $(git branch 2>/dev/null | grep '^*' | colrm 1 2) ];then
		$(git fetch &> /dev/null)
	fi
	
	# Required Font Effect
	local      BOLD='1'
	
	# Requires Types
	local    EFFECT='0'
	local     COLOR='30'
	local        BG='40'
	
	# Required Colors
	local   DEFAULT='9'
	local      BLUE='4'
	local   MAGENTA='5'
	local L_MAGENTA='65'
	local     WHITE='67'
	local WHITE_BOLD="\[\033[1;38;5;15m\]"
        local GREEN_BOLD="\[\033[01;32m\]"
        
	############################################################################
	## CONFIGURATION                                                          ##
	## Choose your color combination here
	############################################################################
	# For User
        local FONT_COLOR_1=$WHITE
	local BACKGROUND_1=$MAGENTA
	local TEXTEFFECT_1=$BOLD
	
        # For Host
	local FONT_COLOR_2=$WHITE
	local BACKGROUND_2=$L_MAGENTA
	local TEXTEFFECT_2=$BOLD
	
	# For Current Working Directory
	local FONT_COLOR_3=$BLUE 
	local BACKGROUND_3=$WHITE
	local TEXTEFFECT_3=$BOLD
        
        # For Git Branch if there is any
	local FONT_COLOR_4=$WHITE
	local BACKGROUND_4=$BLUE
	local TEXTEFFECT_4=$BOLD
	
        # For Typed Command
	local PROMT_FORMAT=$GREEN_BOLD

	############################################################################
	## TEXT FORMATING                                                         ##
	## Generate the text formating according to configuration                 ##
	############################################################################
	
	## CONVERT CODES: add offset
	FC1=$(($FONT_COLOR_1+$COLOR))
	BG1=$(($BACKGROUND_1+$BG))
	FE1=$(($TEXTEFFECT_1+$EFFECT))
	
	FC2=$(($FONT_COLOR_2+$COLOR))
	BG2=$(($BACKGROUND_2+$BG))
	FE2=$(($TEXTEFFECT_2+$EFFECT))
	
	FC3=$(($FONT_COLOR_3+$COLOR))
	BG3=$(($BACKGROUND_3+$BG))
	FE3=$(($TEXTEFFECT_3+$EFFECT))
	
	FC4=$(($FONT_COLOR_4+$COLOR))
	BG4=$(($BACKGROUND_4+$BG))
	FE4=$(($TEXTEFFECT_4+$EFFECT))

	## CALL FORMATING HELPER FUNCTION: effect + font color + BG color
	local TEXT_FORMAT_1
	local TEXT_FORMAT_2
	local TEXT_FORMAT_3
	local TEXT_FORMAT_4	
	format_font TEXT_FORMAT_1 $FE1 $FC1 $BG1
	format_font TEXT_FORMAT_2 $FE2 $FC2 $BG2
	format_font TEXT_FORMAT_3 $FC3 $FE3 $BG3
	format_font TEXT_FORMAT_4 $FC4 $FE4 $BG4
	
	# GENERATE PROMT SECTIONS
	local PROMT_USER=$"$TEXT_FORMAT_1 \u "
	local PROMT_HOST=$"$TEXT_FORMAT_2 \h "
	local PROMT_PWD=$"$TEXT_FORMAT_3 \${NEW_PWD} "
	local PROMT_GIT_BRANCH=$"$TEXT_FORMAT_4\${GIT_BRANCH_IN_DIR}"
	local PROMT_END_SYMBOL=$"$WHITE_BOLD\$"
	local PROMT_INPUT=$"$PROMT_FORMAT "

	############################################################################
	## SEPARATOR FORMATING                                                    ##
	## Generate the separators between sections                               ##
	## Uses background colors of the sections                                 ##
	############################################################################
	
	## CONVERT CODES
	TSFC1=$(($BACKGROUND_1+$COLOR))
	TSBG1=$(($BACKGROUND_2+$BG))
	
	TSFC2=$(($BACKGROUND_2+$COLOR))
	TSBG2=$(($BACKGROUND_3+$BG))
	
	TSFC3=$(($BACKGROUND_3+$COLOR))
	TSBG3=$(($BACKGROUND_4+$BG))
                
        TSFC4=$(($BACKGROUND_4+$COLOR))
	TSBG4=$(($DEFAULT+$BG))
	
	## CALL FORMATING HELPER FUNCTION: effect + font color + BG color
	local SEPARATOR_FORMAT_1
	local SEPARATOR_FORMAT_2
	local SEPARATOR_FORMAT_3
	local SEPARATOR_FORMAT_4
	format_font SEPARATOR_FORMAT_1 $TSFC1 $TSBG1
	format_font SEPARATOR_FORMAT_2 $TSFC2 $TSBG2
	format_font SEPARATOR_FORMAT_3 $TSFC3 $TSBG3
	format_font SEPARATOR_FORMAT_4 $TSFC4 $TSBG4
	
	# GENERATE SEPARATORS WITH FANCY TRIANGLE
	local TRIANGLE=$'\uE0B0'	
	local SEPARATOR_1=$SEPARATOR_FORMAT_1$TRIANGLE
	local SEPARATOR_2=$SEPARATOR_FORMAT_2$TRIANGLE
	local SEPARATOR_3=$SEPARATOR_FORMAT_3$TRIANGLE
	local SEPARATOR_4=$SEPARATOR_FORMAT_4$TRIANGLE

	############################################################################
	## WINDOW TITLE                                                           ##
	## Prevent messed up terminal-window titles                               ##
	############################################################################
	case $TERM in
	xterm*|rxvt*)
		local TITLEBAR='\[\033]0;\u:${NEW_PWD}\007\]'
		;;
	*)
		local TITLEBAR=""
		;;
	esac

	############################################################################
	## BASH PROMT                                                             ##
	## Generate promt and remove format from the rest                         ##
	############################################################################     
        PS1="$TITLEBAR\n${PROMT_USER}${SEPARATOR_1}${PROMT_HOST}${SEPARATOR_2}${PROMT_PWD}${SEPARATOR_3}${PROMT_GIT_BRANCH}${SEPARATOR_4}${PROMT_END_SYMBOL}${PROMT_INPUT}"
        
	
	## For terminal line coloring, leaving the rest standard
	none="$(tput sgr0)"
	trap 'echo -ne "${none}"' DEBUG
}

################################################################################
##  MAIN                                                                      ##
################################################################################

## Bash provides an environment variable called PROMPT_COMMAND. 
## The contents of this variable are executed as a regular Bash command just before Bash displays a prompt. 
PROMPT_COMMAND=bash_prompt_command

## Call bash_promnt only once, then unset it (not needed any more)
## It will set $PS1 with colors and relative to $NEW_PWD, which gets updated by $PROMT_COMMAND on behalf of the terminal
bash_prompt
unset bash_prompt

################################################################################################################################################################################################################################################
##               						End  of Terminal Prompt Customisation
################################################################################################################################################################################################################################################

