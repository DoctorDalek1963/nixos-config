_default:
	@just --list

# build the ISO image for a bootable USB, without secrets
build-iso:
	nom build {{justfile_directory()}}#nixosConfigurations.iso.config.system.build.isoImage

# We include the secrets by using path:, which will include everything in this
# directory, including all git artifacts and any other unstaged and uncommitted files

# build the ISO image for a bootable USB, and include the necessary sops secrets
build-iso-with-secrets:
	nom build path:{{justfile_directory()}}#nixosConfigurations.iso.config.system.build.isoImage

# bootstrap home-manager for dyson
bootstrap-home-manager:
	nix run /etc/nixos/home-manager/dyson -- --flake /etc/nixos/home-manager/dyson switch

# set the git remote to use my SSH key
set-git-remote:
	git remote rm origin
	git remote add origin github-dd:DoctorDalek1963/nixos-config.git
	git branch --set-upstream-to=origin/main main

# make sure everything is set up properly after a fresh install
post-install:
	sudo chown -R dyson:users /etc/nixos
	chmod -R u+w /etc/nixos
	sudo nixos-rebuild switch
	@just set-git-remote
	@just bootstrap-home-manager

# resize the disks on this machine to reflect the current state of the disko.nix file
disko-resize:
	#!/usr/bin/env bash

	disko_file="{{justfile_directory()}}/machines/$(cat /etc/hostname)/disko.nix"

	if [[ ! -f "$disko_file" ]]; then
		echo "ERROR! $disko_file not found"
		exit 1
	fi

	echo "WARNING! You are about to resize the disks on this machine to reflect $disko_file"
	echo "         This should maintain any existing data, but data loss is a very real possibility"
	echo "         Make sure to back up any important files"
	echo "         It would be a good idea to create a recovery ISO with NixOS and secrets just in case"
	echo
	read -p "Are you sure you want to continue? [y/N] " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		sudo disko --mode mount
	fi
