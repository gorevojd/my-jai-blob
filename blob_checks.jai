#import "Basic";
#import,file "module.jai";

main :: () {
    empty := make_blob(0);
    assert(get_blob_size(empty) == 0);
    assert(is_empty_blob_view(make_blob_view(empty)));
    clear_blob(*empty);
    clear_blob(null);

    zeroed := make_blob(8);
    for zeroed.data {
        assert(it == 0);
    }
    clear_blob(*zeroed);

    owned := make_blob(8, 0xAB);
    array_reserve(*owned.data, 64);
    alias := shallow_copy_blob(owned);
    assert(get_blob_data(alias) == get_blob_data(owned));
    assert(get_blob_size(alias) == 8);
    assert(alias.data.allocated == owned.data.allocated);

    copy := deep_copy_blob(owned);
    assert(get_blob_data(copy) != get_blob_data(owned));
    assert(get_blob_size(copy) == 8);
    view := make_blob_view(owned);
    assert(!is_empty_blob_view(view));
    view[0] = 0xCD;
    assert(alias.data[0] == 0xCD && copy.data[0] == 0xAB);
    slice := make_blob_view(get_blob_data(owned) + 1, 3);
    assert(slice.count == 3 && slice[0] == 0xAB);
    clear_blob(*copy);
    clear_blob(*owned);
    assert(owned.data.data == null && owned.data.count == 0 && owned.data.allocated == 0);
    clear_blob(*owned);

    adopted := shallow_copy_blob(cast(*u8)alloc(4), 4);
    adopted.data[0] = 42;
    copied, copied_ok := try_deep_copy_blob(get_blob_data(adopted), get_blob_size(adopted));
    assert(copied_ok && copied.data[0] == 42 && copied.data.data != adopted.data.data);
    clear_blob(*adopted);
    clear_blob(*copied);

    made, made_ok := try_make_blob(4, 0x7F);
    assert(made_ok && get_blob_size(made) == 4);
    for made.data {
        assert(it == 0x7F);
    }
    clear_blob(*made);

    made, made_ok = try_make_blob(-1);
    assert(!made_ok && made.data.data == null);
    made, made_ok = try_make_blob(0);
    assert(made_ok && made.data.data == null);
    copied, copied_ok = try_deep_copy_blob(null, 1);
    assert(!copied_ok && copied.data.data == null);
    copied, copied_ok = try_deep_copy_blob(null, -1);
    assert(!copied_ok && copied.data.data == null);
    copied, copied_ok = try_deep_copy_blob(null, 0);
    assert(copied_ok && copied.data.data == null);
    empty_copy := deep_copy_blob(empty);
    assert(get_blob_size(empty_copy) == 0);
    clear_blob(*empty_copy);
    print("Blob checks passed.\n");
}
