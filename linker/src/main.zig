const std = @import("std");

const io = std.io;
const fs = std.fs;
const process = std.process;

var output = io.bufferedWriter(io.getStdOut().writer());
const out = output.writer();
var cwd = fs.cwd();
const String = []const u8;

const PathType = enum { origin, target };
const LinkError = error{InvalidMap};

const link = struct {
    mapRow: String,
    allocator: std.mem.Allocator,

    fn createSymLink(self: *const link) void {
        // const originPath = try self.getPathFromMap(.origin);
        // const targetPath = try self.getPathFromMap(.target);
        _ = self;
    }

    fn getPathFromMap(self: *const link, path: PathType) LinkError!String {
        var iter = std.mem.tokenizeAny(u8, self.mapRow, ":");
        var idx: usize = 0;

        while (iter.next()) |item| : (idx += 1) {
            if (idx == @intFromEnum(path)) {
                return item;
            }
        }

        return LinkError.InvalidMap;
    }

    fn resolveToAbsolute(self: *const link, path: String) !String {
        // if path start with "~/", it should be resolved from the user home
        if (std.mem.startsWith(u8, path, "~/")) {
            var env_variables = try process.getEnvMap(self.allocator);
            defer env_variables.deinit();

            const home_path = env_variables.get("HOME");

            if (home_path) |home| {
                const to_join = [_]String{ home, path[2..] };

                return fs.path.join(self.allocator, &to_join);
            }

            @panic("user $HOME not found");
        }

        // if path starts with "/", it should be resolved from the drive root(as it is)
        if (std.mem.startsWith(u8, path, "/")) {
            return path;
        }

        // if path starts with "../", "./" or any other character, it should be resolved from the current directory
        const dir = try cwd.openDir(path, .{});
        return try dir.realpathAlloc(self.allocator, ".");
        // return try cwd.realpathAlloc(self.allocator, path);
    }
};

pub fn main() !void {
    // flush all logs when the program exits
    defer {
        output.flush() catch {
            @panic("failed to flush buffered writer");
        };
    }

    // heap allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();

        if (deinit_status == .leak) {
            @panic("memory leak");
        }
    }

    // process args
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    try out.print(
        \\Linking paths defined in 'link-map.txt'
        \\
        \\
    , .{});

    const link_map = getLinkMapFile() catch {
        try out.print("Failed to open \"link-map.txt\", make sure the file exists and it's on the same folder as this program.\n", .{});
        return;
    };
    defer link_map.close();

    const link_map_stat = try link_map.stat();

    // read contents of the link map file
    const link_map_contents = link_map.readToEndAlloc(allocator, link_map_stat.size) catch {
        try out.print("Failed read contents of \"link-map.txt\", make sure the file isn't being used by another program.\n", .{});
        return;
    };
    defer allocator.free(link_map_contents);

    //split link map file contents on each new line
    var link_map_line_iter = std.mem.splitSequence(u8, link_map_contents, "\n");

    outer: while (link_map_line_iter.next()) |line| {
        if (line.len == 0) {
            try out.print(
                \\X  skipping empty line
                \\
                \\
            , .{});

            continue :outer;
        }

        const element = link{ .mapRow = line, .allocator = allocator };
        element.createSymLink();

        // // resolving the origin and target path before linking then
        // while (link_map_row_iter.next()) |entry| : (i += 1) {
        //     switch (i) {
        //         0 => {
        //             // the first entry is the origin path
        //             origin = getOriginPath(entry, allocator) catch {
        //                 try out.print(
        //                     \\X  skipping map where origin path could not be resolved: "{s}"
        //                     \\
        //                     \\
        //                 , .{entry});
        //                 continue :outer;
        //             };
        //         },
        //         1 => {
        //             // the second entry is the target path
        //             target = getTargetPath(entry, allocator) catch {
        //                 try out.print(
        //                     \\X  skipping map where target path could not be resolved: "{s}"
        //                     \\
        //                     \\
        //                 , .{entry});
        //                 continue :outer;
        //             };
        //         },
        //         else => {
        //             // if we get more than two entries, the line is malformed, so we continue the outer loop before actually linking
        //             try out.print(
        //                 \\X  skipping map with more than 2 paths correlations: "{s}"
        //                 \\
        //                 \\
        //             , .{line});
        //             continue :outer;
        //         },
        //     }
        // }

        // try link(origin.?, target.?);
    }
}

