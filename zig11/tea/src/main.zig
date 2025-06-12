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

const TEA = struct {
    const Self = @This();
    const delta:u32 = 0x9e3779b9;

    fn block_encrypt(v:[2]u32, k:[4]u32) [2]u32 {
        @setRuntimeSafety(false);
        var n:u32 = 32;
        var sum:u32 = Self.delta * n;
        var ret:[2]u32 = v;
        while(n > 0) : (n -= 1) {
            ret[1] -= ((ret[0]<<4) + k[2]) ^ (ret[0] + sum) ^ ((ret[0]>>5) + k[3]);
            ret[0] -= ((ret[1]<<4) + k[0]) ^ (ret[1] + sum) ^ ((ret[1]>>5) + k[1]);
            sum -= delta;
        }
        return ret;
    }

    fn block_decrypt(v:[2]u32, k:[4]u32) [2]u32 {
        @setRuntimeSafety(false);
        var n:u32 = 32;
        var sum:u32 = 0;
        var ret:[2]u32 = v;
        while(n > 0) : (n -= 1) {
            sum += delta;
            ret[0] += ((ret[1]<<4) + k[0]) ^ (ret[1] + sum) ^ ((ret[1]>>5) + k[1]);
            ret[1] += ((ret[0]<<4) + k[2]) ^ (ret[0] + sum) ^ ((ret[0]>>5) + k[3]);
        }
        return ret;
    }

    pub fn u32tou8(v:[2]u32) [8]u8 {
        var ret:[8]u8 = undefined;
        ret[0] = @truncate(v[0] & 0xFF);
        ret[1] = @truncate(v[0] >> 8 & 0xFF);
        ret[2] = @truncate(v[0] >> 16 & 0xFF);
        ret[3] = @truncate(v[0] >> 24 & 0xFF);
        ret[4] = @truncate(v[1] & 0xFF);
        ret[5] = @truncate(v[1] >> 8 & 0xFF);
        ret[6] = @truncate(v[1] >> 16 & 0xFF);
        ret[7] = @truncate(v[1] >> 24 & 0xFF);
        return ret;
    }

    pub fn u8tou32(d:[8]u8) [2]u32 {
        var ret:[2]u32 = undefined;
        ret[0] = (@as(u32, d[0]) << 24) | (@as(u32, d[1]) << 16) | (@as(u32, d[2]) << 8) | @as(u32, d[3]);
        ret[1] = (@as(u32, d[4]) << 24) | (@as(u32, d[5]) << 16) | (@as(u32, d[6]) << 8) | @as(u32, d[7]);
        return ret;
    }
};

const XTEA = struct {
    const Self = @This();
    const delta:u32 = 0x9e3779b9;

    fn block_encrypt(rounds:u32, v:[2]u32, k:[4]u32) [2]u32 {
        @setRuntimeSafety(false);
        var n:u32 = rounds;
        var sum:u32 = 0;
        var ret:[2]u32 = v;
        while(n > 0) : (n -= 1) {
            ret[0] += (((ret[1] << 4) ^ (ret[1] >> 5)) + ret[1]) ^ (sum + k[sum & 3]);
            sum += delta;
            ret[1] += (((ret[0] << 4) ^ (ret[0] >> 5)) + ret[0]) ^ (sum + k[(sum>>11) & 3]);  
        }
        return ret;
    }

    fn block_decrypt(rounds:u32, v:[2]u32, k:[4]u32) [2]u32 {
        @setRuntimeSafety(false);
        var n:u32 = rounds;
        var sum:u32 = Self.delta*n;
        var ret:[2]u32 = v;
        while(n > 0) : (n -= 1) {
            ret[1] -= (((ret[0] << 4) ^ (ret[0] >> 5)) + ret[0]) ^ (sum + k[(sum>>11) & 3]); 
            sum -= delta;
            ret[0] -= (((ret[1] << 4) ^ (ret[1] >> 5)) + ret[1]) ^ (sum + k[sum & 3]);
        }
        return ret;
    }

    pub fn u32tou8(v:[2]u32) [8]u8 {
        var ret:[8]u8 = undefined;
        ret[0] = @truncate(v[0] & 0xFF);
        ret[1] = @truncate(v[0] >> 8 & 0xFF);
        ret[2] = @truncate(v[0] >> 16 & 0xFF);
        ret[3] = @truncate(v[0] >> 24 & 0xFF);
        ret[4] = @truncate(v[1] & 0xFF);
        ret[5] = @truncate(v[1] >> 8 & 0xFF);
        ret[6] = @truncate(v[1] >> 16 & 0xFF);
        ret[7] = @truncate(v[1] >> 24 & 0xFF);
        return ret;
    }

    pub fn u8tou32(d:[8]u8) [2]u32 {
        var ret:[2]u32 = undefined;
        ret[0] = (@as(u32, d[0]) << 24) | (@as(u32, d[1]) << 16) | (@as(u32, d[2]) << 8) | @as(u32, d[3]);
        ret[1] = (@as(u32, d[4]) << 24) | (@as(u32, d[5]) << 16) | (@as(u32, d[6]) << 8) | @as(u32, d[7]);
        return ret;
    }
};

