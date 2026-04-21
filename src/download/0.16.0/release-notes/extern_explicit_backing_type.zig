const Enum = enum(u8) { a, b, c, d };
const PackedStruct = packed struct(u8) { a: u4, b: u4 };
const PackedUnion = packed union(u8) { a: u8, b: i8 };

export var some_enum: Enum = .a;
export var some_packed_struct: PackedStruct = .{ .a = 1, .b = 2 };
export var some_packed_union: PackedUnion = .{ .a = 123 };

// test
