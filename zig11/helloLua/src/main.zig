const std = @import("std");
const Lua = @import("lua.zig").Lua;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var L = try Lua.init(allocator);
    defer L.deinit();
    L.openLibs();

    try Lua.loadString(&L, "print(\"Hello Turtles!\")");
    try Lua.protectedCall(&L, 0, 0, 0);
}

