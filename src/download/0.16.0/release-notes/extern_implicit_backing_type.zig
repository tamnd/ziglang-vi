const Enum = enum { a, b, c, d };
const PackedStruct = packed struct { a: u4, b: u4 };
const PackedUnion = packed union { a: u8, b: i8 };

export var some_enum: Enum = .a;
export var some_packed_struct: PackedStruct = .{ .a = 1, .b = 2 };
export var some_packed_union: PackedUnion = .{ .a = 123 };

// test_error=unable to export type
