MEMORY
{
  flash (rx): ORIGIN = 0x08000000, LENGTH = 1024K
  ram (rwx) : ORIGIN = 0x20000000, LENGTH = 320K
}

SECTIONS
{
  .vectors : AT(0) {
    KEEP(*(__VECTORS*))
  } >flash

  .text : ALIGN(16) {
    _stext = .;
    *(.text*)
    _etext = .;
  } >flash
}

ENTRY(reset)
