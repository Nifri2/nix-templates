# .dev-fish-setup.fish

function fish_greeting
    echo "MicroPython development environment is set up."
end

function sync
    rshell -p /dev/ttyACM0 rsync . /pyboard/
end

function runpy
    rshell -p /dev/ttyACM0 cp main.py /pyboard/main.py
    rshell -p /dev/ttyACM0 repl "~ import main"
end