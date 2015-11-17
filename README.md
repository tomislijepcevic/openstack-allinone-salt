# Before install
1. Run script make-symlinks.sh, which will make symbolic links for folders in folder *formulas/*.

2. Copy symbolic directories and directory formulas to Salt's directory.

# Install
On master run:

    salt '*' state.highstate
