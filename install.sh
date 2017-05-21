#!/bin/bash

prefix='/usr/local'
arg="$1"
if [ -n "$arg" ]; then
	if [ "${arg%=*}" = '--prefix' ]; then
		prefix="${arg#*=}"
		prefix="${prefix%*/}"
	elif [ "$arg" = '-h' -o "$arg" = '--help' ]; then
		echo "Usage: ./install.sh [ --prefix=/usr ]"
		exit 0
	else
		echo "Invalid argument. Try ./install.sh --help." 1>&2
		exit 1
	fi
else
	binpath="$( which 'caudec' 2>/dev/null )"
	if [ -n "$binpath" ]; then
		bindir="$( dirname "$binpath" )"
	fi
fi

if [ -z "$bindir" ]; then
	if [ "$prefix" = '/usr/local' -o "$prefix" = '/usr' ]; then
		bindir="${prefix}/bin"
	elif [ -d "${prefix}/bin" ]; then
		bindir="${prefix}/bin"
	else
		bindir="$prefix"
	fi
fi

if [ ! -d "$bindir" ]; then
	mkdir -p "$bindir" ; ec=$?
	if [ $ec -ne 0 ]; then
		echo "Failed to create ${bindir}. Installation aborted. Try again as root." 1>&2
		exit 1
	fi
fi

if [ ! -w "$bindir" ]; then
	echo "$bindir isn't writable. Try again as root, or with a different --prefix." 1>&2
	exit 1
fi

if [ -e '/etc/caudecrc' ]; then
	caudecrcPath='/etc/caudecrc'
elif install -m 0644 'caudecrc' '/etc' &>/dev/null; then
	caudecrcPath='/etc/caudecrc'
else
	if [ ! -e "${HOME}/.caudecrc" ]; then
		install -m 0644 'caudecrc' "${HOME}/.caudecrc"
	fi
	caudecrcPath="${HOME}/.caudecrc"
fi

install -m 0755 'caudec' "$bindir" &&
rm -f "${bindir}/decaude" &&
ln -s 'caudec' "${bindir}/decaude" &&
install -m 0755 'APEv2' "$bindir" &&
echo "caudec, decaude and APEv2 installed in $bindir. See $caudecrcPath for configuration."
if [ "$caudecrcPath" = '/etc/caudecrc' ]; then
	echo "You may also copy /etc/caudecrc to ~/.caudecrc."
fi
