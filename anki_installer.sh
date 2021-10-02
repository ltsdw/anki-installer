#! /bin/sh

#######################################################################################

should_patch="y" # say n if doesn't want remove mime references
PREFIX="$HOME/.local"

major=2.1
minor=48
ver=$major.$minor
url="https://github.com/ankitects/anki/releases/download/$ver/anki-$ver-linux.tar.bz2"
pkg_name="anki-$ver-linux"
pkg_dir="$(pwd)"
src_dir="$pkg_dir/src"

#######################################################################################

download()
{
    pkg_tar="$pkg_name.tar.bz2"

    ! [ -f "$pkg_tar" ] && curl -L $url -o $pkg_tar

    rm -rf "$src_dir/$pkg_name"

    ! [ -d "$src_dir" ] && mkdir "$src_dir"

    tar xvf $pkg_tar -C "$src_dir"
}

install_()
{
    download

    cd "$src_dir"

    export $PREFIX

    BIN_DIR="$PREFIX/bin"

    ! [ -d "$PREFIX/opt" ] && mkdir -p "$PREFIX/opt"

    [ "$should_patch" = "y" ] && patch -d "$pkg_name" -p1 -i "$pkg_dir/remove-mime-references.patch"

    cd "$pkg_name"

    ./install.sh

    if [ -L "$BIN_DIR/anki" ]; then 
        echo "Anki was installed at $BIN_DIR/anki."
        echo "Remember to add \"export PATH=\$PATH:$BIN_DIR\" to your .bashrc, .xinitrc or whataever other you use."
    else
        echo "Anki was not installed."
    fi
}

uninstall_()
{
    cd "$src_dir/$pkg_name"

    export $PREFIX

    ./uninstall.sh
}

case "$1" in
    ""            ) install_;;
    "--install"   ) install_;;
    "--uninstall" ) uninstall_;;
    *             ) echo "--install to install it.\n--uninstall to remove it."
esac
