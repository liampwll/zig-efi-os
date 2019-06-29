fat.img: bootx64.efi
	dd if=/dev/zero of=fat.img bs=1k count=1440
	mformat -i fat.img -f 1440 ::
	mmd -i fat.img ::/EFI
	mmd -i fat.img ::/EFI/BOOT
	mcopy -i fat.img bootx64.efi ::/EFI/BOOT

bootx64.efi:
	zig build-exe ./src/boot.zig \
		--enable-pic \
		-target x86_64-uefi-msvc \
		--disable-gen-h \
		--verbose-link \
		--subsystem efi_application \
		--disable-valgrind \
		--name bootx64 \
		--assembly ./src/gdt.s

run: fat.img
	qemu-system-x86_64 -bios /run/libvirt/nix-ovmf/OVMF_CODE.fd -cpu kvm64 -vga cirrus -hdb ./fat.img -enable-kvm

run_debug: fat.img
	qemu-system-x86_64 -bios /run/libvirt/nix-ovmf/OVMF_CODE.fd -cpu kvm64 -vga cirrus -monitor stdio -serial tcp::6666,server -s -hdb ./fat.img -enable-kvm

clean:
	rm -f fat.img main.obj BOOTX64.EFI BOOTX64.lib
