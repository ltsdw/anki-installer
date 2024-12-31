#! /bin/sh

#######################################################################################

remove_mime_references="y" # say y here if you want to remove mime references
PREFIX="$HOME/.local/opt/Anki"

major=24
minor=11
ver=${major}.${minor}
pkg_name="anki-${ver}-linux-qt5"
url="https://github.com/ankitects/anki/releases/download/${ver}/${pkg_name}.tar.zst"
pkg_dir="$(pwd)"
src_dir="$pkg_dir/src"

#######################################################################################

download()
{
    pkg_tar="${pkg_name}.tar.zst"

    ! [ -f "${pkg_tar}" ] && curl -L ${url} -o ${pkg_tar}

    rm -rf "${src_dir}/${pkg_name}"

    ! [ -d "${src_dir}" ] && mkdir "${src_dir}"

    tar xvf ${pkg_tar} -C "${src_dir}"
}

install_()
{
    download

    cd "${src_dir}"

    export PREFIX="${PREFIX}"

    ! [ -d "${PREFIX}" ] && mkdir -p "${PREFIX}"

    BIN_DIR="${PREFIX}/bin"

    [ "${remove_mime_references}" = "y" ] && patch -d "${pkg_name}" -p1 -i "${pkg_dir}/remove-mime-references.patch"

    cd "${pkg_name}"

    ./install.sh

    if [ -L "${BIN_DIR}/anki" ]; then
        echo "Anki was installed at ${BIN_DIR}/anki."
        echo "Remember to add \"export PATH=\$PATH:$BIN_DIR\" to your .bashrc, .xinitrc or whataever other you use."
    else
        echo "Anki was not installed."
    fi
}

uninstall_()
{
    cd "${src_dir}/${pkg_name}"

    export PREFIX=${PREFIX}

    ./uninstall.sh
}

case "$1" in
    "--install"   ) install_;;
    "--uninstall" ) uninstall_;;
    *             ) echo "--install to install it.\n--uninstall to remove it."
esac
