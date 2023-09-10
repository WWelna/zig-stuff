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

pub fn HeapsAlgo(numberlist:*std.ArrayList([5]u32), n:[5]u32, len:u32) !void {
    var numbers = n;
    if (len == 1) try numberlist.append(n);

    for(0..len) |x| {
        try HeapsAlgo(numberlist, numbers, len-1);

        if (len%2 == 1) {
            var tmp:u32 = numbers[0];
            numbers[0] = numbers[len-1];
            numbers[len-1] = tmp;
        } else {
            var tmp:u32 = numbers[x];
            numbers[x] = numbers[len-1];
            numbers[len-1] = tmp;
        }
    }
}

fn dump(data:[]const u32) void {
    std.debug.print("( ", .{});
    for (0..@truncate(data.len)) |x| std.debug.print("{},", .{data[x]});
    std.debug.print(" )\n", .{});
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    
    var numberlist = std.ArrayList([5]u32).init(allocator);
    try HeapsAlgo(&numberlist, [5]u32{0x01,0x02,0x03,0x04,0x05}, 5);
    
    for (numberlist.items) |x| dump(&x);
}