// TODO: This code is entirely broken and doesn't encrypt/decrypt correctly
const XXTEA = struct {
    const Self = @This();
    const delta:u32 = 0x9e3779b9;

    fn block_encrypt(allocator:std.mem.Allocator, v:[]const u32, k:[4]u32) ![]u32 {
        @setRuntimeSafety(false);
        var ret:[]u32 = try allocator.alloc(u32, v.len);
        @memcpy(ret, v);
        const len:u32 = @truncate(v.len);
        var q:u32 = 6 + 52 / len;
        var sum:u32 = 0;
        var z:u32 = v[len-1];
        var p:u32 = undefined;
        var y:u32 = undefined;
        var e:u32 = undefined;
        while(q > 0) : (q-= 1) {
            sum += Self.delta;
            e = (sum >> 2) & 3;
            p=0;
            while(p < len-1) : (p += 1) {
                y = ret[p+1];
                ret[p] += (((z>>5^y<<2) + (y>>3^z<<4)) ^ ((sum^y) + (k[p&3^e]^z)));
                z = ret[p];
            }
            y = ret[0];
            ret[len-1] += (((z>>5^y<<2) + (y>>3^z<<4)) ^ ((sum^y) + (k[p&3^e]^z)));
            z = ret[len-1];
        }
        return ret;
    }

    fn block_decrypt(allocator:std.mem.Allocator, v:[]u32, k:[4]u32) ![]u32 {
        @setRuntimeSafety(false);
        var ret:[]u32 = try allocator.alloc(u32, v.len);
        @memcpy(ret, v);
        const len:u32 = @truncate(v.len);
        var q:u32 = 6 + 52 / len;
        var sum:u32 = q*Self.delta;
        var z:u32 = undefined;
        var p:u32 = undefined;
        var y:u32 = v[0];
        var e:u32 = undefined;
        while(q > 0) : (q-= 1) {
            e = (sum >> 2) & 3;
            p=len-1;
            while(p > 0) : (p -= 1) {
                z = ret[p-1];
                ret[p] -= (((z>>5^y<<2) + (y>>3^z<<4)) ^ ((sum^y) + (k[p&3^e]^z)));
                y = ret[p];
            }
            
            z = ret[len-1];
            ret[0] -= (((z>>5^y<<2) + (y>>3^z<<4)) ^ ((sum^y) + (k[p&3^e]^z)));
            y = ret[0];
            sum -= Self.delta;
        }
        return ret;
    }

    pub fn u32tou8_32(v:u32) [4]u8 {
        var ret:[8]u8 = undefined;
        ret[0] = @truncate(v & 0xFF);
        ret[1] = @truncate(v >> 8 & 0xFF);
        ret[2] = @truncate(v >> 16 & 0xFF);
        ret[3] = @truncate(v >> 24 & 0xFF);
        return ret;
    }

    pub fn u8tou32_32(d:[4]u8) u32 {
        return (@as(u32, d[0]) << 24) | (@as(u32, d[1]) << 16) | (@as(u32, d[2]) << 8) | @as(u32, d[3]);
    }

    pub fn u32tou8_64(v:[2]u32) [8]u8 {
        var ret:[8]u8 = undefined;
        ret[0] = @truncate(v[0] & 0xFF);
        ret[1] = @truncate(v[0] >> 8 & 0xFF);
        ret[2] = @truncate(v[0] >> 16 & 0xFF);
        ret[3] = @truncate(v[0] >> 24 & 0xFF);
        ret[4] = @truncate(v[1] & 0xFF);
        ret[5] = @truncate(v[1] >> 8 & 0xFF);
        ret[6] = @truncate(v[1] >> 16 & 0xFF);
        ret[7] = @truncate(v[1] >> 24 & 0xFF);
        return ret;
    }

    pub fn u8tou32_64(d:[8]u8) [2]u32 {
        var ret:[2]u32 = undefined;
        ret[0] = (@as(u32, d[0]) << 24) | (@as(u32, d[1]) << 16) | (@as(u32, d[2]) << 8) | @as(u32, d[3]);
        ret[1] = (@as(u32, d[4]) << 24) | (@as(u32, d[5]) << 16) | (@as(u32, d[6]) << 8) | @as(u32, d[7]);
        return ret;
    }

    pub fn u32tou8_128(v:[4]u32) [16]u8 {
        var ret:[16]u8 = undefined;
        ret[0] = @truncate(v[0] & 0xFF);
        ret[1] = @truncate(v[0] >> 8 & 0xFF);
        ret[2] = @truncate(v[0] >> 16 & 0xFF);
        ret[3] = @truncate(v[0] >> 24 & 0xFF);
        ret[4] = @truncate(v[1] & 0xFF);
        ret[5] = @truncate(v[1] >> 8 & 0xFF);
        ret[6] = @truncate(v[1] >> 16 & 0xFF);
        ret[7] = @truncate(v[1] >> 24 & 0xFF);
        ret[8] = @truncate(v[2] & 0xFF);
        ret[9] = @truncate(v[2] >> 8 & 0xFF);
        ret[10] = @truncate(v[2] >> 16 & 0xFF);
        ret[11] = @truncate(v[2] >> 24 & 0xFF);
        ret[12] = @truncate(v[3] & 0xFF);
        ret[13] = @truncate(v[3] >> 8 & 0xFF);
        ret[14] = @truncate(v[3] >> 16 & 0xFF);
        ret[15] = @truncate(v[3] >> 24 & 0xFF);
        return ret;
    }

    pub fn u8tou32_128(d:[16]u8) [4]u32 {
        var ret:[4]u32 = undefined;
        ret[0] = (@as(u32, d[0]) << 24) | (@as(u32, d[1]) << 16) | (@as(u32, d[2]) << 8) | @as(u32, d[3]);
        ret[1] = (@as(u32, d[4]) << 24) | (@as(u32, d[5]) << 16) | (@as(u32, d[6]) << 8) | @as(u32, d[7]);
        ret[2] = (@as(u32, d[8]) << 24) | (@as(u32, d[9]) << 16) | (@as(u32, d[10]) << 8) | @as(u32, d[11]);
        ret[3] = (@as(u32, d[12]) << 24) | (@as(u32, d[13]) << 16) | (@as(u32, d[14]) << 8) | @as(u32, d[15]);
        return ret;
    }

};