fn getLinkMapFile() !fs.File {
    return try cwd.openFile("link-map.txt", .{
        .mode = .read_only,
    });
}

// fn getTargetPath(path: []const u8, allocator: *const std.mem.Allocator) ![]const u8 {
//     // the target path have to start with "~/" and be resolved from the user home,
//     // otherwise, if we accept relative paths (eg. "../../some_folder/folder/")
//     // it would need to be resolved and throw an error since "folder" would
//     // not be created yet.
//     if (std.mem.startsWith(u8, path, "~/")) {
//         var env_variables = try process.getEnvMap(allocator.*);
//         defer env_variables.deinit();
//         const home_path = env_variables.get("HOME");

//         // surely everyone should have a home, right?
//         if (home_path) |hp| {
//             const to_join = [_]String{ hp, path[2..] };
//             return fs.path.join(allocator.*, &to_join);
//         }
//     }
// }

// fn getOriginPath(path: []const u8, allocator: *const std.mem.Allocator) ![]const u8 {
//     // unlike target path, the origin path can be resolved from a relative string
//     // since it SHOULD already exists.
//     return try cwd.realpathAlloc(allocator.*, path);
// }

// fn link(origin: []const u8, target: []const u8) !void {
//     try out.print(
//         \\~> linking '{s}' to '{s}'
//         \\
//     , .{ origin, target });

//     // effectively linking the origin path to the target path,
//     // notice that the origin and target paths are inverted on the function call.
//     fs.symLinkAbsolute(origin, target, .{ .is_directory = isDir(origin) }) catch |err| switch (err) {
//         error.FileNotFound => {
//             try out.print(
//                 \\   FAILED: the target link folder couldn't be found, if it's a subdirectory make sure the parent directory exists.
//                 \\
//                 \\
//             , .{});
//             return;
//         },
//         error.PathAlreadyExists => {
//             try out.print(
//                 \\   FAILED: there is already an link/folder/file with the same name at the target directory.
//                 \\
//                 \\
//             , .{});
//             return;
//         },
//         else => {
//             try out.print(
//                 \\   unexpected error: {}
//                 \\
//                 \\
//             , .{err});
//             return;
//         },
//     };

//     try out.print(
//         \\   SUCCESS
//         \\
//         \\
//     , .{});
// }

// fn isDir(path: []const u8) bool {
//     var dir = fs.openDirAbsolute(path, .{}) catch {
//         return false;
//     };

//     defer dir.close();

//     return true;
// }

test "link.getPathFromMap" {
    const link_1 = link{ .mapRow = "./link/.zsh:~/.zsh", .allocator = std.testing.allocator };
    const link_2 = link{ .mapRow = "./link/.zsh:", .allocator = std.testing.allocator };
    const link_3 = link{ .mapRow = "./link/.zsh", .allocator = std.testing.allocator };
    const link_4 = link{ .mapRow = "", .allocator = std.testing.allocator };

    try std.testing.expectEqualStrings("./link/.zsh", try link_1.getPathFromMap(.origin));
    try std.testing.expectEqualStrings("~/.zsh", try link_1.getPathFromMap(.target));

    try std.testing.expectEqualStrings("./link/.zsh", try link_2.getPathFromMap(.origin));
    try std.testing.expectError(LinkError.InvalidMap, link_2.getPathFromMap(.target));

    try std.testing.expectEqualStrings("./link/.zsh", try link_3.getPathFromMap(.origin));
    try std.testing.expectError(LinkError.InvalidMap, link_3.getPathFromMap(.target));

    try std.testing.expectError(LinkError.InvalidMap, link_4.getPathFromMap(.origin));
    try std.testing.expectError(LinkError.InvalidMap, link_4.getPathFromMap(.target));
}

test "link.resolveToAbsolute" {
    const map = link{ .mapRow = "./path/to/file:~/path/to/file", .allocator = std.testing.allocator };

    const origin = try map.getPathFromMap(.origin);
    const target = try map.getPathFromMap(.target);

    const resolvedFromRelative = try map.resolveToAbsolute(origin);
    const resolvedFromHome = try map.resolveToAbsolute(target);

    std.debug.print("resolvedFromRelative: {s}\n", .{resolvedFromRelative});
    std.debug.print("resolvedFromHome: {s}\n", .{resolvedFromHome});
}
