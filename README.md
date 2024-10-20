# ARITH

Arith is a simple interpreter for a pascal-like language. It's built in Nim for efficiency and simplicity.

## How to install nim?

- ### For Linux and Mac users:

```bash
# Install nim:
curl https://nim-lang.org/choosenim/init.sh -sSf | sh # And follow the instrunctions
# After installation, add nim and it's utilities to your PATH environment variable:
# For bash users
export PATH="$HOME/.local/bin:$PATH"
export PATH="/home/frusadev/.nimble/bin:$PATH"
# For fish users
set --export PATH "$HOME/.local/bin/" $PATH
set -ga fish_user_paths /home/frusadev/.nimble/bin
```

- ### For Windows users:

Its more simple. Download and extract nim then add to PATH with the environment variables utility.

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
- [ ] Variable and block declarations
- [ ] Conditions
- [ ] Loops
- [ ] Function declarations and call
