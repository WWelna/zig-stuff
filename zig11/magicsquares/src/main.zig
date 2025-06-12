// Copyright (C) 2023 William Welna (wwelna@occultusterra.com)

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

const std = @import("std");

const Magicks = struct {
    nummap:std.ArrayList(u32),
    allocator:std.mem.Allocator,

    const numbers = [100]u32{
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
        11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
        21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
        31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
        41, 42, 43, 44, 45, 46, 47, 48, 49, 50,
        51, 52, 53, 54, 55, 56, 57, 58, 59, 60,
        61, 62, 63, 64, 65, 66, 67, 68, 69, 70,
        71, 72, 73, 74, 75, 76, 77, 78, 79, 80,
        81, 82, 83, 84, 85, 86, 87, 88, 89, 90,
        91, 92, 93, 94, 95, 96, 97, 98, 99, 100,
    };

    pub fn init(length:usize, allocator:std.mem.Allocator) !Magicks {
        var a = try std.ArrayList(u32).initCapacity(allocator, length);
        try a.appendNTimes(1, length);
        return Magicks {
            .allocator = allocator,
            .nummap = a,
        };
    }

    pub fn validate(nums:[]u32) bool {
        comptime var magick = (5*((std.math.pow(u32, 5, 2)+1)/2));
        for(nums) |x| {
            var t:bool = false;
            for(nums) |y| {
                if(x == y and t == false) { t = true; }
                else if(x == y and t == true) { return false; }
            }
        }
        var sum:u32 = 0;
        for(nums) |x| sum += x;
        if(sum == magick) return true;
        return false;
    }

    fn step(self:Magicks) bool {
        var ret:bool = true;
        self.nummap.items[0] += 1;
        
        var x:u64=0;
        while(x < self.nummap.items.len) : (x += 1) {
            if(self.nummap.items[x] > @as(u32, @truncate(numbers.len))-1) {
                self.nummap.items[x] = 1;
                if(x+1 == self.nummap.items.len) { ret = false;
                } else self.nummap.items[x+1] += 1;
            }
        }

        return ret;
    }

    pub fn nextSet(self:Magicks) !?[]u32 {
        var ret:[]u32 = try self.allocator.alloc(u32, self.nummap.items.len);
        if(self.step()) {
            @memcpy(ret, self.nummap.items);
            return ret;
        } else return null;
    }

    pub fn deinit(self:Magicks) void {
        self.nummap.deinit();
    }
};

pub fn generate_horizontals() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var magicks = try Magicks.init(5, allocator);

    const stdout_writer = std.io.getStdOut().writer();
    var stdout = std.io.bufferedWriter(stdout_writer);

    while(try magicks.nextSet()) |result| {
        if(Magicks.validate(result)) {
            try std.json.stringify(.{result[0],result[1],result[2],result[3],result[4]}, .{}, stdout.writer());
            _ = try stdout.write("\n");
            defer magicks.allocator.free(result);
        }
    }
}

fn dump(data:[]const u32) !void {
    std.debug.print("( ", .{});
    for (0..@truncate(data.len)) |x| {
        std.debug.print("{},", .{data[x]});
    }
    std.debug.print(" )\n", .{});
}

pub fn main() !void {
    try generate_horizontals();
}