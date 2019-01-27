inotifywait --includei '.*\.elm' -r src -m -e modify | while read; do 
  elm make --debug --output build/main.js src/Main.elm                   
done
