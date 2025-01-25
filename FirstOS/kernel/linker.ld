OUTPUT_FORMAT("binary")
ENTRY(start)

SECTIONS
{
    . = 0x7C00;
    .text : {
        *(.text)
    }
    
    .rodata : {
        *(.rodata)
        *(.data)
    }
    
    .sig : AT(0x7DFE) {
        SHORT(0xAA55)
    }
}
