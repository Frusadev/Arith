# ARITH

Arith is an interpreter for a simple programming language. It's built in Nim for efficiency and simplicity.

## How to install nim?

- ### For Linux and Mac users:

```bash
# Install nim:
curl https://nim-lang.org/choosenim/init.sh -sSf | sh # And follow the instrunctions
# After installation, add nim and it's utilities to your PATH environment variable:
# For bash users
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.nimble/bin:$PATH"
# For fish users
set --export PATH "$HOME/.local/bin/" $PATH
set -ga fish_user_paths $HOME/.nimble/bin
```

- ### For Windows users:

It's simpler here! Download and extract nim to a folder then add it to PATH using the environment variables utility.

More instructions here: [Install nim on windows](https://nim-lang.org/install_windows.html)

## Compiling.

```bash
git clone https://github.com/Frusadev/Arith.git
cd Arith
nimble build -d:release
# Run
./arith
```



## TO-DO

- [x] Implement basic arithmetic
- [X] Variable and block declarations
- [ ] Custom types (objects)
- [ ] Conditions
- [ ] Loops
- [ ] Function declarations and call
