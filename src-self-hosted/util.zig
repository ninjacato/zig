const std = @import("std");
const Target = std.Target;
const llvm = @import("llvm.zig");

pub fn getDarwinArchString(self: Target) [:0]const u8 {
    switch (self.cpu.arch) {
        .aarch64 => return "arm64",
        .thumb,
        .arm,
        => return "arm",
        .powerpc => return "ppc",
        .powerpc64 => return "ppc64",
        .powerpc64le => return "ppc64le",
        // @tagName should be able to return sentinel terminated slice
        else => @panic("TODO https://github.com/ziglang/zig/issues/3779"), //return @tagName(arch),
    }
}

pub fn llvmTargetFromTriple(triple: [:0]const u8) !*llvm.Target {
    var result: *llvm.Target = undefined;
    var err_msg: [*:0]u8 = undefined;
    if (llvm.GetTargetFromTriple(triple, &result, &err_msg) != 0) {
        std.debug.warn("triple: {s} error: {s}\n", .{ triple, err_msg });
        return error.UnsupportedTarget;
    }
    return result;
}

pub fn initializeAllTargets() void {
    llvm.InitializeAllTargets();
    llvm.InitializeAllTargetInfos();
    llvm.InitializeAllTargetMCs();
    llvm.InitializeAllAsmPrinters();
    llvm.InitializeAllAsmParsers();
}

pub fn getLLVMTriple(allocator: *std.mem.Allocator, target: std.Target) ![:0]u8 {
    var result = try std.ArrayListSentineled(u8, 0).initSize(allocator, 0);
    defer result.deinit();

    try result.outStream().print(
        "{}-unknown-{}-{}",
        .{ @tagName(target.cpu.arch), @tagName(target.os.tag), @tagName(target.abi) },
    );

    return result.toOwnedSlice();
}
