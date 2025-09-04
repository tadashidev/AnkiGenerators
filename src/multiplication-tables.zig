const std = @import("std");

pub fn main() !void {
    var debug_allocator: std.heap.DebugAllocator(.{}) = .{};
    defer _ = debug_allocator.detectLeaks();
    const allocator = debug_allocator.allocator();

    var args: std.process.ArgIterator = try .initWithAllocator(allocator);
    defer args.deinit();

    // Skip exe name.
    std.debug.assert(args.skip());

    const output_file = args.next() orelse {
        std.process.fatal("You need to provide a path to an output file.", .{});
    };

    const arg_max_result = args.next() orelse {
        std.process.fatal("You need to provide an allowed maximum result.", .{});
    };

    const max_result = std.fmt.parseInt(u16, arg_max_result, 10) catch {
        std.process.fatal("The maximum result allowed must be a number.", .{});
    };

    var ignored_operands: std.ArrayList(u16) = .empty;
    defer ignored_operands.deinit(allocator);

    while (args.next()) |arg| {
        const operand = std.fmt.parseInt(u16, arg, 10) catch {
            std.process.fatal("The ignored operands must be numbers.", .{});
        };
        try ignored_operands.append(allocator, operand);
    }

    const Question = struct {
        a: u16,
        b: u16,
        result: u16,
    };

    var questions: std.ArrayList(Question) = .empty;
    defer questions.deinit(allocator);

    loop_a: for (0..max_result + 1) |a| {
        loop_b: for (0..max_result + 1) |b| {
            for (ignored_operands.items) |ignored| {
                if (a == ignored) continue :loop_a;
                if (b == ignored) continue :loop_b;
            }

            if (a * b > max_result) continue :loop_a;

            for (questions.items) |question| {
                if (question.a == b and question.b == a) continue :loop_b;
            }

            try questions.append(allocator, .{ .a = @intCast(a), .b = @intCast(b), .result = @intCast(a * b) });
        }
    }

    const file_handler = try std.fs.cwd().createFile(output_file, .{});
    defer file_handler.close();

    var file_buffer: [1024]u8 = undefined;
    var file_writer = file_handler.writer(&file_buffer);
    const file = &file_writer.interface;

    for (questions.items) |question| {
        try file.print("{d},{d},{d}\n", .{ question.a, question.b, question.result });
    }

    try file.flush();

    std.debug.print("Total notes: {}.\n", .{questions.items.len});

    return std.process.cleanExit();
}
