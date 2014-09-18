#!/bin/zsh -f

# Orignal source: https://gist.github.com/capotej/4320967

function set_terminals_titles {

  function set_terminals_tab_title {
      if [[ $TERM_PROGRAM == iTerm.app ]]; then
        tab_label="$PWD:h:t/$PWD:t"

        # The $rlength variable prints only the 20 rightmost characters
        # Otherwise iTerm truncates what appears in the tab from the left
        rlength="20"

        echo -ne "\e]1;${(l:rlength:)tab_label}\a"
      fi
  }

  function set_terminals_window_title {
    title_lab=$PWD
    echo -ne "\e]2;$title_lab\a"
  }

  # Set tab and title bar dynamically using above-defined functions
  function titles_chpwd { set_terminals_tab_title ; set_terminals_window_title }

  # Now we need to run it
  titles_chpwd

  # Set tab or title bar label transiently to the currently running command
  if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
    function tab_title_preexec {  echo -ne "\e]1; $(history $HISTCMD | cut -b7- ) \a"  }
    function tab_title_precmd  { set_terminals_tab_title }
  fi

  # Use reserved named arrays instead of special functions if the ZSH version is 4.3.4 or above
  typeset -ga preexec_functions
  preexec_functions+=tab_title_preexec
  typeset -ga precmd_functions
  precmd_functions+=tab_title_precmd
  typeset -ga chpwd_functions
  chpwd_functions+=titles_chpwd

}

####################
set_terminals_titles
