#!/usr/bin/bash

install() {
    inst_multiple -o \
        "$systemdutildir"/systemd \
        "$systemdutildir"/systemd-modules-load \
        "$systemdsystemunitdir"/sysinit.target \
        "$systemdsystemunitdir"/basic.target \
        "$systemdsystemunitdir"/initrd.target \
        "$systemdsystemunitdir"/initrd-fs.target \
        "$systemdsystemunitdir"/initrd-root-device.target \
        "$systemdsystemunitdir"/initrd-root-fs.target \
        "$systemdsystemunitdir"/initrd-usr-fs.target \
        "$systemdsystemunitdir"/initrd-switch-root.target \
        "$systemdsystemunitdir"/initrd-switch-root.service \
        "$systemdsystemunitdir"/initrd-cleanup.service \
        "$systemdsystemunitdir"/systemd-modules-load.service \
        "$systemdsystemunitdir"/sysroot.service \
        systemctl mount

    inst_dir /sysroot

    $SYSTEMCTL -q --root "$initdir" set-default initrd.target
    $SYSTEMCTL -q --root "$initdir" add-wants sysinit.target initrd-switch-root.service
    $SYSTEMCTL -q --root "$initdir" add-wants sysinit.target initrd-cleanup.service
    $SYSTEMCTL -q --root "$initdir" add-wants sysinit.target systemd-modules-load.service
    $SYSTEMCTL -q --root "$initdir" add-wants sysinit.target sysroot.service

    local _systemdbinary="$systemdutildir"/systemd

    ln_r "$_systemdbinary" "/init"
    ln_r "$_systemdbinary" "/sbin/init"

    unset _systemdbinary

    # Stuff typical to base
    local VERSION=""
    local PRETTY_NAME=""
    # Derive an os-release file from the host, if it exists
    if [[ -e $dracutsysrootdir/etc/os-release ]]; then
        # shellcheck disable=SC1090
        . "$dracutsysrootdir"/etc/os-release
        grep -hE -ve '^VERSION=' -ve '^PRETTY_NAME' "$dracutsysrootdir"/etc/os-release > "${initdir}"/usr/lib/initrd-release
        [[ -n ${VERSION} ]] && VERSION+=" "
        [[ -n ${PRETTY_NAME} ]] && PRETTY_NAME+=" "
    else
        # Fall back to synthesizing one, since dracut is presently used
        # on non-systemd systems as well.
        {
            echo "NAME=dracut"
            echo "ID=dracut"
            echo "VERSION_ID=\"$DRACUT_VERSION\""
            echo 'ANSI_COLOR="0;34"'
        } > "${initdir}"/usr/lib/initrd-release
    fi
    VERSION+="dracut-$DRACUT_VERSION"
    PRETTY_NAME+="dracut-$DRACUT_VERSION (Initramfs)"
    {
        echo "VERSION=\"$VERSION\""
        echo "PRETTY_NAME=\"$PRETTY_NAME\""
        # This addition is relatively new, intended to allow software
        # to easily detect the dracut version if need be without
        # having it mixed in with the real underlying OS version.
        echo "DRACUT_VERSION=\"${DRACUT_VERSION}\""
    } >> "$initdir"/usr/lib/initrd-release
    echo "dracut-$DRACUT_VERSION" > "$initdir/lib/dracut/dracut-$DRACUT_VERSION"
    ln -sf ../usr/lib/initrd-release "$initdir"/etc/initrd-release
    ln -sf initrd-release "$initdir"/usr/lib/os-release
    ln -sf initrd-release "$initdir"/etc/os-releas
}

