gdt_storeGdtInternal:
    add $6, %rcx
    sgdt (%rcx)
    ret

gdt_loadGdtInternal:
    sti
    add $6, %rcx
    lgdt (%rcx)
    mov %r8w, %ds
    mov %r8w, %es
    mov %r8w, %fs
    mov %r8w, %gs
    mov %r8w, %ss
    and $0xFFFF, %rdx
    pushq %rdx
    lea gdt_loadGdtInternal.changeSegmentTarget(%rip), %rax
    pushq %rax
    lretq
gdt_loadGdtInternal.changeSegmentTarget:
    cli
    ret
