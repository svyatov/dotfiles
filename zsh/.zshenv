export PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:$PATH
if [[ -d "/usr/local/share/npm/bin" ]]; then
    export PATH=$PATH:/usr/local/share/npm/bin
fi
if [[ -d "/Applications/Postgres.app/Contents/MacOS/bin" ]]; then
    export PATH="/Applications/Postgres.app/Contents/MacOS/bin:$PATH"
fi
