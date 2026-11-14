// Import with #import "my-jai-blob"; and add its parent directory to the module search path.
// Owns its storage. Struct copies share ownership; clear the storage only once.
Blob :: struct {
    data: [..]u8;
}

// Borrows mutable bytes; the backing storage must outlive the view.
BlobView :: []u8;

// Creates a zero-filled buffer.
make_blob :: inline (size: s64) -> Blob {
    return make_blob(size, 0);
}

make_blob :: inline (size: s64, default_value: u8) -> Blob {
    result: Blob;
    array_resize(*result.data, size, false);
    if size > 0 {
        memset(result.data.data, default_value, size);
    }
    return result;
}

shallow_copy_blob :: inline (data: *u8, size: s64) -> Blob {
    result: Blob;
    result.data.data = data;
    result.data.count = size;
    result.data.allocated = size;
    remember_allocators(*result.data);
    return result;
}

deep_copy_blob :: inline (data: *u8, size: s64) -> Blob {
    result: Blob;
    array_resize(*result.data, size, false);
    if size > 0 {
        memcpy(result.data.data, data, size);
    }
    return result;
}

shallow_copy_blob :: inline (blob: Blob) -> Blob {
    return blob;
}

deep_copy_blob :: inline (blob: Blob) -> Blob {
    return deep_copy_blob(blob.data.data, blob.data.count);
}

try_make_blob :: inline (size: s64, default_value: u8 = 0) -> Blob, bool {
    if size < 0 {
        return .{}, false;
    }

    if size == 0 {
        return .{}, true;
    }

    data := cast(*u8)alloc(size);
    if data == null {
        return .{}, false;
    }

    memset(data, default_value, size);
    return shallow_copy_blob(data, size), true;
}

try_deep_copy_blob :: inline (data: *u8, size: s64) -> Blob, bool {
    if size < 0 || (size > 0 && data == null) {
        return .{}, false;
    }

    if size == 0 {
        return .{}, true;
    }

    copy := cast(*u8)alloc(size);
    if copy == null {
        return .{}, false;
    }

    memcpy(copy, data, size);
    return shallow_copy_blob(copy, size), true;
}

get_blob_data :: inline (blob: Blob) -> *u8 {
    return blob.data.data;
}

get_blob_size :: inline (blob: Blob) -> s64 {
    return blob.data.count;
}

clear_blob :: inline (blob: *Blob) {
    if blob == null {
        return;
    }
    array_reset(*blob.data);
    blob.* = .{};
}

make_blob_view :: inline (blob: Blob) -> BlobView {
    return make_blob_view(blob.data.data, blob.data.count);
}

make_blob_view :: inline (data: *u8, size: s64) -> BlobView {
    result: BlobView;
    result.data = data;
    result.count = size;
    return result;
}

is_empty_blob_view :: inline (view: BlobView) -> bool {
    return view.count == 0;
}

#scope_file
#import "Basic";
