; *************************
; General x86 Real Mode Memory Map:
;   - 0x00000000 - 0x000003FF - Real Mode Interrupt Vector Table
;   - 0x00000400 - 0x000004FF - BIOS Data Area
;   - 0x00000500 - 0x00007BFF - Unused
;   - 0x00007C00 - 0x00007DFF - Our Stage 1
;   - 0x00007E00 - 0x0009FFFF - Our Stage 2
;   - 0x000A0000 - 0x000BFFFF - Video RAM (VRAM) Memory
;   - 0x000B0000 - 0x000B7777 - Monochrome Video Memory
;   - 0x000B8000 - 0x000BFFFF - Color Video Memory
;   - 0x000C0000 - 0x000C7FFF - Video ROM BIOS
;   - 0x000C8000 - 0x000EFFFF - BIOS Shadow Area
;   - 0x000F0000 - 0x000FFFFF - System BIOS
; *************************
; *************************
;    Real Mode 16-Bit
; - Uses the native Segment:offset memory model
; - Limited to 1MB of memory
; - No memory protection or virtual memory
; *************************
BITS	16							; We are still in 16 bit Real Mode

ORG     0x7E00

main_Stage2: JMP Stage2_Main

;*******************************************************
;	Preprocessor directives 16-BIT MODE
;*******************************************************
%include "../SysBoot/Fat-Stage2/asmlib16.inc"

;*******************************************************
;	Preprocessor Descriptor Tables
;*******************************************************
%include "../SysBoot/Fat-Stage2/Gdt.inc"
%include "../SysBoot/Fat-Stage2/Idt.inc"

;*******************************************************
;	Preprocessor A20
;*******************************************************
%include "../SysBoot/Fat-Stage2/A20.inc"

;******************************************************
;	ENTRY POINT For STAGE 2
;******************************************************
Stage2_Main:
    CLI
    ;-------------------------------;
	;   Setup segments and stack	;
	;-------------------------------;
    XOR     ax, ax
    
    MOV	    ds, ax
    
    MOV	    es, ax
    
    MOV	    fs, ax
    
    MOV	    gs, ax

    MOV	    ss, ax
    
    MOV	    ax, 0x7C00
    
    MOV	    sp, ax
    
    STI
    ; Save Drive Number in DL
    MOV     [bPhysicalDriveNum],dl
    ; "cpuid" retrieve the information about your cpu
    ; eax=0x80000000: Get Highest Extended Function Implemented (only in long mode)
    ; 0x80000000 = 2^31
    MOV     eax,0x80000000
    
    CPUID
    ; Long mode can only be detected using the extended functions of CPUID (> 0x80000000)
    ; It is less, there is no long mode.
    CMP     eax,0x80000001
    ; if eax < 0x80000001 => CF=1 => jb
    ; jb, jump if below for unsigned number
    ; (jl, jump if less for signed number)
    JB  DEATH
    ; eax=0x80000001: Extended Processor Info and Feature Bits
    MOV     eax,0x80000001
    CPUID
    ; check if long mode is supported
    ; test => edx & (1<<29), if result=0, CF=1, then jump
    ; long mode is at bit-29
    TEST    edx,(1<<29) ; We test to check whether it supports long mode
    ; jz, jump if zero => CF=1
    JZ  DEATH
    ; check if 1g huge page support
    ; test => edx & (1<<26), if result=0, CF=1, then jump
    ; Gigabyte pages is at bit-26
    TEST    edx,(1<<26)
    ; jz, jump if zero => CF=1
    JZ  DEATH

.NoLongMode
    JMP     DEATHSCREEN

LoadKernel:
    ; DS:SI (segment:offset pointer to the DAP, Disk Address Packet)
    ; DS is Data Segment, SI is Source Index
    MOV     si,ReadPacket
    ; size of Disk Address Packet (set this to 0x10)
    MOV     word[si],0x10
    ; number of sectors(loader) to read(in this case its 100 sectors for our kernel)
    MOV     word[si+2],100
    ; number of sectors to transfer
    ; transfer buffer (16 bit segment:16 bit offset)
    ; 16 bit offset=0 (stored in word[si+4])
    MOV     word[si+4],0
    ; 16 bit segment=0x1000 (stored in word[si+6])
    ; address => 0x1000 * 16 + 0 = 0x10000
    MOV     word[si+6],0x1000
    ; LBA=6 is the start of kernel sector
    MOV     dword[si+8],6
    
    MOV     dword[si+0xc],0
    ; dl=pysicaldrivenum
    MOV     dl,[bPhysicalDriveNum]
    ; function code, 0x42 = Extended Read Sectors From Drive
    MOV     ah,0x42
    
    INT     0x13
    
    JC      DEATH


