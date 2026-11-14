# my-jai-blob

Owned byte buffers and borrowed mutable views for Jai.

## Dependencies

No other `my-jai-*` modules are required.

Jai standard library: `Basic`.

## Usage

Import with `#import "my-jai-blob";` and add the directory containing `my-jai-blob` to the compiler module search path.
my-jai-core re-exports this module, so `#import "my-jai-core";` also exposes its API.
The standalone module remains independent of my-jai-core.

```jai
#import "my-jai-blob";

bytes := make_blob(16, 0xAB);
defer clear_blob(*bytes);
view := make_blob_view(bytes);
copy := deep_copy_blob(bytes);
defer clear_blob(*copy);
```

- `Blob` owns a resizable `data: [..]u8` array and remembers its allocator.
  Ordinary struct copies and `shallow_copy_blob(blob)` share ownership, capacity
  and allocator metadata. Free the shared allocation exactly once, and do not
  use other copies after resizing or freeing it.
- `shallow_copy_blob(data, size)` adopts an allocation from the current allocator.
  Pass the full allocation size; do not adopt stack, borrowed or static storage.
- `deep_copy_blob(blob)` and `deep_copy_blob(data, size)` allocate independent copies.
- `make_blob(size)` fills with zero; `make_blob(size, byte)` fills with that byte.
  Unchecked constructors require a nonnegative size and valid source storage.
- `try_make_blob` and `try_deep_copy_blob` return `(Blob, bool)` and reject invalid
  sizes, missing nonempty source storage and allocation failure. Empty buffers succeed.
- `get_blob_data` and `get_blob_size` expose the owned storage and byte count.
- `clear_blob(*blob)` frees storage and resets the owner; a null pointer is accepted.
- `BlobView` is an alias for `[]u8`. `make_blob_view(blob)` and
  `make_blob_view(data, size)` borrow storage without allocation or ownership.
  The backing storage must remain valid for the view's lifetime.
  `is_empty_blob_view(view)` checks its count.

This replaces the former `Binary`, `BinaryView` and `*_binary*` APIs with `Blob`,
`BlobView` and `*_blob*`. Byte layout and buffer behavior are unchanged.
