Welcome to the new QuickCrt version 9.x

At present, I have not yet decided which OpenSource License I will use 
for QuickCrt. It will be either Apache, MIT, GPL v2 or v3. Since 
GPL v3 is the most restrictive, if you conform to its license requirements
for your use of this project, you will be fine.

QuickCrt 9 is a complete rewrite of the previous versions. This
version is 100% assembly code and is designed to be directly
built into asm projects. It also includes, Turbo Pascal unit
wrappers for creating programs in TP5.5 & TP7.0. 

It's goal is to simplify creating text mode console programs. 
At present, it only supports 16-bit DOS. However, eventually, 
I would like to support 32/64-bit Mac, Windows and Linux
consoles as well. 

Requirements:
	NASM 2.11.08 for DOS
	286+ CPU (TargetCPU, 8086 compitibility untested)
	FreeDOS, DosBox or other DOS OS.
	TurboPascal 5.5 (Verion 7.0 recommended) for Pascal
	