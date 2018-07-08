
Debian
====================
This directory contains files used to package balld/ball-qt
for Debian-based Linux systems. If you compile balld/ball-qt yourself, there are some useful files here.

## ball: URI support ##


ball-qt.desktop  (Gnome / Open Desktop)
To install:

	sudo desktop-file-install ball-qt.desktop
	sudo update-desktop-database

If you build yourself, you will either need to modify the paths in
the .desktop file or copy or symlink your ball-qt binary to `/usr/bin`
and the `../../share/pixmaps/ball128.png` to `/usr/share/pixmaps`

ball-qt.protocol (KDE)

