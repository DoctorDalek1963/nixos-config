# This script was slightly adapted from
# https://github.com/jnsgruk/nixos-config/blob/675c71cbec13c9166b37595f800129bce74a27e3/scripts/install-with-disko

set -euo pipefail
TARGET_HOST="${1:-}"

print_error() {
	printf "\033[31;1mERROR!\033[0m "
}

print_warning() {
	printf "\033[33;1mWARNING!\033[0m "
}

cd /tmp/nixos-config

if [[ "$(id -u)" -eq 0 ]]; then
	print_error
	echo "$(basename "${0}") should be run as a regular user"
	exit 1
fi

if [[ -z "$TARGET_HOST" ]]; then
	print_error
	echo "$(basename "${0}") requires a hostname as the first argument"
	exit 1
fi

if [[ ! -e "machines/${TARGET_HOST}/disko.nix" ]]; then
	print_error
	echo "$(basename "${0}") could not find the required machines/${TARGET_HOST}/disko.nix"
	exit 1
fi

if [[ ! -e "sops-secrets/key.txt" ]]; then
	print_error
	echo "$(basename "${0}") could not find the system wide sops key in /tmp/nixos-config/sops-secrets/key.txt"
	exit 1
fi

if [[ ! -e "home-manager/sops-secrets/keys/dyson.txt" ]]; then
	print_warning
	echo "$(basename "${0}") could not find the user-level sops key for dyson in /tmp/nixos-config/home-manager/sops-secrets/keys/dyson.txt"

	read -p "Do you want to continue without this secret key? [y/N]" -n 1 -r
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		exit 1
	fi
fi

# grep exits with 1 if nothing is found, but we want to ignore that
set +e
password_files="$(grep -Po '(?<=passwordFile = ")[^"]+(?=";)' "machines/${TARGET_HOST}/disko.nix" | uniq)"
set -e

if [[ -n "$password_files" ]]; then
	while IFS= read -r password_file; do
		if [[ ! -f "$password_file" ]]; then
			print_error
			echo "${TARGET_HOST} requires a LUKS password in ${password_file} but this file was not found"
			echo "Please write to this file with \`set-password ${password_file}\` and try again"
			exit 1
		fi
	done <<< "$password_files"
fi

print_warning
echo "All the disks on this machine are about to get wiped"
echo "         NixOS will be re-installed and this machine will become ${TARGET_HOST}"
echo "         This is a destructive operation"
echo
read -p "Are you sure? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	sudo disko --mode disko "machines/${TARGET_HOST}/disko.nix"

	# Rsync my nix-config to the target install
	sudo mkdir -p "/mnt/etc/nixos"
	sudo rsync -a --delete "/tmp/nixos-config/" "/mnt/etc/nixos"

	sudo nixos-install --flake ".#${TARGET_HOST}" --show-trace
else
	echo "Cancelling installation"
	exit 1
fi