const PKCS7 = struct {
    const Self = @This();
    block_size:u32,
    allocator:std.mem.Allocator,

    pub fn init(allocator:std.mem.Allocator, bs:u32) Self {
        return Self {
            .block_size = bs,
            .allocator = allocator,
        };
    }

    pub fn PKCS7_pack(self:Self, data:[]const u8) ![]u8 {
        //@setRuntimeSafety(false);
        var size:u32 = @as(u32, @truncate(data.len));
        var mod:u32 = (size+1)%self.block_size;
        var resize:u32 = blk: {
            if (mod > 0) break :blk (self.block_size-mod)+size+1;
            break :blk size+1;
        };
        //std.debug.print("\n {} {} {} {}\n", .{self.block_size, size, mod, resize});
        var ret:[]u8 = try self.allocator.alloc(u8, resize);
        for (0..size) |x| ret[x] = data[x];
        for (size..resize) |x| ret[x] = @truncate(resize-size);
        //std.debug.print(" {}X{d}\n", .{ret.len, ret[ret.len-1]});
        return ret;
    }

    pub fn PKCS7_unpack(self:Self, data:[]const u8) ![]u8 {
        //@setRuntimeSafety(false);
        var len:u32 = @truncate(data.len);
        var pad:u32 = len - data[len-1];
        //std.debug.print("PAD:{} LEN:{} {d}\n", .{pad, len, data[len-1]});
        var ret:[]u8 = try self.allocator.alloc(u8, pad);
        for (0..pad) |x| ret[x] = data[x];
        return ret;
    }
};

