Disk Access and How It Works
===========================

Disk access in real mode is typically performed using BIOS interrupts, such as INT 0x13. The BIOS provides routines for reading and writing sectors on disks, abstracting away the hardware details. The bootloader can use these interrupts to load additional data from disk into memory.

Key points:

- INT 0x13 is used for low-level disk operations (read, write, format)
- Disk geometry (cylinders, heads, sectors) must be specified
- Data is transferred to/from memory using segment:offset addressing
- Error handling is performed via BIOS return codes

Disk Geometry and Sector Sizes
-----------------------------

Disks are organized into tracks, heads, and sectors:

- **Track**: A circular path on the disk surface where data is magnetically recorded.
- **Head**: The read/write device for a disk surface. Multi-headed drives have several heads, one for each surface.
- **Sector**: The smallest addressable unit on a disk, typically 512 bytes in size.

To read or write data, the BIOS interrupt requires you to specify the cylinder (track), head, and sector number. For example, to read sector 1 from head 0 on track 0, you provide these values to INT 0x13. The combination of these parameters allows precise access to any part of the disk.

Most bootloaders read the first sector (the boot sector) using these parameters, and may read additional sectors to load more code or data as needed.

This mechanism allows bootloaders to load the next stage of the OS or kernel from disk, making it a critical part of the boot process.

Logical Block Addressing (LBA)
-----------------------------

Modern disks and BIOSes often support Logical Block Addressing (LBA), which simplifies disk access by treating the disk as a linear array of blocks (sectors), rather than using the traditional cylinder-head-sector (CHS) scheme. With LBA, each sector is assigned a unique number starting from zero, making it easier for software to calculate and access disk locations.

Key points about LBA:

- LBA eliminates the need to specify cylinder, head, and sector numbers.
- INT 0x13 supports LBA commands on newer BIOSes and drives.
- Bootloaders and operating systems can use LBA for more reliable and larger disk access.

LBA is now the standard for most modern systems, but understanding CHS is still important for legacy compatibility and low-level disk operations.

Calculating LBA Addresses
------------------------

To convert traditional CHS (Cylinder, Head, Sector) values to an LBA (Logical Block Addressing) value, use the following formula:

	LBA = (cylinder × heads_per_cylinder + head) × sectors_per_track + (sector - 1)

Where:
	- cylinder: The track number
	- head: The head number
	- sector: The sector number (starting from 1)
	- heads_per_cylinder: Number of heads (surfaces) per cylinder
	- sectors_per_track: Number of sectors per track

This formula allows software to map CHS coordinates to a linear LBA sector number, which is then used for disk operations. Modern BIOS and hardware typically handle this conversion internally, but understanding it is useful for low-level programming and legacy systems.

Read and Write Disk Interrupts (x86 Real Mode)
----------------------------------------------

In x86 real mode, disk operations are performed using BIOS interrupt `INT 0x13`. This interrupt provides several functions for reading and writing sectors on disks.

**Read Sectors (Function 02h) Parameters:**

================= ==============================
Register          Description
================= ==============================
AH                0x02 (function: read)
AL                Number of sectors to read
CH                Cylinder (track) number
CL                Sector number (starts at 1)
DH                Head number
DL                Drive number
ES:BX             Buffer address for data
================= ==============================

**Write Sectors (Function 03h) Parameters:**

================= ===============================
Register          Description
================= ===============================
AH                0x03 (function: write)
AL                Number of sectors to write
CH                Cylinder (track) number
CL                Sector number (starts at 1)
DH                Head number
DL                Drive number
ES:BX             Buffer address with data
================= ===============================

.. note::
   The DL register (drive number) is automatically set by the BIOS when the bootloader starts. For example, 0x00 typically refers to the first floppy drive, and 0x80 refers to the first hard disk. The bootloader can use this value directly to access the boot device.
