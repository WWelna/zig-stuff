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

const SkipJack = struct {
    key:[10]u8,
    key_lookup:[32][4]u8,
    ftable:[256]u8,
    s3cr3ts:[64]u8 = [64]u8{
        0xea,0xff,0x52,0x64,0x89,0xaf,0x77,0x4b,0xe9,0x52,0x82,0x8c,0x3b,0xcc,0x47,0xdb,
        0xd1,0xc0,0x8b,0xb,0x9a,0x9,0x5f,0xa,0x8f,0x8f,0x17,0xa1,0x1b,0x5c,0x8a,0x5,
        0xe5,0x66,0x9a,0xdf,0xbe,0x6b,0xd9,0x7,0x55,0xf,0x1e,0xb0,0x9b,0xd7,0x20,0x65,
        0xc8,0xf1,0xd2,0x8c,0xf,0x26,0xa8,0x5,0xb4,0xbe,0x9e,0xbb,0xba,0x33,0x13,0xe5
    },
    allocator:std.mem.Allocator,

    pub fn init(k:[10]u8, allocator:std.mem.Allocator) SkipJack {
        @setRuntimeSafety(false);
        var klu:[32][4]u8 = undefined;
        for(0..32) |x| {
            klu[x][0] = k[((x<<2))%10];
            klu[x][1] = k[((x<<2)+1)%10];
            klu[x][2] = k[((x<<2)+2)%10];
            klu[x][3] = k[((x<<2)+3)%10];
        }
        return SkipJack{
            .key = k,
            .key_lookup = klu,
            .allocator = allocator,
            .ftable = [256]u8 {
            0xa3,0xd7,0x09,0x83,0xf8,0x48,0xf6,0xf4,0xb3,0x21,0x15,0x78,0x99,0xb1,0xaf,0xf9,
            0xe7,0x2d,0x4d,0x8a,0xce,0x4c,0xca,0x2e,0x52,0x95,0xd9,0x1e,0x4e,0x38,0x44,0x28,
            0x0a,0xdf,0x02,0xa0,0x17,0xf1,0x60,0x68,0x12,0xb7,0x7a,0xc3,0xe9,0xfa,0x3d,0x53,
            0x96,0x84,0x6b,0xba,0xf2,0x63,0x9a,0x19,0x7c,0xae,0xe5,0xf5,0xf7,0x16,0x6a,0xa2,
            0x39,0xb6,0x7b,0x0f,0xc1,0x93,0x81,0x1b,0xee,0xb4,0x1a,0xea,0xd0,0x91,0x2f,0xb8,
            0x55,0xb9,0xda,0x85,0x3f,0x41,0xbf,0xe0,0x5a,0x58,0x80,0x5f,0x66,0x0b,0xd8,0x90,
            0x35,0xd5,0xc0,0xa7,0x33,0x06,0x65,0x69,0x45,0x00,0x94,0x56,0x6d,0x98,0x9b,0x76,
            0x97,0xfc,0xb2,0xc2,0xb0,0xfe,0xdb,0x20,0xe1,0xeb,0xd6,0xe4,0xdd,0x47,0x4a,0x1d,
            0x42,0xed,0x9e,0x6e,0x49,0x3c,0xcd,0x43,0x27,0xd2,0x07,0xd4,0xde,0xc7,0x67,0x18,
            0x89,0xcb,0x30,0x1f,0x8d,0xc6,0x8f,0xaa,0xc8,0x74,0xdc,0xc9,0x5d,0x5c,0x31,0xa4,
            0x70,0x88,0x61,0x2c,0x9f,0x0d,0x2b,0x87,0x50,0x82,0x54,0x64,0x26,0x7d,0x03,0x40,
            0x34,0x4b,0x1c,0x73,0xd1,0xc4,0xfd,0x3b,0xcc,0xfb,0x7f,0xab,0xe6,0x3e,0x5b,0xa5,
            0xad,0x04,0x23,0x9c,0x14,0x51,0x22,0xf0,0x29,0x79,0x71,0x7e,0xff,0x8c,0x0e,0xe2,
            0x0c,0xef,0xbc,0x72,0x75,0x6f,0x37,0xa1,0xec,0xd3,0x8e,0x62,0x8b,0x86,0x10,0xe8,
            0x08,0x77,0x11,0xbe,0x92,0x4f,0x24,0xc5,0x32,0x36,0x9d,0xcf,0xf3,0xa6,0xbb,0xac,
            0x5e,0x6c,0xa9,0x13,0x57,0x25,0xb5,0xe3,0xbd,0xa8,0x3a,0x01,0x05,0x59,0x2a,0x46
        }};
    }

    pub fn block_encrypt(self:SkipJack, block:[8]u8) [8]u8 {
        @setRuntimeSafety(false);
        //var startTime:u64 = @intCast(std.time.microTimestamp());
        var w1:u32 = ((@as(u32, block[0]))<<8)|(@as(u32, block[1]));
        var w2:u32 = ((@as(u32, block[2]))<<8)|(@as(u32, block[3]));
        var w3:u32 = ((@as(u32, block[4]))<<8)|(@as(u32, block[5]));
        var w4:u32 = ((@as(u32, block[6]))<<8)|(@as(u32, block[7]));
        var k:u32 = 0;
        var ret:[8]u8 = undefined;

        var x:u32 = 0;
        while (x < 2) : (x += 1) {
            
            var y:u32 = 0;
            while (y < 8) : (y += 1) {
                //std.debug.print("1E {} {x}{x} {x}{x}\n", .{k,w1,w2,w3,w4});
                var tmp:u32 = w4;
                w4 = w3; w3 = w2;
                w2 = blk: {
                    var g2:u32 = (w1&0xff);
                    var g3:u32 = (self.ftable[g2^self.key_lookup[k][0]]^((w1>>8)&0xff));
                    var g4:u32 = (self.ftable[g3^self.key_lookup[k][1]]^g2);
                    var g5:u32 = (self.ftable[g4^self.key_lookup[k][2]]^g3);
                    var g6:u32 = (self.ftable[g5^self.key_lookup[k][3]]^g4);
                    break :blk (g5<<8)|(g6);
                };
                w1 = w2^tmp^(k+1);
                k += 1;
            }

            y=0;
            while (y < 8) : (y += 1) {
                //std.debug.print("2E {} {x}{x} {x}{x}\n", .{k,w1,w2,w3,w4});
                var tmp:u32 = w4;
                w4 = w3;
                w3 = w1^w2^(k+1);
                w2 = blk: {
                    var g2:u32 = (w1&0xff);
                    var g3:u32 = (self.ftable[g2^self.key_lookup[k][0]]^((w1>>8)&0xff));
                    var g4:u32 = (self.ftable[g3^self.key_lookup[k][1]]^g2);
                    var g5:u32 = (self.ftable[g4^self.key_lookup[k][2]]^g3);
                    var g6:u32 = (self.ftable[g5^self.key_lookup[k][3]]^g4);
                    break :blk (g5<<8)|(g6);
                };
                w1 = tmp;
                k += 1;
            }
        }

        ret[0] = @truncate((w1>>8));
		ret[1] = @truncate(w1);
		ret[2] = @truncate((w2>>8));
		ret[3] = @truncate(w2);
		ret[4] = @truncate((w3>>8));
		ret[5] = @truncate(w3);
		ret[6] = @truncate((w4>>8));
		ret[7] = @truncate(w4);

        //std.debug.print("FIN {} {x}{x} {x}{x}\n", .{k,w1,w2,w3,w4});
        //std.debug.print("[ENC] Skipjack.block_encrypt {}ms\n", .{@intCast(std.time.microTimestamp()-startTime});
        return ret;
    }

    pub fn block_decrypt(self:SkipJack, block:[8]u8) [8]u8 {
        @setRuntimeSafety(false);
        //var startTime:u64 = @intCast(std.time.microTimestamp());
        var w1:u32 = ((@as(u32, block[0]))<<8)|(@as(u32, block[1]));
        var w2:u32 = ((@as(u32, block[2]))<<8)|(@as(u32, block[3]));
        var w3:u32 = ((@as(u32, block[4]))<<8)|(@as(u32, block[5]));
        var w4:u32 = ((@as(u32, block[6]))<<8)|(@as(u32, block[7]));
        var k:u32 = 31;
        var ret:[8]u8 = undefined;

        var x:u32 = 0;
        while (x < 2) : (x += 1) {

            var y:u32 = 0;
            while (y < 8) : (y += 1) {
                //std.debug.print("1D {} {x}{x} {x}{x}\n", .{k,w1,w2,w3,w4});
                var tmp:u32 = blk: {
                    var g2:u32 = ((w2>>8)&0xff);
                    var g3:u32 = (self.ftable[g2^self.key_lookup[k][3]]^(w2&0xff));
                    var g4:u32 = (self.ftable[g3^self.key_lookup[k][2]]^g2);
                    var g5:u32 = (self.ftable[g4^self.key_lookup[k][1]]^g3);
                    var g6:u32 = (self.ftable[g5^self.key_lookup[k][0]]^g4);
                    break :blk (g6<<8)|(g5);
                };
                w2 = tmp^w3^(k+1);
                w3 = w4; w4 = w1; w1 = tmp;
                k -= 1;
            }

            y=0;
            while (y < 8) : (y += 1) {
                //std.debug.print("2D {} {x}{x} {x}{x}\n", .{k,w1,w2,w3,w4});
                var tmp:u32=w1^w2^(k+1);
                w1 = blk: {
                    var g2:u32 = ((w2>>8)&0xff);
                    var g3:u32 = (self.ftable[g2^self.key_lookup[k][3]]^(w2&0xff));
                    var g4:u32 = (self.ftable[g3^self.key_lookup[k][2]]^g2);
                    var g5:u32 = (self.ftable[g4^self.key_lookup[k][1]]^g3);
                    var g6:u32 = (self.ftable[g5^self.key_lookup[k][0]]^g4);
                    break :blk (g6<<8)|(g5);
                };
                w2 = w3; w3 = w4; w4 = tmp;
                k -= 1;
            }
        }
        
        ret[0] = @truncate((w1>>8));
		ret[1] = @truncate(w1);
		ret[2] = @truncate((w2>>8));
		ret[3] = @truncate(w2);
		ret[4] = @truncate((w3>>8));
		ret[5] = @truncate(w3);
		ret[6] = @truncate((w4>>8));
		ret[7] = @truncate(w4);

		//std.debug.print("FIN {} {x}{x} {x}{x}\n", .{k,w1,w2,w3,w4});
        //std.debug.print("[DEC] Skipjack.block_decrypt {}ms\n", .{@intCast(std.time.microTimestamp()-startTime});
		return ret;
    }

    pub fn PKCS7_pack(self:SkipJack, data:[]const u8) ![]u8 {
        @setRuntimeSafety(false);
        //var startTime:u64 = @intCast(std.time.microTimestamp());
        var size:u32 = @as(u32, @truncate(data.len));
        var mod:u32 = (size+1)%8;
        var resize:u32 = blk: {
            if (mod > 0) break :blk (8-mod)+size+1;
            break :blk size+1;
        };
        var ret:[]u8 = try self.allocator.alloc(u8, resize);
        for (0..size) |x| ret[x] = data[x];
        for (size..resize) |x| ret[x] = @truncate(resize-size);
        //std.debug.print("[PKCS7] Skipjack.PKCS7_pack {}ms\n", .{@intCast(std.time.microTimestamp()-startTime});
        return ret;
    }

    pub fn PKCS7_unpack(self:SkipJack, data:[]const u8) ![]u8 {
        @setRuntimeSafety(false);
        //var startTime:u64 = @intCast(std.time.microTimestamp());
        var pad:u32 = @as(u32, @truncate(data.len))-@as(u32, data[@as(u32, @truncate(data.len))-1]);
        var ret:[]u8 = try self.allocator.alloc(u8, pad);
        for (0..pad) |x| ret[x] = data[x];
        //std.debug.print("[PKCS7] Skipjack.PKCS7_unpack {}ms\n", .{@intCast(std.time.microTimestamp()-startTime});
        return ret;
    }

    pub fn encrypt_ecb(self:SkipJack, data:[]u8) ![]u8 {
        @setRuntimeSafety(false);
        std.debug.assert((data.len%8) == 0);
        //var startTime:u64 = @intCast(std.time.microTimestamp());
        var blocks:u64 = data.len / 8;
        var ret:[]u8 = try self.allocator.alloc(u8, data.len);
        for (0..blocks) |x| {
            var s:[8]u8 = undefined;
            var z:u64 = x*8;
            @memcpy(&s, data[z..z+8]);
            @memcpy(ret[z..8], &self.block_encrypt(s));
        }
        //std.debug.print("[ECB] Skipjack.encrypt_ecb {}ms\n", .{@intCast(std.time.microTimestamp()-startTime});
        return ret;
    }

    pub fn decrypt_ecb(self:SkipJack, data:[]u8) ![]u8 {
        @setRuntimeSafety(false);
        std.debug.assert((data.len%8) == 0);
        //var startTime:u64 = @intCast(std.time.microTimestamp());
        var blocks:u64 = data.len / 8;
        var ret:[]u8 = try self.allocator.alloc(u8, data.len);
        for (0..blocks) |x| {
            var s:[8]u8 = undefined;
            var z:u64 = x*8;
            @memcpy(&s, data[z..z+8]);
            @memcpy(ret[z..8], &self.block_decrypt(s));
        }
        //std.debug.print("[ECB] Skipjack.decrypt_ecb {}ms\n", .{@intCast(std.time.microTimestamp()-startTime});
        return ret;
    }
};

