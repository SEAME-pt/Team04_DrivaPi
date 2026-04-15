OUTPUT_FORMAT("elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(__txm_module_preamble)

MEMORY
{
  FLASH (rx)  : ORIGIN = 0x00000000, LENGTH = 256K
  RAM   (rwx)  : ORIGIN = 0x20000000, LENGTH = 64K
}

SECTIONS
{
  . = ORIGIN(FLASH);
  __FLASH_segment_start__ = .;

  .preamble :
  {
    KEEP(*(.preamble))
  } > FLASH

  .text :
  {
    *(.text*)
    *(.rodata*)
    *(.glue_7)
    *(.glue_7t)
    *(.eh_frame)
  } > FLASH

  .got :
  {
    __got_load_start__ = .;
    *(.got*)
  } > FLASH

  .data_load :
  {
    __data_load_start__ = .;
    *(.data*)
  } > FLASH

  __FLASH_segment_end__ = .;

  . = ORIGIN(RAM);
  __RAM_segment_start__ = .;

  .new_got (NOLOAD) :
  {
    __new_got_start__ = .;
    . = . + SIZEOF(.got);
    __new_got_end__ = .;
  } > RAM

  .data (NOLOAD) :
  {
    __data_start__ = .;
    *(.ram_data*)
    . = ALIGN(4);
    __data_end__ = .;
  } > RAM

  .bss (NOLOAD) :
  {
    __bss_start__ = .;
    *(.bss*)
    *(COMMON)
    . = ALIGN(4);
    __bss_end__ = .;
  } > RAM

  .heap (NOLOAD) :
  {
    __heap_start__ = .;
    . = . + 0x400;
    __heap_end__ = .;
  } > RAM

  __code_start__ = __FLASH_segment_start__;
  __code_size__ = __FLASH_segment_end__ - __FLASH_segment_start__;
  __data_size__ = __heap_end__ - __RAM_segment_start__;
}
