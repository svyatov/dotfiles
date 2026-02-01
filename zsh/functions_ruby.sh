rncd() { rails new "$1" && cd "$1" }

_bin_first() {
    if [[ -x ./bin/$1 ]]; then
        ./bin/$1 ${@:2} # means "skip first element in array"
    else
        $(rbenv root)/shims/$1 ${@:2}
    fi
}

# rails()  { _bin_first rails  $@ }
# rake()   { _bin_first rake   $@ }
# cap()    { _bin_first cap    $@ }
# bundle() { _bin_first bundle $@ }

_Rakefile_changed() {
  [[ ! -f .rake_tasks ]] || [[ Rakefile -nt .rake_tasks ]]
}

_rake () {
  if [ -f Rakefile ]; then
    if _Rakefile_changed; then
      rake --tasks --quiet | awk '{print $2}' >! .rake_tasks
    fi
    compadd `cat .rake_tasks`
  fi
}
compdef _rake rake
compdef _rake rails