test "Skipjack Vectors" {
    const allocator = std.testing.allocator;

    // These are test vectors -> https://archive.org/details/NSA-SKIPJACK-SPEC/page/18/mode/2up
    var test_block = [8]u8 {0x33,0x22,0x11,0x00,0xdd,0xcc,0xbb,0xaa};
    var sj = SkipJack.init([10]u8{0x00,0x99,0x88,0x77,0x66,0x55,0x44,0x33,0x22,0x11}, allocator);
    
    var block_enc = sj.block_encrypt(test_block);
    try std.testing.expect(std.mem.eql(u8, &block_enc, &[8]u8{0x25,0x87,0xca,0xe2,0x7a,0x12,0xd3,0x00}));

    var block_dec = sj.block_decrypt(block_enc);
    try std.testing.expect(std.mem.eql(u8, &test_block, &block_dec));

    var tundra = "Hello, Blackberry!";
    var pked = try sj.PKCS7_pack(tundra);
    defer allocator.free(pked);
    var enc = try sj.encrypt_ecb(pked);
    defer allocator.free(enc);
    var dec = try sj.decrypt_ecb(enc);
    defer allocator.free(dec);
    var unpked = try sj.PKCS7_unpack(dec);
    defer allocator.free(unpked);
    try std.testing.expect(std.mem.eql(u8, tundra, unpked));
}

pub fn main() !void {
    //var startTime:u64 = @intCast(std.time.microTimestamp());
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var testy = [8]u8 {'T', 'U', 'R', 'T', 'L', 'E', 'S', 'S'};
    var hello = [_]u8{0xa6,0xe6,0xfb,0x0,0xa3,0xb7,0xca,0x54,0xcc,0xac,0x17,0x54,0x85,0x11,0x12,0x60,0x77,0xc0,0x85,0x20,0x99,0x27,0x60,0xb8};

    var sj = SkipJack.init([10]u8{0xC0, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xEE, 0xEE, 0xEE}, allocator);
    var hello_unpacked = try sj.PKCS7_unpack(try sj.decrypt_ecb(&hello));

    std.debug.print("{s}{s}\n", .{hello_unpacked, sj.block_decrypt(sj.block_encrypt(testy))});

    //std.debug.print("[+] Skipjack Hello World took {}ms to execute\n", .{@intCast(std.time.microTimestamp()-startTime});
}
