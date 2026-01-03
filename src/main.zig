// SPDX-License-Identifier: AGPL-3.0-or-later
//! Zig FFI bindings for container runtimes (Docker, Podman, nerdctl)
//! Inspired by: hyperpolymath/poly-container-mcp

const std = @import("std");

pub const Error = error{
    ConnectionFailed,
    ListFailed,
    AllocationFailed,
};

pub const ContainerState = enum {
    created,
    running,
    paused,
    restarting,
    removing,
    exited,
    dead,
    unknown,
};

pub const Container = struct {
    id: []const u8,
    name: []const u8,
    image: []const u8,
    state: ContainerState,
};

/// Container runtime client (connects via Unix socket)
pub const Client = struct {
    socket_path: []const u8,

    pub fn connect(socket_path: []const u8) Error!Client {
        return Client{ .socket_path = socket_path };
    }

    pub fn listContainers(self: *Client, allocator: std.mem.Allocator) Error![]Container {
        _ = self;
        _ = allocator;
        // TODO: Implement via Unix socket HTTP API
        return &[_]Container{};
    }
};

// C FFI exports
var global_allocator: std.mem.Allocator = std.heap.c_allocator;

export fn container_connect(socket_path: [*:0]const u8) ?*Client {
    const client = Client.connect(std.mem.span(socket_path)) catch return null;
    const ptr = global_allocator.create(Client) catch return null;
    ptr.* = client;
    return ptr;
}

export fn container_free(client: *Client) void {
    global_allocator.destroy(client);
}