const XXTEA_STRING = struct {
    const Self = @This();
    allocator:std.mem.Allocator,
    key:[4]u32,

    pub fn init(allocator:std.mem.Allocator, key:[4]u32) Self {
        return Self {
            .allocator = allocator,
            .key = key,
        };
    }

    fn u8tou32(self:Self, data:[]const u8) ![]u32 {
        var how_many:u32 = @as(u32, @truncate(data.len)) / 4;
        var ret = try self.allocator.alloc(u32, how_many);

        //std.debug.print("{s}\n", .{data});
        for(0..how_many) |x| {
            ret[x] = (@as(u32, data[x*4]) << 24) | (@as(u32, data[(x*4)+1]) << 16) | (@as(u32, data[(x*4)+2]) << 8) | @as(u32, data[(x*4)+3]);
            //std.debug.print("{}:{x}\n", .{x,ret[x]});
        }

        return ret;
    }

    fn u32tou8(self:Self, data:[]const u32) ![]u8 {
        var how_many:u32 = @as(u32, @truncate(data.len));
        var ret = try self.allocator.alloc(u8, how_many*4);

        for(0..how_many) |x| {
            ret[x*4] = @truncate(data[x] & 0xFF);
            ret[(x*4)+1] = @truncate(data[x] >> 8 & 0xFF);
            ret[(x*4)+2] = @truncate(data[x] >> 16 & 0xFF);
            ret[(x*4)+3] = @truncate(data[x] >> 24 & 0xFF);

        }
        //for(0..ret.len) |x| std.debug.print("{}:{x}\n", .{x,ret[x]});

        return ret;
    }

    pub fn encrypt(self:Self, astring:[]const u8) ![]u8 {
        var len:u32 = @truncate(astring.len);
        var block_size = if ((len % 4) > 0) len+4 else len;
        var pkcs7 = PKCS7.init(self.allocator, block_size);
        
        var pack = try pkcs7.PKCS7_pack(astring);
        defer self.allocator.free(pack);

        var pack_conv = try self.u8tou32(pack);
        defer self.allocator.free(pack_conv);

        var enc = try XXTEA.block_encrypt(self.allocator, pack_conv, self.key);
        defer self.allocator.free(enc);

        return try self.u32tou8(enc);
    }

    pub fn decrypt(self:Self, msg:[]const u8) ![]u8 {
        var pkcs7 = PKCS7.init(self.allocator, 0);
        
        var conv = try self.u8tou32(msg);
        defer self.allocator.free(conv);
        
        var dec = try XXTEA.block_decrypt(self.allocator, conv, self.key);
        defer self.allocator.free(dec);

        var dec_conv = try self.u32tou8(dec);
        defer self.allocator.free(dec_conv);
        
        return try pkcs7.PKCS7_unpack(dec_conv);
    }

};

test "TEA" {
    const k:[4]u32 = .{0xDEAD, 0xDEAD, 0xDEAD, 0xDEAD};
    const b:[2]u32 = .{0x1234, 0x5678};
    var e = TEA.block_encrypt(b, k);
    var d = TEA.block_decrypt(e, k);
    try std.testing.expect(std.mem.eql(u32, &b, &d));
}

test "XTEA" {
    const k:[4]u32 = .{0xDEAD, 0xDEAD, 0xDEAD, 0xDEAD};
    const b:[2]u32 = .{0x1234, 0x5678};
    var e = XTEA.block_encrypt(32, b, k);
    var d = XTEA.block_decrypt(32, e, k);
    try std.testing.expect(std.mem.eql(u32, &b, &d));
}

// TODO: Broken Completly
// test "XXTEA_STRING" {
//     const k:[4]u32 = .{0xDEAD, 0xDEAD, 0xDEAD, 0xDEAD};
//     const b = "I LIEK TURTLES XX\x00";
//     const allocator = std.testing.allocator;
//     var xxtea_string = XXTEA_STRING.init(allocator, k);
    
//     var enc = try xxtea_string.encrypt(b);
//     defer allocator.free(enc);
//     var dec = try xxtea_string.decrypt(enc);
//     defer allocator.free(dec);

//     std.debug.print("\n ENC_LEN:{} DEC_LEN:{} MSG_LEN:{}", .{enc.len, dec.len, b.len});

//     try std.testing.expect(std.mem.eql(u8, b, dec));
// }

test "PKCS7" {
    const msg = "I LIEK TURTLES \x00";
    const allocator = std.testing.allocator;
    var pkcs7 = PKCS7.init(allocator, 8);
    
    var pack = try pkcs7.PKCS7_pack(msg);
    defer allocator.free(pack);
    var unpack = try pkcs7.PKCS7_unpack(pack);
    defer allocator.free(unpack);

    try std.testing.expect(std.mem.eql(u8, unpack, msg));
}

pub fn main() !void {

}