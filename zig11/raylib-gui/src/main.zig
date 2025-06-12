const std = @import("std");
const raygui = @cImport({
    @cInclude("raygui.h");
    @cInclude("raylib.h");
});

const allocator = std.heap.c_allocator;

pub fn main() !void {
    var screenWidth:f32 = 800;
    var screenHeight:f32 = 600;

    raygui.InitWindow(@intFromFloat(screenWidth), @intFromFloat(screenHeight), "ZIG Raylib + GUI Test Linking");
    raygui.SetTargetFPS(60);

    while(!raygui.WindowShouldClose()) {
        raygui.BeginDrawing();
        raygui.ClearBackground(raygui.RAYWHITE);
        
        raygui.GuiSetStyle(raygui.DEFAULT, raygui.TEXT_ALIGNMENT_VERTICAL, raygui.TEXT_ALIGN_CENTER);
        raygui.GuiSetStyle(raygui.DEFAULT, raygui.TEXT_ALIGNMENT, raygui.TEXT_ALIGN_CENTER);
 
        var text = "I LIKE TURTLES\n\nDo you... Like Turtles?\n\n?????";

        _ = raygui.GuiTextBox(make_rect(0,0,600,800), @constCast(text), 1024, false);
        if(raygui.GuiButton(make_rect(375, 350, 20, 50), @constCast("YES")) > 0) {
            std.debug.print("CLICK\n", .{});
        }
        raygui.EndDrawing();
    }
    raygui.CloseWindow();
}

fn make_rect(x:f32, y:f32, height:f32, width:f32) raygui.Rectangle {
    var boxrec:raygui.Rectangle = undefined;
    boxrec.x = x;
    boxrec.y = y;
    boxrec.height = height;
    boxrec.width = width;
    return boxrec;
}