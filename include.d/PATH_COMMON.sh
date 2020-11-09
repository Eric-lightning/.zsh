PATH_LIST=$(cat << EOF | xargs | sed -e 's/\ /:/g'
$HOME/bin
$HOME/.local/bin
$HOME/local/bin
$HOME/go/bin
$HOME/.cargo/bin
$HOME/.nesc/bin
EOF
)
export PATH="$PATH_LIST:$PATH"

# .local/packages
for i in $(/bin/ls -1 $HOME/.local/packages/)
do
  export PATH="$HOME/.local/packages/${i}/bin:$PATH"
done