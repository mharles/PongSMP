SET PATH=D:\Facultate\Anul 3\Semestrul 2\SM\UASM;%PATH%
uasm64.exe -bin pong.asm
SET PATH=C:\Program Files\qemu;%PATH%
qemu-system-i386 -hda pong.bin

