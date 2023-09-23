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

const BruteForce = struct {
    const Self = @This();
    passmap:[]u8,
    allocator:std.mem.Allocator,
    map:[]const u8,
    ret:[]u8,

    const numbers = [_]u8{0,1,2,3,4,5,6,7,8,9};
    const lower = [_]u8{'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'};
    const upper = [_]u8{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};
    const special = [_]u8{'!','@','#','$','%','^','&','*','~','+','=','-','_'};
    const upper_lower = lower + upper;
    const upper_lower_numbers = upper_lower + numbers;

    pub fn init(length:usize, map:[]const u8, allocator:std.mem.Allocator) !Self {
        var a = try allocator.alloc(u8, length);
        var ret = try allocator.alloc(u8, length);
        @memset(a, 1);
        return Self {
            .allocator = allocator,
            .passmap = a,
            .ret = ret,
            .map = map,
        };
    }

    fn step(self:Self) bool {
        var ret:bool = true;
        self.passmap[0] += 1;
        
        var x:usize=0;
        while(x < self.passmap.len) : (x += 1) {
            if(self.passmap[x] > self.map.len-1) {
                self.passmap[x] = 1;
                if(x+1 == self.passmap.len) { ret = false;
                } else self.passmap[x+1] += 1;
            }
        }

        return ret;
    }

    pub fn next(self:Self) !?[]u8 {
        if(self.step()) {
            for(0..self.ret.len) |x| {
                self.ret[x] = self.map[self.passmap[x]];
            }
            return self.ret;
        } else return null;
    }

    pub fn deinit(self:Self) void {
        self.allocator.free(self.ret);
        self.allocator.free(self.passmap);
    }
};



pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var bf = try BruteForce.init(4, &BruteForce.lower, allocator);
    
    while (try bf.next()) |pass| {
        std.debug.print("{s}\n", .{pass});
    }
}
