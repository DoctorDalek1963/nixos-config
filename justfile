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

# make sure everything is set up properly after a fresh install
post-install:
	sudo chown -R dyson:users /etc/nixos
	chmod -R u+w /etc/nixos
	sudo nixos-rebuild switch
	@just set-git-remote
	@just bootstrap-home-manager

# copy sops keys to ~/.config/sops/age/keys.txt (WILL OVERWRITE)
copy-sops-keys:
	mkdir -p {{env("HOME")}}/.config/sops/age
	cat {{justfile_directory()}}/sops-secrets/key.txt > {{env("HOME")}}/.config/sops/age/keys.txt
	cat {{justfile_directory()}}/home-manager/dyson/sops-secrets/key.txt >> {{env("HOME")}}/.config/sops/age/keys.txt
