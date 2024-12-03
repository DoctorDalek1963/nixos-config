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

# We use `sudo true` so that just doesn't mkdir pi-mnt until we know the user
# is present to sudo mount the image. It's annoying to need to rmdir this
# folder before I try again if I left it running in the background for a while.

# We have a hardcoded offset=39845888 here because working it out is
# complicated, and it seems like NixOS always creates a 30M boot partition at
# the start, and then the root partition afterwards.

# build the image for the SD card for Bert-NixOS, my Raspberry Pi 4, and copy the secret key to the correct place
build-raspi-sd:
	nom build {{justfile_directory()}}#nixosConfigurations.Bert-NixOS.config.system.build.sdImage
	cp {{justfile_directory()}}/result/sd-image/pi.img pi.img
	chmod u+w pi.img

	sudo true
	mkdir {{justfile_directory()}}/pi-mnt
	sudo mount -o loop,offset=39845888 pi.img {{justfile_directory()}}/pi-mnt/

	fd --one-file-system --hidden --type d -x sudo mkdir -p ./pi-mnt/etc/nixos/{}
	fd --one-file-system --hidden --type f -x sudo cp {} ./pi-mnt/etc/nixos/{}
	fd --one-file-system --hidden --no-ignore --type d . .git/ -x sudo mkdir -p ./pi-mnt/etc/nixos/{}
	fd --one-file-system --hidden --no-ignore --type f . .git/ -x sudo cp {} ./pi-mnt/etc/nixos/{}

	sudo mkdir -p {{justfile_directory()}}/pi-mnt/etc/nixos/sops-secrets
	sudo cp /etc/nixos/sops-secrets/key.txt {{justfile_directory()}}/pi-mnt/etc/nixos/sops-secrets/key.txt

	sudo mkdir -p {{justfile_directory()}}/pi-mnt/etc/nixos/home-manager/sops-secrets
	sudo cp /etc/nixos/home-manager/sops-secrets/key.txt {{justfile_directory()}}/pi-mnt/etc/nixos/home-manager/sops-secrets/key.txt

	sudo umount {{justfile_directory()}}/pi-mnt
	rmdir {{justfile_directory()}}/pi-mnt

# push all store paths for the give system to Cachix
cachix-push-system name:
	cachix watch-exec doctordalek1963 nom -- build {{justfile_directory()}}#nixosConfigurations."{{name}}".config.system.build.toplevel --keep-going --json | jq -r '.[].drvPath' | cachix push doctordalek1963

# push all store paths for Bert-NixOS to Cachix
cachix-push-raspi: (cachix-push-system "Bert-NixOS")

# set the git remote to use my SSH key
set-git-remote:
	git remote rm origin
	git remote add origin github-dd:DoctorDalek1963/nixos-config.git

# make sure everything is set up properly after a fresh install
post-install user='dyson':
	sudo chown -R {{user}}:users /etc/nixos
	chmod -R u+w /etc/nixos
	sudo nixos-rebuild switch
	@just set-git-remote

# copy sops keys to ~/.config/sops/age/keys.txt (WILL OVERWRITE)
copy-sops-keys:
	mkdir -p {{env("HOME")}}/.config/sops/age
	cat {{justfile_directory()}}/sops-secrets/key.txt > {{env("HOME")}}/.config/sops/age/keys.txt
	cat {{justfile_directory()}}/home-manager/sops-secrets/keys/{{env("USER")}}.txt >> {{env("HOME")}}/.config/sops/age/keys.txt

# set authentication token for Cachix
cachix-authtoken:
	cachix authtoken "$(sudo cat /run/secrets/cachix/tokens/doctordalek1963)"
