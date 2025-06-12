const std = @import("std");

const e_lfanew = 0x3c;

const PEHeader = packed struct {
    Magic:u32, // PE\0\0
    Machine:u16,
    NumberOfSections:u16,
    TimeDateStamp:u32,
    PointerToSymbolTable:u32,
    NumberOfSymbols:u32,
    SizeOfOptionalHeader:u16,
    mCharacteristics:u16,
};

const PE32OptionalHeader = packed struct {
	Magic:u16, // 0x010b - PE32, 0x020b - PE32+ (64 bit)
	MajorLinkerVersion:u8,
	MinorLinkerVersion:u8,
	SizeOfCode:u32,
	SizeOfInitializedData:u32,
	SizeOfUninitializedData:u32,
	AddressOfEntryPoint:u32,
	BaseOfCode:u32,
	BaseOfData:u32,
	ImageBase:u32,
	SectionAlignment:u32,
	FileAlignment:u32,
	MajorOperatingSystemVersion:u16,
	MinorOperatingSystemVersion:u16,
	MajorImageVersion:u16,
	MinorImageVersion:u16,
	MajorSubsystemVersion:u16,
	MinorSubsystemVersion:u16,
	Win32VersionValue:u32,
	SizeOfImage:u32,
	SizeOfHeaders:u32,
	CheckSum:u32,
	Subsystem:u16,
	DllCharacteristics:u16,
	SizeOfStackReserve:u32,
	SizeOfStackCommit:u32,
	SizeOfHeapReserve:u32,
	SizeOfHeapCommit:u32,
	LoaderFlags:u32,
	NumberOfRvaAndSizes:u32,
};

const PE64OptionalHeader = packed struct {
	Magic:u16, // 0x010b - PE32, 0x020b - PE32+ (64 bit)
	MajorLinkerVersion:u8,
	MinorLinkerVersion:u8,
	SizeOfCode:u32,
	SizeOfInitializedData:u32,
	SizeOfUninitializedData:u32,
	AddressOfEntryPoint:u32,
	BaseOfCode:u32,
	ImageBase:u64,
	SectionAlignment:u32,
	FileAlignment:u32,
	MajorOperatingSystemVersion:u16,
	MinorOperatingSystemVersion:u16,
	MajorImageVersion:u16,
	MinorImageVersion:u16,
	MajorSubsystemVersion:u16,
	MinorSubsystemVersion:u16,
	Win32VersionValue:u32,
	SizeOfImage:u32,
	SizeOfHeaders:u32,
	CheckSum:u32,
	Subsystem:u16,
	DllCharacteristics:u16,
	SizeOfStackReserve:u64,
	SizeOfStackCommit:u64,
	SizeOfHeapReserve:u64,
	SizeOfHeapCommit:u64,
	LoaderFlags:u32,
	NumberOfRvaAndSizes:u32,
};

const Image_Data_Directory = packed struct {
    VirtualAddress:u32,
    Size:u32,
};

const Image_Directory_Entry = enum {
    EXPORT,
    IMPORT,
    RESOURCE,
    EXCEPTION,
    SECURITY,
    BASERELOC,
    DEBUG,
    COPYRIGHT,
    ARCHITECTURE,
    GLOBALPTR,
    TLS,
    LOAD_CONFIG,
    IAT,
    DELAYED_IMPORT,
    COM_DESCRIPTOR,
    DOT_NET,
};

const Image_Section_Header = packed struct {
	Name:[8]u8,
	VirtualSize:u32,
	VirtualAddress:u32,
	SizeOfRawData:u32,
	PointerToRawData:u32,
	PointerToRelocations:u32,
	PointerToLinenumbers:u32,
	NumberOfRelocations:u16,
	NumberOfLinenumbers:u16,
	Characteristics:u32,
};

const Image_Import_Descriptor = packed struct {
    OriginalFirstThunk:u32,
    TimeDateStamp:u32,
    ForwarderChain:u32,
    Name:u32,
    FirstThunk:u32,
};

const Image_Bound_Import_Descriptor = packed struct {
    TimeDateStamp:u32,
    OffsetModuleName:u16,
    NumberOfModuleForwarderRefs:u16,
};

const Image_Import_By_Name = packed struct {
    Hint:u16,
    name:u8[80], // Zero Term String
};

const Image_Base_Relocation = packed struct {
    VirtualAddress:u32,
    SizeOfBlock:u32,
};

const Image_Base_Relocation_Entry = packed struct {
    Type:u4,
    RVA:u12,
};

pub fn main() !void {

}

