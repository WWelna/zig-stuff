const std = @import("std");

pub fn LinkedList(comptime T: type) type {
    return struct {
        const Self = @This();
        const Node = struct {
            data: T,
            next: ?*Node,
        };

        allocator: std.mem.Allocator,
        N: ?*Node,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self {
                .allocator = allocator,
                .N = null,
            };
        }

        pub fn add(self: *Self, data: T) !void {
            var node = try self.allocator.create(Node);
            node.* = Node { .data = data, .next = self.N };
            self.N = node;
        }

        pub fn pop(self: *Self) ?*Self.Node {
            var t:?*Self.Node = self.N;
            if(t) |x| {
                self.N = x.next;
                return x;
            }
            return null;
        }

        pub fn count(self: *Self) usize {
            var x:usize = 0;
            var it: ?*Self.Node = self.N;
            while(it) |N| : (it = N.next) {x += 1;}
            return x; 
        }
    };
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    
    var ll = LinkedList(u32).init(allocator);
    try ll.add(42);
    try ll.add(777);
    try ll.add(9001);
    var r = ll.pop();
    if(r) |x| { std.debug.print("POP: {}\n", .{x.data}); allocator.destroy(x); } // allocator.destroy(r.?);
    
    std.debug.print("SIZE: {}\n", .{ll.count()});

    var it = ll.N;
    while(it) |N| : (it = N.next) {
        std.debug.print("DATA: {}\n", .{N.data});
    }

}