const std = @import("std");
const hello_world = @import("hello_world");

// start()
// This is the beginning of the app
fn start() !void {
    // Use a buffer
    var stdin_buffer: [1024]u8 = undefined;
    var stdout_buffer: [1024]u8 = undefined;

    var stdin = std.fs.File.stdin().reader(&stdin_buffer);
    var stdout = std.fs.File.stdout().writer(&stdout_buffer);

    // A capacity to hold any i64 + '\r'
    var line_buffer: [1024]u8 = undefined;

    const output = try ask_for_prompt(line_buffer[0..], &stdin.interface, &stdout.interface);
    try stdout.interface.print("Your output: {s}\n", .{output});
    try stdout.interface.flush();
}

// read_line()
// Input: a line_buffer (array of unsigned 8 bit chars), a stdin reader interface
// Output: an array of unsigned 8 bit chars with the length constrained by the delimiter (new line)
fn read_line(line_buffer: []u8, input: *std.io.Reader) ![]u8 {
    var w: std.io.Writer = .fixed(line_buffer);
    const line_length = try input.streamDelimiterLimit(&w, '\n', .unlimited);
    std.debug.assert(line_length <= line_buffer.len);
    return line_buffer[0..line_length];
}

// ask_for_prompt()
// Input: a line_buffer (array of unsigned 8-bit chars), a stdin reader interface, a stdout writer interface,
// Output: a 64 bit integer, or an error
fn ask_for_prompt(line_buffer: []u8, input: *std.io.Reader, output: *std.io.Writer) ![]u8 {
    try output.writeAll("prompt: ");
    // Flush to write all the message before reading the line
    try output.flush();
    const input_line = try read_line(line_buffer, input);
    return input_line;
}

pub fn main() !void {
    try hello_world.bufferedPrint();
    // try start();
}

test "simple test" {
    const gpa = std.testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(gpa); // Try commenting this out and see if zig detects the memory leak!
    try list.append(gpa, 42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "fuzz example" {
    const Context = struct {
        fn testOne(context: @This(), input: []const u8) anyerror!void {
            _ = context;
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(Context{}, Context.testOne, .{});
}
