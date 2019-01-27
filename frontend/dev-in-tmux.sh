tmux new-session -s lockpick-dev 'zsh build-elm.sh' \; \
new-window 'yarn sass --watch src/css:build' \; \
new-window 'yarn serve -s'
