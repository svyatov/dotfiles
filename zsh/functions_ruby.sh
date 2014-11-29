rncd() { rails new "$1" && cd "$1" }

_bin_first() {
    if [[ -x ./bin/$1 ]]; then
        ./bin/$1 ${@:2} # means "skip first element in array"
    else
        # bundler and rake are installed in global gemset
        if [[ -x $GEM_HOME@global/bin/$1 ]]; then
            $GEM_HOME@global/bin/$1 ${@:2}
        else
            $GEM_HOME/bin/$1 ${@:2}
        fi
    fi
}

rails()  { _bin_first rails  $@ }
rake()   { _bin_first rake   $@ }
cap()    { _bin_first cap    $@ }
bundle() { _bin_first bundle $@ }

_Rakefile_changed() {
  if [ ! -f .rake_tasks ]; then return 0;
  else
    accurate=$(stat -f%m .rake_tasks)
    changed=$(stat -f%m Rakefile)
    return $(expr $accurate '>=' $changed)
  fi
}
_rake () {
  if [ -f Rakefile ]; then
    if _Rakefile_changed; then
      rake --tasks --quiet | cut -d " " -f 2 > .rake_tasks
    fi
    compadd `cat .rake_tasks`
  fi
}
compdef _rake rake