;Most Modern Computers already have the A20 line set from the get-go, but if not then we enable it through BIOS
SetA20:
    ;-------------------------------;
	;   Enable A20 Line		        ;
	;-------------------------------;
    CALL EnableA20_Bios
    
    MOV         si, msgA20
    
    CALL        Puts16

SetVideoMode:
    MOV     ax,3
    ; Sets the Video Mode to Text Mode
    INT     0x10

    MOV         si, msgVideoMode
    
    CALL        Puts16
    
    CLI
    ;-------------------------------;
	;   Install our GDT		        ;
	;-------------------------------;
    LGDT    [gdt_descriptor]
    
    MOV         si, msggdt
    
    CALL        Puts16
    ;-------------------------------;
	;   Install our IDT		        ;
	;-------------------------------;
    LIDT    [idt_real]
    
    MOV         si, msgidt
    
    CALL        Puts16
	;-------------------------------;
	;   Go into PMode		        ;
	;-------------------------------;
    MOV     eax,cr0
    
    OR  eax,1
    
    MOV     cr0,eax

    JMP 8:ProtectedMode_Stage3 ; Get outta this cursed Real Mode

DEATH:
DEATHSCREEN:
    MOV         si, ErrorMsg
    
    CALL        Puts16                          ; Error message
    
    MOV         ah, 0x00
    
    INT         0x16                            ; SMACK YOUR ASS ON THAT KEYBOARD AGAIN
    
    INT         0x19                            ; Reboot and try again, bios uses int 0x19 to find a bootable device

ALIGN   32
BITS    32
;*******************************************************
;	Preprocessor directives 32-BIT MODE
;*******************************************************
%include "../SysBoot/Fat-Stage2/asmlib32.inc"
;******************************************************
;	ENTRY POINT For STAGE 3
;******************************************************
ProtectedMode_Stage3:
    ;-------------------------------;
	;   Setup segments and stack	;
	;-------------------------------;
    MOV     ax,0x10
    
    MOV     ds,ax
    
    MOV     es,ax
    
    MOV     ss,ax
    
    MOV     esp,0x7c00

    CLD
    
    MOV     edi,0x80000
    
    XOR     eax,eax
    
    MOV     ecx,0x10000/4
    
    REP     stosd
    
    MOV     dword[0x80000],0x81007
    
    MOV     dword[0x81000],10000111b
    ;-------------------------------;
	;   Install our new GDT		    ;
	;-------------------------------;
    CALL    ClrScr32

    LGDT    [gdt_descriptor_64]
    
    MOV     si, msgNewgdt
    
    CALL    Puts32
    ;-------------------------------;
	;   Get Ready For Long Mode		;
	;-------------------------------;
    MOV     eax,cr4
    
    OR  eax,(1<<5)
    
    MOV     cr4,eax

    MOV     eax,0x80000
    
    MOV     cr3,eax

    MOV     ecx,0xc0000080
    
    RDMSR
    
    OR  eax,(1<<8)
    
    WRMSR

    MOV     eax,cr0
    
    OR  eax,(1<<31)
    
    MOV     cr0,eax

    JMP     8:LMEntry ; Juuummpppppp

PEnd:
    HLT
    
    JMP     PEnd
ALIGN   64
BITS    64
LMEntry:
    ; clear out upper 32 bits of stack to make sure
    ; no intended bits are left up there
    MOV     eax, esp
    
    XOR     rsp, rsp
    
    MOV     rsp, rax
    ;-------------------------------;
	;   Setup segments and stack	;
	;-------------------------------;
    MOV     rsp, 0x7C00

LEnd:
    HLT
    
    JMP LEnd
;*******************************************************
;	Data Section
;*******************************************************
bPhysicalDriveNum			db		0
ErrorMsg                    db  "Hahahaha, Fuck you, but at Stage2"
msgA20                      db  "Enabling A20 Gate", 0x0D, 0x0A, 0x00
msggdt                      db  "Installing gdt", 0x0D, 0x0A, 0x00
msgNewgdt                   db  "Installing gdt", 0x0D, 0x0A, 0x00
msgidt                      db  "Installing idt", 0x0D, 0x0A, 0x00
msgKernelLoaded             db  "Loading the Kernel In", 0x0D, 0x0A, 0x00
msgVideoMode                db  "Setting up Video Mode", 0x0D, 0x0A, 0x00
ReadPacket:                 times 16 db 0
LoadingMsg                  db 0x0D, 0x0A, "Stage 2 Sucessfully Loaded", 0x00
Msg                         db  "Preparing to load operating system...",13,10,0
msgpmode                    db  0x0A, 0x0A, 0x0A, "               <[ OMOS 32-bit 10 ]>"
                            db  0x0A, 0x0A,             "           Basic 32 bit graphics demo in Assembly Language", 0