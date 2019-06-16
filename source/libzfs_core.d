module libzfs_core;


        import core.stdc.config;
        import core.stdc.stdarg: va_list;
        static import core.simd;

        template __from(string moduleName) {
            mixin("import from = " ~ moduleName ~ ";");
        }
        struct DppOffsetSize{ long offset; long size; }
        struct Int128 { long lower; long upper; }
        struct UInt128 { ulong lower; ulong upper; }

        struct __locale_data { int dummy; }


alias _Bool = bool;
struct dpp {

    static bool isEmpty(T)() {
        return T.tupleof.length == 0;
    }
    static struct Move(T) {
        T* ptr;
    }

    static auto move(T)(ref T value) {
        return Move!T(&value);
    }
    mixin template EnumD(string name, T, string prefix) if(is(T == enum)) {
        private static string _memberMixinStr(string member) {
            import std.conv: text;
            import std.array: replace;
            return text(` `, member.replace(prefix, ""), ` = `, T.stringof, `.`, member, `,`);
        }
        private static string _enumMixinStr() {
            import std.array: join;
            string[] ret;
            ret ~= "enum " ~ name ~ "{";
            static foreach(member; __traits(allMembers, T)) {
                ret ~= _memberMixinStr(member);
            }
            ret ~= "}";
            return ret.join("\n");
        }
        mixin(_enumMixinStr());
    }
}

extern(C)
{
    enum zio_priority
    {
        ZIO_PRIORITY_SYNC_READ = 0,
        ZIO_PRIORITY_SYNC_WRITE = 1,
        ZIO_PRIORITY_ASYNC_READ = 2,
        ZIO_PRIORITY_ASYNC_WRITE = 3,
        ZIO_PRIORITY_SCRUB = 4,
        ZIO_PRIORITY_REMOVAL = 5,
        ZIO_PRIORITY_INITIALIZING = 6,
        ZIO_PRIORITY_TRIM = 7,
        ZIO_PRIORITY_NUM_QUEUEABLE = 8,
        ZIO_PRIORITY_NOW = 9,
    }
    enum ZIO_PRIORITY_SYNC_READ = zio_priority.ZIO_PRIORITY_SYNC_READ;
    enum ZIO_PRIORITY_SYNC_WRITE = zio_priority.ZIO_PRIORITY_SYNC_WRITE;
    enum ZIO_PRIORITY_ASYNC_READ = zio_priority.ZIO_PRIORITY_ASYNC_READ;
    enum ZIO_PRIORITY_ASYNC_WRITE = zio_priority.ZIO_PRIORITY_ASYNC_WRITE;
    enum ZIO_PRIORITY_SCRUB = zio_priority.ZIO_PRIORITY_SCRUB;
    enum ZIO_PRIORITY_REMOVAL = zio_priority.ZIO_PRIORITY_REMOVAL;
    enum ZIO_PRIORITY_INITIALIZING = zio_priority.ZIO_PRIORITY_INITIALIZING;
    enum ZIO_PRIORITY_TRIM = zio_priority.ZIO_PRIORITY_TRIM;
    enum ZIO_PRIORITY_NUM_QUEUEABLE = zio_priority.ZIO_PRIORITY_NUM_QUEUEABLE;
    enum ZIO_PRIORITY_NOW = zio_priority.ZIO_PRIORITY_NOW;
    alias zio_priority_t = zio_priority;
    nvlist* fnvpair_value_nvlist(nvpair*) @nogc nothrow;
    char* fnvpair_value_string(nvpair*) @nogc nothrow;
    ulong fnvpair_value_uint64(nvpair*) @nogc nothrow;
    uint fnvpair_value_uint32(nvpair*) @nogc nothrow;
    ushort fnvpair_value_uint16(nvpair*) @nogc nothrow;
    ubyte fnvpair_value_uint8(nvpair*) @nogc nothrow;
    c_long fnvpair_value_int64(nvpair*) @nogc nothrow;
    int fnvpair_value_int32(nvpair*) @nogc nothrow;
    short fnvpair_value_int16(nvpair*) @nogc nothrow;
    byte fnvpair_value_int8(nvpair*) @nogc nothrow;
    ubyte fnvpair_value_byte(nvpair*) @nogc nothrow;
    int fnvpair_value_boolean_value(nvpair*) @nogc nothrow;
    ulong* fnvlist_lookup_uint64_array(nvlist*, const(char)*, uint*) @nogc nothrow;
    c_long* fnvlist_lookup_int64_array(nvlist*, const(char)*, uint*) @nogc nothrow;
    uint* fnvlist_lookup_uint32_array(nvlist*, const(char)*, uint*) @nogc nothrow;
    int* fnvlist_lookup_int32_array(nvlist*, const(char)*, uint*) @nogc nothrow;
    ushort* fnvlist_lookup_uint16_array(nvlist*, const(char)*, uint*) @nogc nothrow;
    short* fnvlist_lookup_int16_array(nvlist*, const(char)*, uint*) @nogc nothrow;
    ubyte* fnvlist_lookup_uint8_array(nvlist*, const(char)*, uint*) @nogc nothrow;
    byte* fnvlist_lookup_int8_array(nvlist*, const(char)*, uint*) @nogc nothrow;
    ubyte* fnvlist_lookup_byte_array(nvlist*, const(char)*, uint*) @nogc nothrow;
    int* fnvlist_lookup_boolean_array(nvlist*, const(char)*, uint*) @nogc nothrow;
    nvlist* fnvlist_lookup_nvlist(nvlist*, const(char)*) @nogc nothrow;
    char* fnvlist_lookup_string(nvlist*, const(char)*) @nogc nothrow;
    ulong fnvlist_lookup_uint64(nvlist*, const(char)*) @nogc nothrow;
    uint fnvlist_lookup_uint32(nvlist*, const(char)*) @nogc nothrow;
    ushort fnvlist_lookup_uint16(nvlist*, const(char)*) @nogc nothrow;
    ubyte fnvlist_lookup_uint8(nvlist*, const(char)*) @nogc nothrow;
    c_long fnvlist_lookup_int64(nvlist*, const(char)*) @nogc nothrow;
    int fnvlist_lookup_int32(nvlist*, const(char)*) @nogc nothrow;
    short fnvlist_lookup_int16(nvlist*, const(char)*) @nogc nothrow;
    byte fnvlist_lookup_int8(nvlist*, const(char)*) @nogc nothrow;
    ubyte fnvlist_lookup_byte(nvlist*, const(char)*) @nogc nothrow;
    int fnvlist_lookup_boolean_value(nvlist*, const(char)*) @nogc nothrow;
    int fnvlist_lookup_boolean(nvlist*, const(char)*) @nogc nothrow;
    nvpair* fnvlist_lookup_nvpair(nvlist*, const(char)*) @nogc nothrow;
    void fnvlist_remove_nvpair(nvlist*, nvpair*) @nogc nothrow;
    void fnvlist_remove(nvlist*, const(char)*) @nogc nothrow;
    void fnvlist_add_nvlist_array(nvlist*, const(char)*, nvlist**, uint) @nogc nothrow;
    void fnvlist_add_string_array(nvlist*, const(char)*, char**, uint) @nogc nothrow;
    void fnvlist_add_uint64_array(nvlist*, const(char)*, ulong*, uint) @nogc nothrow;
    void fnvlist_add_int64_array(nvlist*, const(char)*, c_long*, uint) @nogc nothrow;
    void fnvlist_add_uint32_array(nvlist*, const(char)*, uint*, uint) @nogc nothrow;
    void fnvlist_add_int32_array(nvlist*, const(char)*, int*, uint) @nogc nothrow;
    void fnvlist_add_uint16_array(nvlist*, const(char)*, ushort*, uint) @nogc nothrow;
    void fnvlist_add_int16_array(nvlist*, const(char)*, short*, uint) @nogc nothrow;
    void fnvlist_add_uint8_array(nvlist*, const(char)*, ubyte*, uint) @nogc nothrow;
    void fnvlist_add_int8_array(nvlist*, const(char)*, byte*, uint) @nogc nothrow;
    void fnvlist_add_byte_array(nvlist*, const(char)*, ubyte*, uint) @nogc nothrow;
    void fnvlist_add_boolean_array(nvlist*, const(char)*, int*, uint) @nogc nothrow;
    void fnvlist_add_nvpair(nvlist*, nvpair*) @nogc nothrow;
    void fnvlist_add_nvlist(nvlist*, const(char)*, nvlist*) @nogc nothrow;
    void fnvlist_add_string(nvlist*, const(char)*, const(char)*) @nogc nothrow;
    void fnvlist_add_uint64(nvlist*, const(char)*, ulong) @nogc nothrow;
    void fnvlist_add_int64(nvlist*, const(char)*, c_long) @nogc nothrow;
    void fnvlist_add_uint32(nvlist*, const(char)*, uint) @nogc nothrow;
    void fnvlist_add_int32(nvlist*, const(char)*, int) @nogc nothrow;
    void fnvlist_add_uint16(nvlist*, const(char)*, ushort) @nogc nothrow;
    void fnvlist_add_int16(nvlist*, const(char)*, short) @nogc nothrow;
    void fnvlist_add_uint8(nvlist*, const(char)*, ubyte) @nogc nothrow;
    void fnvlist_add_int8(nvlist*, const(char)*, byte) @nogc nothrow;
    void fnvlist_add_byte(nvlist*, const(char)*, ubyte) @nogc nothrow;
    void fnvlist_add_boolean_value(nvlist*, const(char)*, int) @nogc nothrow;
    void fnvlist_add_boolean(nvlist*, const(char)*) @nogc nothrow;
    c_ulong fnvlist_num_pairs(nvlist*) @nogc nothrow;
    void fnvlist_merge(nvlist*, nvlist*) @nogc nothrow;
    nvlist* fnvlist_dup(nvlist*) @nogc nothrow;
    nvlist* fnvlist_unpack(char*, c_ulong) @nogc nothrow;
    void fnvlist_pack_free(char*, c_ulong) @nogc nothrow;
    char* fnvlist_pack(nvlist*, c_ulong*) @nogc nothrow;
    c_ulong fnvlist_size(nvlist*) @nogc nothrow;
    void fnvlist_free(nvlist*) @nogc nothrow;
    nvlist* fnvlist_alloc() @nogc nothrow;
    int nvpair_value_double(nvpair*, double*) @nogc nothrow;
    int nvpair_value_hrtime(nvpair*, ulong*) @nogc nothrow;
    int nvpair_value_nvlist_array(nvpair*, nvlist***, uint*) @nogc nothrow;
    int nvpair_value_string_array(nvpair*, char***, uint*) @nogc nothrow;
    int nvpair_value_uint64_array(nvpair*, ulong**, uint*) @nogc nothrow;
    int nvpair_value_int64_array(nvpair*, c_long**, uint*) @nogc nothrow;
    int nvpair_value_uint32_array(nvpair*, uint**, uint*) @nogc nothrow;
    int nvpair_value_int32_array(nvpair*, int**, uint*) @nogc nothrow;
    int nvpair_value_uint16_array(nvpair*, ushort**, uint*) @nogc nothrow;
    int nvpair_value_int16_array(nvpair*, short**, uint*) @nogc nothrow;
    int nvpair_value_uint8_array(nvpair*, ubyte**, uint*) @nogc nothrow;
    int nvpair_value_int8_array(nvpair*, byte**, uint*) @nogc nothrow;
    int nvpair_value_byte_array(nvpair*, ubyte**, uint*) @nogc nothrow;
    int nvpair_value_boolean_array(nvpair*, int**, uint*) @nogc nothrow;
    int nvpair_value_nvlist(nvpair*, nvlist**) @nogc nothrow;
    int nvpair_value_string(nvpair*, char**) @nogc nothrow;
    int nvpair_value_uint64(nvpair*, ulong*) @nogc nothrow;
    int nvpair_value_int64(nvpair*, c_long*) @nogc nothrow;
    int nvpair_value_uint32(nvpair*, uint*) @nogc nothrow;
    int nvpair_value_int32(nvpair*, int*) @nogc nothrow;
    int nvpair_value_uint16(nvpair*, ushort*) @nogc nothrow;
    int nvpair_value_int16(nvpair*, short*) @nogc nothrow;
    int nvpair_value_uint8(nvpair*, ubyte*) @nogc nothrow;
    int nvpair_value_int8(nvpair*, byte*) @nogc nothrow;
    int nvpair_value_byte(nvpair*, ubyte*) @nogc nothrow;
    int nvpair_value_boolean_value(nvpair*, int*) @nogc nothrow;
    int nvpair_type_is_array(nvpair*) @nogc nothrow;
    data_type_t nvpair_type(nvpair*) @nogc nothrow;
    char* nvpair_name(nvpair*) @nogc nothrow;
    nvpair* nvlist_prev_nvpair(nvlist*, nvpair*) @nogc nothrow;
    nvpair* nvlist_next_nvpair(nvlist*, nvpair*) @nogc nothrow;
    int nvlist_empty(nvlist*) @nogc nothrow;
    int nvlist_exists(nvlist*, const(char)*) @nogc nothrow;
    int nvlist_lookup_nvpair_embedded_index(nvlist*, const(char)*, nvpair**, int*, char**) @nogc nothrow;
    int nvlist_lookup_nvpair(nvlist*, const(char)*, nvpair**) @nogc nothrow;
    int nvlist_lookup_double(nvlist*, const(char)*, double*) @nogc nothrow;
    int nvlist_lookup_pairs(nvlist*, int, ...) @nogc nothrow;
    int nvlist_lookup_hrtime(nvlist*, const(char)*, ulong*) @nogc nothrow;
    int nvlist_lookup_nvlist_array(nvlist*, const(char)*, nvlist***, uint*) @nogc nothrow;
    int nvlist_lookup_string_array(nvlist*, const(char)*, char***, uint*) @nogc nothrow;
    int nvlist_lookup_uint64_array(nvlist*, const(char)*, ulong**, uint*) @nogc nothrow;
    int nvlist_lookup_int64_array(nvlist*, const(char)*, c_long**, uint*) @nogc nothrow;
    int nvlist_lookup_uint32_array(nvlist*, const(char)*, uint**, uint*) @nogc nothrow;
    int nvlist_lookup_int32_array(nvlist*, const(char)*, int**, uint*) @nogc nothrow;
    int nvlist_lookup_uint16_array(nvlist*, const(char)*, ushort**, uint*) @nogc nothrow;
    int nvlist_lookup_int16_array(nvlist*, const(char)*, short**, uint*) @nogc nothrow;
    int nvlist_lookup_uint8_array(nvlist*, const(char)*, ubyte**, uint*) @nogc nothrow;
    int nvlist_lookup_int8_array(nvlist*, const(char)*, byte**, uint*) @nogc nothrow;
    int nvlist_lookup_byte_array(nvlist*, const(char)*, ubyte**, uint*) @nogc nothrow;
    int nvlist_lookup_boolean_array(nvlist*, const(char)*, int**, uint*) @nogc nothrow;
    int nvlist_lookup_nvlist(nvlist*, const(char)*, nvlist**) @nogc nothrow;
    int nvlist_lookup_string(nvlist*, const(char)*, char**) @nogc nothrow;
    int nvlist_lookup_uint64(nvlist*, const(char)*, ulong*) @nogc nothrow;
    int nvlist_lookup_int64(nvlist*, const(char)*, c_long*) @nogc nothrow;
    int nvlist_lookup_uint32(nvlist*, const(char)*, uint*) @nogc nothrow;
    int nvlist_lookup_int32(nvlist*, const(char)*, int*) @nogc nothrow;
    int nvlist_lookup_uint16(nvlist*, const(char)*, ushort*) @nogc nothrow;
    int nvlist_lookup_int16(nvlist*, const(char)*, short*) @nogc nothrow;
    int nvlist_lookup_uint8(nvlist*, const(char)*, ubyte*) @nogc nothrow;
    int nvlist_lookup_int8(nvlist*, const(char)*, byte*) @nogc nothrow;
    int nvlist_lookup_byte(nvlist*, const(char)*, ubyte*) @nogc nothrow;
    int nvlist_lookup_boolean_value(nvlist*, const(char)*, int*) @nogc nothrow;
    int nvlist_lookup_boolean(nvlist*, const(char)*) @nogc nothrow;
    int nvlist_remove_nvpair(nvlist*, nvpair*) @nogc nothrow;
    int nvlist_remove_all(nvlist*, const(char)*) @nogc nothrow;
    int nvlist_remove(nvlist*, const(char)*, data_type_t) @nogc nothrow;
    int nvlist_add_double(nvlist*, const(char)*, double) @nogc nothrow;
    int nvlist_add_hrtime(nvlist*, const(char)*, ulong) @nogc nothrow;
    int nvlist_add_nvlist_array(nvlist*, const(char)*, nvlist**, uint) @nogc nothrow;
    int nvlist_add_string_array(nvlist*, const(char)*, char**, uint) @nogc nothrow;
    int nvlist_add_uint64_array(nvlist*, const(char)*, ulong*, uint) @nogc nothrow;
    int nvlist_add_int64_array(nvlist*, const(char)*, c_long*, uint) @nogc nothrow;
    int nvlist_add_uint32_array(nvlist*, const(char)*, uint*, uint) @nogc nothrow;
    int nvlist_add_int32_array(nvlist*, const(char)*, int*, uint) @nogc nothrow;
    int nvlist_add_uint16_array(nvlist*, const(char)*, ushort*, uint) @nogc nothrow;
    int nvlist_add_int16_array(nvlist*, const(char)*, short*, uint) @nogc nothrow;
    int nvlist_add_uint8_array(nvlist*, const(char)*, ubyte*, uint) @nogc nothrow;
    int nvlist_add_int8_array(nvlist*, const(char)*, byte*, uint) @nogc nothrow;
    int nvlist_add_byte_array(nvlist*, const(char)*, ubyte*, uint) @nogc nothrow;
    int nvlist_add_boolean_array(nvlist*, const(char)*, int*, uint) @nogc nothrow;
    int nvlist_add_nvlist(nvlist*, const(char)*, nvlist*) @nogc nothrow;
    int nvlist_add_string(nvlist*, const(char)*, const(char)*) @nogc nothrow;
    int nvlist_add_uint64(nvlist*, const(char)*, ulong) @nogc nothrow;
    int nvlist_add_int64(nvlist*, const(char)*, c_long) @nogc nothrow;
    int nvlist_add_uint32(nvlist*, const(char)*, uint) @nogc nothrow;
    int nvlist_add_int32(nvlist*, const(char)*, int) @nogc nothrow;
    int nvlist_add_uint16(nvlist*, const(char)*, ushort) @nogc nothrow;
    int nvlist_add_int16(nvlist*, const(char)*, short) @nogc nothrow;
    int nvlist_add_uint8(nvlist*, const(char)*, ubyte) @nogc nothrow;
    int nvlist_add_int8(nvlist*, const(char)*, byte) @nogc nothrow;
    int nvlist_add_byte(nvlist*, const(char)*, ubyte) @nogc nothrow;
    int nvlist_add_boolean_value(nvlist*, const(char)*, int) @nogc nothrow;
    int nvlist_add_boolean(nvlist*, const(char)*) @nogc nothrow;
    int nvlist_add_nvpair(nvlist*, nvpair*) @nogc nothrow;
    nv_alloc* nvlist_lookup_nv_alloc(nvlist*) @nogc nothrow;
    int nvlist_xdup(nvlist*, nvlist**, nv_alloc*) @nogc nothrow;
    int nvlist_xunpack(char*, c_ulong, nvlist**, nv_alloc*) @nogc nothrow;
    int nvlist_xpack(nvlist*, char**, c_ulong*, int, nv_alloc*) @nogc nothrow;
    int nvlist_xalloc(nvlist**, uint, nv_alloc*) @nogc nothrow;
    uint nvlist_nvflag(nvlist*) @nogc nothrow;
    int nvlist_merge(nvlist*, nvlist*, int) @nogc nothrow;
    int nvlist_dup(nvlist*, nvlist**, int) @nogc nothrow;
    int nvlist_unpack(char*, c_ulong, nvlist**, int) @nogc nothrow;
    int nvlist_pack(nvlist*, char**, c_ulong*, int, int) @nogc nothrow;
    int nvlist_size(nvlist*, c_ulong*, int) @nogc nothrow;
    void nvlist_free(nvlist*) @nogc nothrow;
    int nvlist_alloc(nvlist**, uint, int) @nogc nothrow;
    void nv_alloc_fini(nv_alloc*) @nogc nothrow;
    void nv_alloc_reset(nv_alloc*) @nogc nothrow;
    int nv_alloc_init(nv_alloc*, const(nv_alloc_ops)*, ...) @nogc nothrow;
    extern __gshared nv_alloc* nv_alloc_nosleep;
    extern __gshared const(nv_alloc_ops)* nv_fixed_ops;
    struct nv_alloc
    {
        @DppOffsetSize(0,8) const(nv_alloc_ops)* nva_ops;
        @DppOffsetSize(8,8) void* nva_arg;
    }
    alias nv_alloc_t = nv_alloc;
    struct nv_alloc_ops
    {
        @DppOffsetSize(0,8) int function(nv_alloc*, int) nv_ao_init;
        @DppOffsetSize(8,8) void function(nv_alloc*) nv_ao_fini;
        @DppOffsetSize(16,8) void* function(nv_alloc*, c_ulong) nv_ao_alloc;
        @DppOffsetSize(24,8) void function(nv_alloc*, void*, c_ulong) nv_ao_free;
        @DppOffsetSize(32,8) void function(nv_alloc*) nv_ao_reset;
    }
    alias nv_alloc_ops_t = nv_alloc_ops;
    struct nvlist
    {
        @DppOffsetSize(0,4) int nvl_version;
        @DppOffsetSize(4,4) uint nvl_nvflag;
        @DppOffsetSize(8,8) ulong nvl_priv;
        @DppOffsetSize(16,4) uint nvl_flag;
        @DppOffsetSize(20,4) int nvl_pad;
    }
    alias nvlist_t = nvlist;
    struct nvpair
    {
        @DppOffsetSize(0,4) int nvp_size;
        @DppOffsetSize(4,2) short nvp_name_sz;
        @DppOffsetSize(6,2) short nvp_reserve;
        @DppOffsetSize(8,4) int nvp_value_elem;
        @DppOffsetSize(12,4) data_type_t nvp_type;
    }
    alias nvpair_t = nvpair;
    enum _Anonymous_0
    {
        DATA_TYPE_DONTCARE = -1,
        DATA_TYPE_UNKNOWN = 0,
        DATA_TYPE_BOOLEAN = 1,
        DATA_TYPE_BYTE = 2,
        DATA_TYPE_INT16 = 3,
        DATA_TYPE_UINT16 = 4,
        DATA_TYPE_INT32 = 5,
        DATA_TYPE_UINT32 = 6,
        DATA_TYPE_INT64 = 7,
        DATA_TYPE_UINT64 = 8,
        DATA_TYPE_STRING = 9,
        DATA_TYPE_BYTE_ARRAY = 10,
        DATA_TYPE_INT16_ARRAY = 11,
        DATA_TYPE_UINT16_ARRAY = 12,
        DATA_TYPE_INT32_ARRAY = 13,
        DATA_TYPE_UINT32_ARRAY = 14,
        DATA_TYPE_INT64_ARRAY = 15,
        DATA_TYPE_UINT64_ARRAY = 16,
        DATA_TYPE_STRING_ARRAY = 17,
        DATA_TYPE_HRTIME = 18,
        DATA_TYPE_NVLIST = 19,
        DATA_TYPE_NVLIST_ARRAY = 20,
        DATA_TYPE_BOOLEAN_VALUE = 21,
        DATA_TYPE_INT8 = 22,
        DATA_TYPE_UINT8 = 23,
        DATA_TYPE_BOOLEAN_ARRAY = 24,
        DATA_TYPE_INT8_ARRAY = 25,
        DATA_TYPE_UINT8_ARRAY = 26,
        DATA_TYPE_DOUBLE = 27,
    }
    enum DATA_TYPE_DONTCARE = _Anonymous_0.DATA_TYPE_DONTCARE;
    enum DATA_TYPE_UNKNOWN = _Anonymous_0.DATA_TYPE_UNKNOWN;
    enum DATA_TYPE_BOOLEAN = _Anonymous_0.DATA_TYPE_BOOLEAN;
    enum DATA_TYPE_BYTE = _Anonymous_0.DATA_TYPE_BYTE;
    enum DATA_TYPE_INT16 = _Anonymous_0.DATA_TYPE_INT16;
    enum DATA_TYPE_UINT16 = _Anonymous_0.DATA_TYPE_UINT16;
    enum DATA_TYPE_INT32 = _Anonymous_0.DATA_TYPE_INT32;
    enum DATA_TYPE_UINT32 = _Anonymous_0.DATA_TYPE_UINT32;
    enum DATA_TYPE_INT64 = _Anonymous_0.DATA_TYPE_INT64;
    enum DATA_TYPE_UINT64 = _Anonymous_0.DATA_TYPE_UINT64;
    enum DATA_TYPE_STRING = _Anonymous_0.DATA_TYPE_STRING;
    enum DATA_TYPE_BYTE_ARRAY = _Anonymous_0.DATA_TYPE_BYTE_ARRAY;
    enum DATA_TYPE_INT16_ARRAY = _Anonymous_0.DATA_TYPE_INT16_ARRAY;
    enum DATA_TYPE_UINT16_ARRAY = _Anonymous_0.DATA_TYPE_UINT16_ARRAY;
    enum DATA_TYPE_INT32_ARRAY = _Anonymous_0.DATA_TYPE_INT32_ARRAY;
    enum DATA_TYPE_UINT32_ARRAY = _Anonymous_0.DATA_TYPE_UINT32_ARRAY;
    enum DATA_TYPE_INT64_ARRAY = _Anonymous_0.DATA_TYPE_INT64_ARRAY;
    enum DATA_TYPE_UINT64_ARRAY = _Anonymous_0.DATA_TYPE_UINT64_ARRAY;
    enum DATA_TYPE_STRING_ARRAY = _Anonymous_0.DATA_TYPE_STRING_ARRAY;
    enum DATA_TYPE_HRTIME = _Anonymous_0.DATA_TYPE_HRTIME;
    enum DATA_TYPE_NVLIST = _Anonymous_0.DATA_TYPE_NVLIST;
    enum DATA_TYPE_NVLIST_ARRAY = _Anonymous_0.DATA_TYPE_NVLIST_ARRAY;
    enum DATA_TYPE_BOOLEAN_VALUE = _Anonymous_0.DATA_TYPE_BOOLEAN_VALUE;
    enum DATA_TYPE_INT8 = _Anonymous_0.DATA_TYPE_INT8;
    enum DATA_TYPE_UINT8 = _Anonymous_0.DATA_TYPE_UINT8;
    enum DATA_TYPE_BOOLEAN_ARRAY = _Anonymous_0.DATA_TYPE_BOOLEAN_ARRAY;
    enum DATA_TYPE_INT8_ARRAY = _Anonymous_0.DATA_TYPE_INT8_ARRAY;
    enum DATA_TYPE_UINT8_ARRAY = _Anonymous_0.DATA_TYPE_UINT8_ARRAY;
    enum DATA_TYPE_DOUBLE = _Anonymous_0.DATA_TYPE_DOUBLE;
    alias data_type_t = _Anonymous_0;
    ulong gethrtime() @nogc nothrow;
    alias hrtime_t = ulong;
    alias int64_t = c_long;
    alias int32_t = int;
    alias int16_t = short;
    alias uint64_t = ulong;
    alias uint8_t = ubyte;
    alias uchar_t = ubyte;
    alias boolean_t = int;
    alias uint_t = uint;
    alias uint32_t = uint;
    alias uint16_t = ushort;
    enum _Anonymous_1
    {
        SPA_LOAD_NONE = 0,
        SPA_LOAD_OPEN = 1,
        SPA_LOAD_IMPORT = 2,
        SPA_LOAD_TRYIMPORT = 3,
        SPA_LOAD_RECOVER = 4,
        SPA_LOAD_ERROR = 5,
        SPA_LOAD_CREATE = 6,
    }
    enum SPA_LOAD_NONE = _Anonymous_1.SPA_LOAD_NONE;
    enum SPA_LOAD_OPEN = _Anonymous_1.SPA_LOAD_OPEN;
    enum SPA_LOAD_IMPORT = _Anonymous_1.SPA_LOAD_IMPORT;
    enum SPA_LOAD_TRYIMPORT = _Anonymous_1.SPA_LOAD_TRYIMPORT;
    enum SPA_LOAD_RECOVER = _Anonymous_1.SPA_LOAD_RECOVER;
    enum SPA_LOAD_ERROR = _Anonymous_1.SPA_LOAD_ERROR;
    enum SPA_LOAD_CREATE = _Anonymous_1.SPA_LOAD_CREATE;
    alias spa_load_state_t = _Anonymous_1;
    enum _Anonymous_2
    {
        ZFS_ERR_CHECKPOINT_EXISTS = 1024,
        ZFS_ERR_DISCARDING_CHECKPOINT = 1025,
        ZFS_ERR_NO_CHECKPOINT = 1026,
        ZFS_ERR_DEVRM_IN_PROGRESS = 1027,
        ZFS_ERR_VDEV_TOO_BIG = 1028,
        ZFS_ERR_IOC_CMD_UNAVAIL = 1029,
        ZFS_ERR_IOC_ARG_UNAVAIL = 1030,
        ZFS_ERR_IOC_ARG_REQUIRED = 1031,
        ZFS_ERR_IOC_ARG_BADTYPE = 1032,
        ZFS_ERR_WRONG_PARENT = 1033,
        ZFS_ERR_FROM_IVSET_GUID_MISSING = 1034,
        ZFS_ERR_FROM_IVSET_GUID_MISMATCH = 1035,
        ZFS_ERR_SPILL_BLOCK_FLAG_MISSING = 1036,
    }
    enum ZFS_ERR_CHECKPOINT_EXISTS = _Anonymous_2.ZFS_ERR_CHECKPOINT_EXISTS;
    enum ZFS_ERR_DISCARDING_CHECKPOINT = _Anonymous_2.ZFS_ERR_DISCARDING_CHECKPOINT;
    enum ZFS_ERR_NO_CHECKPOINT = _Anonymous_2.ZFS_ERR_NO_CHECKPOINT;
    enum ZFS_ERR_DEVRM_IN_PROGRESS = _Anonymous_2.ZFS_ERR_DEVRM_IN_PROGRESS;
    enum ZFS_ERR_VDEV_TOO_BIG = _Anonymous_2.ZFS_ERR_VDEV_TOO_BIG;
    enum ZFS_ERR_IOC_CMD_UNAVAIL = _Anonymous_2.ZFS_ERR_IOC_CMD_UNAVAIL;
    enum ZFS_ERR_IOC_ARG_UNAVAIL = _Anonymous_2.ZFS_ERR_IOC_ARG_UNAVAIL;
    enum ZFS_ERR_IOC_ARG_REQUIRED = _Anonymous_2.ZFS_ERR_IOC_ARG_REQUIRED;
    enum ZFS_ERR_IOC_ARG_BADTYPE = _Anonymous_2.ZFS_ERR_IOC_ARG_BADTYPE;
    enum ZFS_ERR_WRONG_PARENT = _Anonymous_2.ZFS_ERR_WRONG_PARENT;
    enum ZFS_ERR_FROM_IVSET_GUID_MISSING = _Anonymous_2.ZFS_ERR_FROM_IVSET_GUID_MISSING;
    enum ZFS_ERR_FROM_IVSET_GUID_MISMATCH = _Anonymous_2.ZFS_ERR_FROM_IVSET_GUID_MISMATCH;
    enum ZFS_ERR_SPILL_BLOCK_FLAG_MISSING = _Anonymous_2.ZFS_ERR_SPILL_BLOCK_FLAG_MISSING;
    alias zfs_errno_t = _Anonymous_2;
    enum zfs_ioc
    {
        ZFS_IOC_FIRST = 23040,
        ZFS_IOC = 23040,
        ZFS_IOC_POOL_CREATE = 23040,
        ZFS_IOC_POOL_DESTROY = 23041,
        ZFS_IOC_POOL_IMPORT = 23042,
        ZFS_IOC_POOL_EXPORT = 23043,
        ZFS_IOC_POOL_CONFIGS = 23044,
        ZFS_IOC_POOL_STATS = 23045,
        ZFS_IOC_POOL_TRYIMPORT = 23046,
        ZFS_IOC_POOL_SCAN = 23047,
        ZFS_IOC_POOL_FREEZE = 23048,
        ZFS_IOC_POOL_UPGRADE = 23049,
        ZFS_IOC_POOL_GET_HISTORY = 23050,
        ZFS_IOC_VDEV_ADD = 23051,
        ZFS_IOC_VDEV_REMOVE = 23052,
        ZFS_IOC_VDEV_SET_STATE = 23053,
        ZFS_IOC_VDEV_ATTACH = 23054,
        ZFS_IOC_VDEV_DETACH = 23055,
        ZFS_IOC_VDEV_SETPATH = 23056,
        ZFS_IOC_VDEV_SETFRU = 23057,
        ZFS_IOC_OBJSET_STATS = 23058,
        ZFS_IOC_OBJSET_ZPLPROPS = 23059,
        ZFS_IOC_DATASET_LIST_NEXT = 23060,
        ZFS_IOC_SNAPSHOT_LIST_NEXT = 23061,
        ZFS_IOC_SET_PROP = 23062,
        ZFS_IOC_CREATE = 23063,
        ZFS_IOC_DESTROY = 23064,
        ZFS_IOC_ROLLBACK = 23065,
        ZFS_IOC_RENAME = 23066,
        ZFS_IOC_RECV = 23067,
        ZFS_IOC_SEND = 23068,
        ZFS_IOC_INJECT_FAULT = 23069,
        ZFS_IOC_CLEAR_FAULT = 23070,
        ZFS_IOC_INJECT_LIST_NEXT = 23071,
        ZFS_IOC_ERROR_LOG = 23072,
        ZFS_IOC_CLEAR = 23073,
        ZFS_IOC_PROMOTE = 23074,
        ZFS_IOC_SNAPSHOT = 23075,
        ZFS_IOC_DSOBJ_TO_DSNAME = 23076,
        ZFS_IOC_OBJ_TO_PATH = 23077,
        ZFS_IOC_POOL_SET_PROPS = 23078,
        ZFS_IOC_POOL_GET_PROPS = 23079,
        ZFS_IOC_SET_FSACL = 23080,
        ZFS_IOC_GET_FSACL = 23081,
        ZFS_IOC_SHARE = 23082,
        ZFS_IOC_INHERIT_PROP = 23083,
        ZFS_IOC_SMB_ACL = 23084,
        ZFS_IOC_USERSPACE_ONE = 23085,
        ZFS_IOC_USERSPACE_MANY = 23086,
        ZFS_IOC_USERSPACE_UPGRADE = 23087,
        ZFS_IOC_HOLD = 23088,
        ZFS_IOC_RELEASE = 23089,
        ZFS_IOC_GET_HOLDS = 23090,
        ZFS_IOC_OBJSET_RECVD_PROPS = 23091,
        ZFS_IOC_VDEV_SPLIT = 23092,
        ZFS_IOC_NEXT_OBJ = 23093,
        ZFS_IOC_DIFF = 23094,
        ZFS_IOC_TMP_SNAPSHOT = 23095,
        ZFS_IOC_OBJ_TO_STATS = 23096,
        ZFS_IOC_SPACE_WRITTEN = 23097,
        ZFS_IOC_SPACE_SNAPS = 23098,
        ZFS_IOC_DESTROY_SNAPS = 23099,
        ZFS_IOC_POOL_REGUID = 23100,
        ZFS_IOC_POOL_REOPEN = 23101,
        ZFS_IOC_SEND_PROGRESS = 23102,
        ZFS_IOC_LOG_HISTORY = 23103,
        ZFS_IOC_SEND_NEW = 23104,
        ZFS_IOC_SEND_SPACE = 23105,
        ZFS_IOC_CLONE = 23106,
        ZFS_IOC_BOOKMARK = 23107,
        ZFS_IOC_GET_BOOKMARKS = 23108,
        ZFS_IOC_DESTROY_BOOKMARKS = 23109,
        ZFS_IOC_RECV_NEW = 23110,
        ZFS_IOC_POOL_SYNC = 23111,
        ZFS_IOC_CHANNEL_PROGRAM = 23112,
        ZFS_IOC_LOAD_KEY = 23113,
        ZFS_IOC_UNLOAD_KEY = 23114,
        ZFS_IOC_CHANGE_KEY = 23115,
        ZFS_IOC_REMAP = 23116,
        ZFS_IOC_POOL_CHECKPOINT = 23117,
        ZFS_IOC_POOL_DISCARD_CHECKPOINT = 23118,
        ZFS_IOC_POOL_INITIALIZE = 23119,
        ZFS_IOC_POOL_TRIM = 23120,
        ZFS_IOC_LINUX = 23168,
        ZFS_IOC_EVENTS_NEXT = 23169,
        ZFS_IOC_EVENTS_CLEAR = 23170,
        ZFS_IOC_EVENTS_SEEK = 23171,
        ZFS_IOC_FREEBSD = 23232,
        ZFS_IOC_LAST = 23233,
    }
    enum ZFS_IOC_FIRST = zfs_ioc.ZFS_IOC_FIRST;
    enum ZFS_IOC = zfs_ioc.ZFS_IOC;
    enum ZFS_IOC_POOL_CREATE = zfs_ioc.ZFS_IOC_POOL_CREATE;
    enum ZFS_IOC_POOL_DESTROY = zfs_ioc.ZFS_IOC_POOL_DESTROY;
    enum ZFS_IOC_POOL_IMPORT = zfs_ioc.ZFS_IOC_POOL_IMPORT;
    enum ZFS_IOC_POOL_EXPORT = zfs_ioc.ZFS_IOC_POOL_EXPORT;
    enum ZFS_IOC_POOL_CONFIGS = zfs_ioc.ZFS_IOC_POOL_CONFIGS;
    enum ZFS_IOC_POOL_STATS = zfs_ioc.ZFS_IOC_POOL_STATS;
    enum ZFS_IOC_POOL_TRYIMPORT = zfs_ioc.ZFS_IOC_POOL_TRYIMPORT;
    enum ZFS_IOC_POOL_SCAN = zfs_ioc.ZFS_IOC_POOL_SCAN;
    enum ZFS_IOC_POOL_FREEZE = zfs_ioc.ZFS_IOC_POOL_FREEZE;
    enum ZFS_IOC_POOL_UPGRADE = zfs_ioc.ZFS_IOC_POOL_UPGRADE;
    enum ZFS_IOC_POOL_GET_HISTORY = zfs_ioc.ZFS_IOC_POOL_GET_HISTORY;
    enum ZFS_IOC_VDEV_ADD = zfs_ioc.ZFS_IOC_VDEV_ADD;
    enum ZFS_IOC_VDEV_REMOVE = zfs_ioc.ZFS_IOC_VDEV_REMOVE;
    enum ZFS_IOC_VDEV_SET_STATE = zfs_ioc.ZFS_IOC_VDEV_SET_STATE;
    enum ZFS_IOC_VDEV_ATTACH = zfs_ioc.ZFS_IOC_VDEV_ATTACH;
    enum ZFS_IOC_VDEV_DETACH = zfs_ioc.ZFS_IOC_VDEV_DETACH;
    enum ZFS_IOC_VDEV_SETPATH = zfs_ioc.ZFS_IOC_VDEV_SETPATH;
    enum ZFS_IOC_VDEV_SETFRU = zfs_ioc.ZFS_IOC_VDEV_SETFRU;
    enum ZFS_IOC_OBJSET_STATS = zfs_ioc.ZFS_IOC_OBJSET_STATS;
    enum ZFS_IOC_OBJSET_ZPLPROPS = zfs_ioc.ZFS_IOC_OBJSET_ZPLPROPS;
    enum ZFS_IOC_DATASET_LIST_NEXT = zfs_ioc.ZFS_IOC_DATASET_LIST_NEXT;
    enum ZFS_IOC_SNAPSHOT_LIST_NEXT = zfs_ioc.ZFS_IOC_SNAPSHOT_LIST_NEXT;
    enum ZFS_IOC_SET_PROP = zfs_ioc.ZFS_IOC_SET_PROP;
    enum ZFS_IOC_CREATE = zfs_ioc.ZFS_IOC_CREATE;
    enum ZFS_IOC_DESTROY = zfs_ioc.ZFS_IOC_DESTROY;
    enum ZFS_IOC_ROLLBACK = zfs_ioc.ZFS_IOC_ROLLBACK;
    enum ZFS_IOC_RENAME = zfs_ioc.ZFS_IOC_RENAME;
    enum ZFS_IOC_RECV = zfs_ioc.ZFS_IOC_RECV;
    enum ZFS_IOC_SEND = zfs_ioc.ZFS_IOC_SEND;
    enum ZFS_IOC_INJECT_FAULT = zfs_ioc.ZFS_IOC_INJECT_FAULT;
    enum ZFS_IOC_CLEAR_FAULT = zfs_ioc.ZFS_IOC_CLEAR_FAULT;
    enum ZFS_IOC_INJECT_LIST_NEXT = zfs_ioc.ZFS_IOC_INJECT_LIST_NEXT;
    enum ZFS_IOC_ERROR_LOG = zfs_ioc.ZFS_IOC_ERROR_LOG;
    enum ZFS_IOC_CLEAR = zfs_ioc.ZFS_IOC_CLEAR;
    enum ZFS_IOC_PROMOTE = zfs_ioc.ZFS_IOC_PROMOTE;
    enum ZFS_IOC_SNAPSHOT = zfs_ioc.ZFS_IOC_SNAPSHOT;
    enum ZFS_IOC_DSOBJ_TO_DSNAME = zfs_ioc.ZFS_IOC_DSOBJ_TO_DSNAME;
    enum ZFS_IOC_OBJ_TO_PATH = zfs_ioc.ZFS_IOC_OBJ_TO_PATH;
    enum ZFS_IOC_POOL_SET_PROPS = zfs_ioc.ZFS_IOC_POOL_SET_PROPS;
    enum ZFS_IOC_POOL_GET_PROPS = zfs_ioc.ZFS_IOC_POOL_GET_PROPS;
    enum ZFS_IOC_SET_FSACL = zfs_ioc.ZFS_IOC_SET_FSACL;
    enum ZFS_IOC_GET_FSACL = zfs_ioc.ZFS_IOC_GET_FSACL;
    enum ZFS_IOC_SHARE = zfs_ioc.ZFS_IOC_SHARE;
    enum ZFS_IOC_INHERIT_PROP = zfs_ioc.ZFS_IOC_INHERIT_PROP;
    enum ZFS_IOC_SMB_ACL = zfs_ioc.ZFS_IOC_SMB_ACL;
    enum ZFS_IOC_USERSPACE_ONE = zfs_ioc.ZFS_IOC_USERSPACE_ONE;
    enum ZFS_IOC_USERSPACE_MANY = zfs_ioc.ZFS_IOC_USERSPACE_MANY;
    enum ZFS_IOC_USERSPACE_UPGRADE = zfs_ioc.ZFS_IOC_USERSPACE_UPGRADE;
    enum ZFS_IOC_HOLD = zfs_ioc.ZFS_IOC_HOLD;
    enum ZFS_IOC_RELEASE = zfs_ioc.ZFS_IOC_RELEASE;
    enum ZFS_IOC_GET_HOLDS = zfs_ioc.ZFS_IOC_GET_HOLDS;
    enum ZFS_IOC_OBJSET_RECVD_PROPS = zfs_ioc.ZFS_IOC_OBJSET_RECVD_PROPS;
    enum ZFS_IOC_VDEV_SPLIT = zfs_ioc.ZFS_IOC_VDEV_SPLIT;
    enum ZFS_IOC_NEXT_OBJ = zfs_ioc.ZFS_IOC_NEXT_OBJ;
    enum ZFS_IOC_DIFF = zfs_ioc.ZFS_IOC_DIFF;
    enum ZFS_IOC_TMP_SNAPSHOT = zfs_ioc.ZFS_IOC_TMP_SNAPSHOT;
    enum ZFS_IOC_OBJ_TO_STATS = zfs_ioc.ZFS_IOC_OBJ_TO_STATS;
    enum ZFS_IOC_SPACE_WRITTEN = zfs_ioc.ZFS_IOC_SPACE_WRITTEN;
    enum ZFS_IOC_SPACE_SNAPS = zfs_ioc.ZFS_IOC_SPACE_SNAPS;
    enum ZFS_IOC_DESTROY_SNAPS = zfs_ioc.ZFS_IOC_DESTROY_SNAPS;
    enum ZFS_IOC_POOL_REGUID = zfs_ioc.ZFS_IOC_POOL_REGUID;
    enum ZFS_IOC_POOL_REOPEN = zfs_ioc.ZFS_IOC_POOL_REOPEN;
    enum ZFS_IOC_SEND_PROGRESS = zfs_ioc.ZFS_IOC_SEND_PROGRESS;
    enum ZFS_IOC_LOG_HISTORY = zfs_ioc.ZFS_IOC_LOG_HISTORY;
    enum ZFS_IOC_SEND_NEW = zfs_ioc.ZFS_IOC_SEND_NEW;
    enum ZFS_IOC_SEND_SPACE = zfs_ioc.ZFS_IOC_SEND_SPACE;
    enum ZFS_IOC_CLONE = zfs_ioc.ZFS_IOC_CLONE;
    enum ZFS_IOC_BOOKMARK = zfs_ioc.ZFS_IOC_BOOKMARK;
    enum ZFS_IOC_GET_BOOKMARKS = zfs_ioc.ZFS_IOC_GET_BOOKMARKS;
    enum ZFS_IOC_DESTROY_BOOKMARKS = zfs_ioc.ZFS_IOC_DESTROY_BOOKMARKS;
    enum ZFS_IOC_RECV_NEW = zfs_ioc.ZFS_IOC_RECV_NEW;
    enum ZFS_IOC_POOL_SYNC = zfs_ioc.ZFS_IOC_POOL_SYNC;
    enum ZFS_IOC_CHANNEL_PROGRAM = zfs_ioc.ZFS_IOC_CHANNEL_PROGRAM;
    enum ZFS_IOC_LOAD_KEY = zfs_ioc.ZFS_IOC_LOAD_KEY;
    enum ZFS_IOC_UNLOAD_KEY = zfs_ioc.ZFS_IOC_UNLOAD_KEY;
    enum ZFS_IOC_CHANGE_KEY = zfs_ioc.ZFS_IOC_CHANGE_KEY;
    enum ZFS_IOC_REMAP = zfs_ioc.ZFS_IOC_REMAP;
    enum ZFS_IOC_POOL_CHECKPOINT = zfs_ioc.ZFS_IOC_POOL_CHECKPOINT;
    enum ZFS_IOC_POOL_DISCARD_CHECKPOINT = zfs_ioc.ZFS_IOC_POOL_DISCARD_CHECKPOINT;
    enum ZFS_IOC_POOL_INITIALIZE = zfs_ioc.ZFS_IOC_POOL_INITIALIZE;
    enum ZFS_IOC_POOL_TRIM = zfs_ioc.ZFS_IOC_POOL_TRIM;
    enum ZFS_IOC_LINUX = zfs_ioc.ZFS_IOC_LINUX;
    enum ZFS_IOC_EVENTS_NEXT = zfs_ioc.ZFS_IOC_EVENTS_NEXT;
    enum ZFS_IOC_EVENTS_CLEAR = zfs_ioc.ZFS_IOC_EVENTS_CLEAR;
    enum ZFS_IOC_EVENTS_SEEK = zfs_ioc.ZFS_IOC_EVENTS_SEEK;
    enum ZFS_IOC_FREEBSD = zfs_ioc.ZFS_IOC_FREEBSD;
    enum ZFS_IOC_LAST = zfs_ioc.ZFS_IOC_LAST;
    alias zfs_ioc_t = zfs_ioc;
    enum _Anonymous_3
    {
        VDEV_TRIM_NONE = 0,
        VDEV_TRIM_ACTIVE = 1,
        VDEV_TRIM_CANCELED = 2,
        VDEV_TRIM_SUSPENDED = 3,
        VDEV_TRIM_COMPLETE = 4,
    }
    enum VDEV_TRIM_NONE = _Anonymous_3.VDEV_TRIM_NONE;
    enum VDEV_TRIM_ACTIVE = _Anonymous_3.VDEV_TRIM_ACTIVE;
    enum VDEV_TRIM_CANCELED = _Anonymous_3.VDEV_TRIM_CANCELED;
    enum VDEV_TRIM_SUSPENDED = _Anonymous_3.VDEV_TRIM_SUSPENDED;
    enum VDEV_TRIM_COMPLETE = _Anonymous_3.VDEV_TRIM_COMPLETE;
    alias vdev_trim_state_t = _Anonymous_3;
    enum _Anonymous_4
    {
        VDEV_INITIALIZE_NONE = 0,
        VDEV_INITIALIZE_ACTIVE = 1,
        VDEV_INITIALIZE_CANCELED = 2,
        VDEV_INITIALIZE_SUSPENDED = 3,
        VDEV_INITIALIZE_COMPLETE = 4,
    }
    enum VDEV_INITIALIZE_NONE = _Anonymous_4.VDEV_INITIALIZE_NONE;
    enum VDEV_INITIALIZE_ACTIVE = _Anonymous_4.VDEV_INITIALIZE_ACTIVE;
    enum VDEV_INITIALIZE_CANCELED = _Anonymous_4.VDEV_INITIALIZE_CANCELED;
    enum VDEV_INITIALIZE_SUSPENDED = _Anonymous_4.VDEV_INITIALIZE_SUSPENDED;
    enum VDEV_INITIALIZE_COMPLETE = _Anonymous_4.VDEV_INITIALIZE_COMPLETE;
    alias vdev_initializing_state_t = _Anonymous_4;
    struct ddt_histogram
    {
        @DppOffsetSize(0,4096) ddt_stat[64] ddh_stat;
    }
    alias ddt_histogram_t = ddt_histogram;
    struct ddt_stat
    {
        @DppOffsetSize(0,8) ulong dds_blocks;
        @DppOffsetSize(8,8) ulong dds_lsize;
        @DppOffsetSize(16,8) ulong dds_psize;
        @DppOffsetSize(24,8) ulong dds_dsize;
        @DppOffsetSize(32,8) ulong dds_ref_blocks;
        @DppOffsetSize(40,8) ulong dds_ref_lsize;
        @DppOffsetSize(48,8) ulong dds_ref_psize;
        @DppOffsetSize(56,8) ulong dds_ref_dsize;
    }
    alias ddt_stat_t = ddt_stat;
    struct ddt_object
    {
        @DppOffsetSize(0,8) ulong ddo_count;
        @DppOffsetSize(8,8) ulong ddo_dspace;
        @DppOffsetSize(16,8) ulong ddo_mspace;
    }
    alias ddt_object_t = ddt_object;
    enum pool_trim_func
    {
        POOL_TRIM_START = 0,
        POOL_TRIM_CANCEL = 1,
        POOL_TRIM_SUSPEND = 2,
        POOL_TRIM_FUNCS = 3,
    }
    enum POOL_TRIM_START = pool_trim_func.POOL_TRIM_START;
    enum POOL_TRIM_CANCEL = pool_trim_func.POOL_TRIM_CANCEL;
    enum POOL_TRIM_SUSPEND = pool_trim_func.POOL_TRIM_SUSPEND;
    enum POOL_TRIM_FUNCS = pool_trim_func.POOL_TRIM_FUNCS;
    alias pool_trim_func_t = pool_trim_func;
    enum pool_initialize_func
    {
        POOL_INITIALIZE_START = 0,
        POOL_INITIALIZE_CANCEL = 1,
        POOL_INITIALIZE_SUSPEND = 2,
        POOL_INITIALIZE_FUNCS = 3,
    }
    enum POOL_INITIALIZE_START = pool_initialize_func.POOL_INITIALIZE_START;
    enum POOL_INITIALIZE_CANCEL = pool_initialize_func.POOL_INITIALIZE_CANCEL;
    enum POOL_INITIALIZE_SUSPEND = pool_initialize_func.POOL_INITIALIZE_SUSPEND;
    enum POOL_INITIALIZE_FUNCS = pool_initialize_func.POOL_INITIALIZE_FUNCS;
    alias pool_initialize_func_t = pool_initialize_func;
    struct vdev_stat_ex
    {
        @DppOffsetSize(0,64) ulong[8] vsx_active_queue;
        @DppOffsetSize(64,64) ulong[8] vsx_pend_queue;
        @DppOffsetSize(128,2368) ulong[37][8] vsx_queue_histo;
        @DppOffsetSize(2496,2072) ulong[37][7] vsx_total_histo;
        @DppOffsetSize(4568,2072) ulong[37][7] vsx_disk_histo;
        @DppOffsetSize(6640,1600) ulong[25][8] vsx_ind_histo;
        @DppOffsetSize(8240,1600) ulong[25][8] vsx_agg_histo;
    }
    alias vdev_stat_ex_t = vdev_stat_ex;
    struct vdev_stat
    {
        @DppOffsetSize(0,8) ulong vs_timestamp;
        @DppOffsetSize(8,8) ulong vs_state;
        @DppOffsetSize(16,8) ulong vs_aux;
        @DppOffsetSize(24,8) ulong vs_alloc;
        @DppOffsetSize(32,8) ulong vs_space;
        @DppOffsetSize(40,8) ulong vs_dspace;
        @DppOffsetSize(48,8) ulong vs_rsize;
        @DppOffsetSize(56,8) ulong vs_esize;
        @DppOffsetSize(64,48) ulong[6] vs_ops;
        @DppOffsetSize(112,48) ulong[6] vs_bytes;
        @DppOffsetSize(160,8) ulong vs_read_errors;
        @DppOffsetSize(168,8) ulong vs_write_errors;
        @DppOffsetSize(176,8) ulong vs_checksum_errors;
        @DppOffsetSize(184,8) ulong vs_initialize_errors;
        @DppOffsetSize(192,8) ulong vs_self_healed;
        @DppOffsetSize(200,8) ulong vs_scan_removing;
        @DppOffsetSize(208,8) ulong vs_scan_processed;
        @DppOffsetSize(216,8) ulong vs_fragmentation;
        @DppOffsetSize(224,8) ulong vs_initialize_bytes_done;
        @DppOffsetSize(232,8) ulong vs_initialize_bytes_est;
        @DppOffsetSize(240,8) ulong vs_initialize_state;
        @DppOffsetSize(248,8) ulong vs_initialize_action_time;
        @DppOffsetSize(256,8) ulong vs_checkpoint_space;
        @DppOffsetSize(264,8) ulong vs_resilver_deferred;
        @DppOffsetSize(272,8) ulong vs_slow_ios;
        @DppOffsetSize(280,8) ulong vs_trim_errors;
        @DppOffsetSize(288,8) ulong vs_trim_notsup;
        @DppOffsetSize(296,8) ulong vs_trim_bytes_done;
        @DppOffsetSize(304,8) ulong vs_trim_bytes_est;
        @DppOffsetSize(312,8) ulong vs_trim_state;
        @DppOffsetSize(320,8) ulong vs_trim_action_time;
    }
    alias vdev_stat_t = vdev_stat;
    enum zpool_errata
    {
        ZPOOL_ERRATA_NONE = 0,
        ZPOOL_ERRATA_ZOL_2094_SCRUB = 1,
        ZPOOL_ERRATA_ZOL_2094_ASYNC_DESTROY = 2,
        ZPOOL_ERRATA_ZOL_6845_ENCRYPTION = 3,
        ZPOOL_ERRATA_ZOL_8308_ENCRYPTION = 4,
    }
    enum ZPOOL_ERRATA_NONE = zpool_errata.ZPOOL_ERRATA_NONE;
    enum ZPOOL_ERRATA_ZOL_2094_SCRUB = zpool_errata.ZPOOL_ERRATA_ZOL_2094_SCRUB;
    enum ZPOOL_ERRATA_ZOL_2094_ASYNC_DESTROY = zpool_errata.ZPOOL_ERRATA_ZOL_2094_ASYNC_DESTROY;
    enum ZPOOL_ERRATA_ZOL_6845_ENCRYPTION = zpool_errata.ZPOOL_ERRATA_ZOL_6845_ENCRYPTION;
    enum ZPOOL_ERRATA_ZOL_8308_ENCRYPTION = zpool_errata.ZPOOL_ERRATA_ZOL_8308_ENCRYPTION;
    alias zpool_errata_t = zpool_errata;
    enum dsl_scan_state
    {
        DSS_NONE = 0,
        DSS_SCANNING = 1,
        DSS_FINISHED = 2,
        DSS_CANCELED = 3,
        DSS_NUM_STATES = 4,
    }
    enum DSS_NONE = dsl_scan_state.DSS_NONE;
    enum DSS_SCANNING = dsl_scan_state.DSS_SCANNING;
    enum DSS_FINISHED = dsl_scan_state.DSS_FINISHED;
    enum DSS_CANCELED = dsl_scan_state.DSS_CANCELED;
    enum DSS_NUM_STATES = dsl_scan_state.DSS_NUM_STATES;
    alias dsl_scan_state_t = dsl_scan_state;
    struct pool_removal_stat
    {
        @DppOffsetSize(0,8) ulong prs_state;
        @DppOffsetSize(8,8) ulong prs_removing_vdev;
        @DppOffsetSize(16,8) ulong prs_start_time;
        @DppOffsetSize(24,8) ulong prs_end_time;
        @DppOffsetSize(32,8) ulong prs_to_copy;
        @DppOffsetSize(40,8) ulong prs_copied;
        @DppOffsetSize(48,8) ulong prs_mapping_memory;
    }
    alias pool_removal_stat_t = pool_removal_stat;
    struct pool_scan_stat
    {
        @DppOffsetSize(0,8) ulong pss_func;
        @DppOffsetSize(8,8) ulong pss_state;
        @DppOffsetSize(16,8) ulong pss_start_time;
        @DppOffsetSize(24,8) ulong pss_end_time;
        @DppOffsetSize(32,8) ulong pss_to_examine;
        @DppOffsetSize(40,8) ulong pss_examined;
        @DppOffsetSize(48,8) ulong pss_to_process;
        @DppOffsetSize(56,8) ulong pss_processed;
        @DppOffsetSize(64,8) ulong pss_errors;
        @DppOffsetSize(72,8) ulong pss_pass_exam;
        @DppOffsetSize(80,8) ulong pss_pass_start;
        @DppOffsetSize(88,8) ulong pss_pass_scrub_pause;
        @DppOffsetSize(96,8) ulong pss_pass_scrub_spent_paused;
        @DppOffsetSize(104,8) ulong pss_pass_issued;
        @DppOffsetSize(112,8) ulong pss_issued;
    }
    alias pool_scan_stat_t = pool_scan_stat;
    enum zio_type
    {
        ZIO_TYPE_NULL = 0,
        ZIO_TYPE_READ = 1,
        ZIO_TYPE_WRITE = 2,
        ZIO_TYPE_FREE = 3,
        ZIO_TYPE_CLAIM = 4,
        ZIO_TYPE_IOCTL = 5,
        ZIO_TYPE_TRIM = 6,
        ZIO_TYPES = 7,
    }
    enum ZIO_TYPE_NULL = zio_type.ZIO_TYPE_NULL;
    enum ZIO_TYPE_READ = zio_type.ZIO_TYPE_READ;
    enum ZIO_TYPE_WRITE = zio_type.ZIO_TYPE_WRITE;
    enum ZIO_TYPE_FREE = zio_type.ZIO_TYPE_FREE;
    enum ZIO_TYPE_CLAIM = zio_type.ZIO_TYPE_CLAIM;
    enum ZIO_TYPE_IOCTL = zio_type.ZIO_TYPE_IOCTL;
    enum ZIO_TYPE_TRIM = zio_type.ZIO_TYPE_TRIM;
    enum ZIO_TYPES = zio_type.ZIO_TYPES;
    alias zio_type_t = zio_type;
    struct pool_checkpoint_stat
    {
        @DppOffsetSize(0,8) ulong pcs_state;
        @DppOffsetSize(8,8) ulong pcs_start_time;
        @DppOffsetSize(16,8) ulong pcs_space;
    }
    alias pool_checkpoint_stat_t = pool_checkpoint_stat;
    enum _Anonymous_5
    {
        CS_NONE = 0,
        CS_CHECKPOINT_EXISTS = 1,
        CS_CHECKPOINT_DISCARDING = 2,
        CS_NUM_STATES = 3,
    }
    enum CS_NONE = _Anonymous_5.CS_NONE;
    enum CS_CHECKPOINT_EXISTS = _Anonymous_5.CS_CHECKPOINT_EXISTS;
    enum CS_CHECKPOINT_DISCARDING = _Anonymous_5.CS_CHECKPOINT_DISCARDING;
    enum CS_NUM_STATES = _Anonymous_5.CS_NUM_STATES;
    alias checkpoint_state_t = _Anonymous_5;
    enum pool_scrub_cmd
    {
        POOL_SCRUB_NORMAL = 0,
        POOL_SCRUB_PAUSE = 1,
        POOL_SCRUB_FLAGS_END = 2,
    }
    enum POOL_SCRUB_NORMAL = pool_scrub_cmd.POOL_SCRUB_NORMAL;
    enum POOL_SCRUB_PAUSE = pool_scrub_cmd.POOL_SCRUB_PAUSE;
    enum POOL_SCRUB_FLAGS_END = pool_scrub_cmd.POOL_SCRUB_FLAGS_END;
    alias pool_scrub_cmd_t = pool_scrub_cmd;
    enum pool_scan_func
    {
        POOL_SCAN_NONE = 0,
        POOL_SCAN_SCRUB = 1,
        POOL_SCAN_RESILVER = 2,
        POOL_SCAN_FUNCS = 3,
    }
    enum POOL_SCAN_NONE = pool_scan_func.POOL_SCAN_NONE;
    enum POOL_SCAN_SCRUB = pool_scan_func.POOL_SCAN_SCRUB;
    enum POOL_SCAN_RESILVER = pool_scan_func.POOL_SCAN_RESILVER;
    enum POOL_SCAN_FUNCS = pool_scan_func.POOL_SCAN_FUNCS;
    alias pool_scan_func_t = pool_scan_func;
    enum mmp_state
    {
        MMP_STATE_ACTIVE = 0,
        MMP_STATE_INACTIVE = 1,
        MMP_STATE_NO_HOSTID = 2,
    }
    enum MMP_STATE_ACTIVE = mmp_state.MMP_STATE_ACTIVE;
    enum MMP_STATE_INACTIVE = mmp_state.MMP_STATE_INACTIVE;
    enum MMP_STATE_NO_HOSTID = mmp_state.MMP_STATE_NO_HOSTID;
    alias mmp_state_t = mmp_state;
    enum pool_state
    {
        POOL_STATE_ACTIVE = 0,
        POOL_STATE_EXPORTED = 1,
        POOL_STATE_DESTROYED = 2,
        POOL_STATE_SPARE = 3,
        POOL_STATE_L2CACHE = 4,
        POOL_STATE_UNINITIALIZED = 5,
        POOL_STATE_UNAVAIL = 6,
        POOL_STATE_POTENTIALLY_ACTIVE = 7,
    }
    enum POOL_STATE_ACTIVE = pool_state.POOL_STATE_ACTIVE;
    enum POOL_STATE_EXPORTED = pool_state.POOL_STATE_EXPORTED;
    enum POOL_STATE_DESTROYED = pool_state.POOL_STATE_DESTROYED;
    enum POOL_STATE_SPARE = pool_state.POOL_STATE_SPARE;
    enum POOL_STATE_L2CACHE = pool_state.POOL_STATE_L2CACHE;
    enum POOL_STATE_UNINITIALIZED = pool_state.POOL_STATE_UNINITIALIZED;
    enum POOL_STATE_UNAVAIL = pool_state.POOL_STATE_UNAVAIL;
    enum POOL_STATE_POTENTIALLY_ACTIVE = pool_state.POOL_STATE_POTENTIALLY_ACTIVE;
    alias pool_state_t = pool_state;
    enum vdev_aux
    {
        VDEV_AUX_NONE = 0,
        VDEV_AUX_OPEN_FAILED = 1,
        VDEV_AUX_CORRUPT_DATA = 2,
        VDEV_AUX_NO_REPLICAS = 3,
        VDEV_AUX_BAD_GUID_SUM = 4,
        VDEV_AUX_TOO_SMALL = 5,
        VDEV_AUX_BAD_LABEL = 6,
        VDEV_AUX_VERSION_NEWER = 7,
        VDEV_AUX_VERSION_OLDER = 8,
        VDEV_AUX_UNSUP_FEAT = 9,
        VDEV_AUX_SPARED = 10,
        VDEV_AUX_ERR_EXCEEDED = 11,
        VDEV_AUX_IO_FAILURE = 12,
        VDEV_AUX_BAD_LOG = 13,
        VDEV_AUX_EXTERNAL = 14,
        VDEV_AUX_SPLIT_POOL = 15,
        VDEV_AUX_BAD_ASHIFT = 16,
        VDEV_AUX_EXTERNAL_PERSIST = 17,
        VDEV_AUX_ACTIVE = 18,
        VDEV_AUX_CHILDREN_OFFLINE = 19,
    }
    enum VDEV_AUX_NONE = vdev_aux.VDEV_AUX_NONE;
    enum VDEV_AUX_OPEN_FAILED = vdev_aux.VDEV_AUX_OPEN_FAILED;
    enum VDEV_AUX_CORRUPT_DATA = vdev_aux.VDEV_AUX_CORRUPT_DATA;
    enum VDEV_AUX_NO_REPLICAS = vdev_aux.VDEV_AUX_NO_REPLICAS;
    enum VDEV_AUX_BAD_GUID_SUM = vdev_aux.VDEV_AUX_BAD_GUID_SUM;
    enum VDEV_AUX_TOO_SMALL = vdev_aux.VDEV_AUX_TOO_SMALL;
    enum VDEV_AUX_BAD_LABEL = vdev_aux.VDEV_AUX_BAD_LABEL;
    enum VDEV_AUX_VERSION_NEWER = vdev_aux.VDEV_AUX_VERSION_NEWER;
    enum VDEV_AUX_VERSION_OLDER = vdev_aux.VDEV_AUX_VERSION_OLDER;
    enum VDEV_AUX_UNSUP_FEAT = vdev_aux.VDEV_AUX_UNSUP_FEAT;
    enum VDEV_AUX_SPARED = vdev_aux.VDEV_AUX_SPARED;
    enum VDEV_AUX_ERR_EXCEEDED = vdev_aux.VDEV_AUX_ERR_EXCEEDED;
    enum VDEV_AUX_IO_FAILURE = vdev_aux.VDEV_AUX_IO_FAILURE;
    enum VDEV_AUX_BAD_LOG = vdev_aux.VDEV_AUX_BAD_LOG;
    enum VDEV_AUX_EXTERNAL = vdev_aux.VDEV_AUX_EXTERNAL;
    enum VDEV_AUX_SPLIT_POOL = vdev_aux.VDEV_AUX_SPLIT_POOL;
    enum VDEV_AUX_BAD_ASHIFT = vdev_aux.VDEV_AUX_BAD_ASHIFT;
    enum VDEV_AUX_EXTERNAL_PERSIST = vdev_aux.VDEV_AUX_EXTERNAL_PERSIST;
    enum VDEV_AUX_ACTIVE = vdev_aux.VDEV_AUX_ACTIVE;
    enum VDEV_AUX_CHILDREN_OFFLINE = vdev_aux.VDEV_AUX_CHILDREN_OFFLINE;
    alias vdev_aux_t = vdev_aux;
    enum vdev_state
    {
        VDEV_STATE_UNKNOWN = 0,
        VDEV_STATE_CLOSED = 1,
        VDEV_STATE_OFFLINE = 2,
        VDEV_STATE_REMOVED = 3,
        VDEV_STATE_CANT_OPEN = 4,
        VDEV_STATE_FAULTED = 5,
        VDEV_STATE_DEGRADED = 6,
        VDEV_STATE_HEALTHY = 7,
    }
    enum VDEV_STATE_UNKNOWN = vdev_state.VDEV_STATE_UNKNOWN;
    enum VDEV_STATE_CLOSED = vdev_state.VDEV_STATE_CLOSED;
    enum VDEV_STATE_OFFLINE = vdev_state.VDEV_STATE_OFFLINE;
    enum VDEV_STATE_REMOVED = vdev_state.VDEV_STATE_REMOVED;
    enum VDEV_STATE_CANT_OPEN = vdev_state.VDEV_STATE_CANT_OPEN;
    enum VDEV_STATE_FAULTED = vdev_state.VDEV_STATE_FAULTED;
    enum VDEV_STATE_DEGRADED = vdev_state.VDEV_STATE_DEGRADED;
    enum VDEV_STATE_HEALTHY = vdev_state.VDEV_STATE_HEALTHY;
    alias vdev_state_t = vdev_state;
    struct zpool_load_policy
    {
        @DppOffsetSize(0,4) uint zlp_rewind;
        @DppOffsetSize(8,8) ulong zlp_maxmeta;
        @DppOffsetSize(16,8) ulong zlp_maxdata;
        @DppOffsetSize(24,8) ulong zlp_txg;
    }
    alias zpool_load_policy_t = zpool_load_policy;
    enum zfs_key_location
    {
        ZFS_KEYLOCATION_NONE = 0,
        ZFS_KEYLOCATION_PROMPT = 1,
        ZFS_KEYLOCATION_URI = 2,
        ZFS_KEYLOCATION_LOCATIONS = 3,
    }
    enum ZFS_KEYLOCATION_NONE = zfs_key_location.ZFS_KEYLOCATION_NONE;
    enum ZFS_KEYLOCATION_PROMPT = zfs_key_location.ZFS_KEYLOCATION_PROMPT;
    enum ZFS_KEYLOCATION_URI = zfs_key_location.ZFS_KEYLOCATION_URI;
    enum ZFS_KEYLOCATION_LOCATIONS = zfs_key_location.ZFS_KEYLOCATION_LOCATIONS;
    alias zfs_keylocation_t = zfs_key_location;
    enum zfs_keyformat
    {
        ZFS_KEYFORMAT_NONE = 0,
        ZFS_KEYFORMAT_RAW = 1,
        ZFS_KEYFORMAT_HEX = 2,
        ZFS_KEYFORMAT_PASSPHRASE = 3,
        ZFS_KEYFORMAT_FORMATS = 4,
    }
    enum ZFS_KEYFORMAT_NONE = zfs_keyformat.ZFS_KEYFORMAT_NONE;
    enum ZFS_KEYFORMAT_RAW = zfs_keyformat.ZFS_KEYFORMAT_RAW;
    enum ZFS_KEYFORMAT_HEX = zfs_keyformat.ZFS_KEYFORMAT_HEX;
    enum ZFS_KEYFORMAT_PASSPHRASE = zfs_keyformat.ZFS_KEYFORMAT_PASSPHRASE;
    enum ZFS_KEYFORMAT_FORMATS = zfs_keyformat.ZFS_KEYFORMAT_FORMATS;
    alias zfs_keyformat_t = zfs_keyformat;
    enum zfs_keystatus
    {
        ZFS_KEYSTATUS_NONE = 0,
        ZFS_KEYSTATUS_UNAVAILABLE = 1,
        ZFS_KEYSTATUS_AVAILABLE = 2,
    }
    enum ZFS_KEYSTATUS_NONE = zfs_keystatus.ZFS_KEYSTATUS_NONE;
    enum ZFS_KEYSTATUS_UNAVAILABLE = zfs_keystatus.ZFS_KEYSTATUS_UNAVAILABLE;
    enum ZFS_KEYSTATUS_AVAILABLE = zfs_keystatus.ZFS_KEYSTATUS_AVAILABLE;
    alias zfs_keystatus_t = zfs_keystatus;
    enum _Anonymous_6
    {
        ZFS_VOLMODE_DEFAULT = 0,
        ZFS_VOLMODE_GEOM = 1,
        ZFS_VOLMODE_DEV = 2,
        ZFS_VOLMODE_NONE = 3,
    }
    enum ZFS_VOLMODE_DEFAULT = _Anonymous_6.ZFS_VOLMODE_DEFAULT;
    enum ZFS_VOLMODE_GEOM = _Anonymous_6.ZFS_VOLMODE_GEOM;
    enum ZFS_VOLMODE_DEV = _Anonymous_6.ZFS_VOLMODE_DEV;
    enum ZFS_VOLMODE_NONE = _Anonymous_6.ZFS_VOLMODE_NONE;
    alias zfs_volmode_t = _Anonymous_6;
    enum _Anonymous_7
    {
        ZFS_REDUNDANT_METADATA_ALL = 0,
        ZFS_REDUNDANT_METADATA_MOST = 1,
    }
    enum ZFS_REDUNDANT_METADATA_ALL = _Anonymous_7.ZFS_REDUNDANT_METADATA_ALL;
    enum ZFS_REDUNDANT_METADATA_MOST = _Anonymous_7.ZFS_REDUNDANT_METADATA_MOST;
    alias zfs_redundant_metadata_type_t = _Anonymous_7;
    enum _Anonymous_8
    {
        ZFS_DNSIZE_LEGACY = 0,
        ZFS_DNSIZE_AUTO = 1,
        ZFS_DNSIZE_1K = 1024,
        ZFS_DNSIZE_2K = 2048,
        ZFS_DNSIZE_4K = 4096,
        ZFS_DNSIZE_8K = 8192,
        ZFS_DNSIZE_16K = 16384,
    }
    enum ZFS_DNSIZE_LEGACY = _Anonymous_8.ZFS_DNSIZE_LEGACY;
    enum ZFS_DNSIZE_AUTO = _Anonymous_8.ZFS_DNSIZE_AUTO;
    enum ZFS_DNSIZE_1K = _Anonymous_8.ZFS_DNSIZE_1K;
    enum ZFS_DNSIZE_2K = _Anonymous_8.ZFS_DNSIZE_2K;
    enum ZFS_DNSIZE_4K = _Anonymous_8.ZFS_DNSIZE_4K;
    enum ZFS_DNSIZE_8K = _Anonymous_8.ZFS_DNSIZE_8K;
    enum ZFS_DNSIZE_16K = _Anonymous_8.ZFS_DNSIZE_16K;
    alias zfs_dnsize_type_t = _Anonymous_8;
    enum _Anonymous_9
    {
        ZFS_XATTR_OFF = 0,
        ZFS_XATTR_DIR = 1,
        ZFS_XATTR_SA = 2,
    }
    enum ZFS_XATTR_OFF = _Anonymous_9.ZFS_XATTR_OFF;
    enum ZFS_XATTR_DIR = _Anonymous_9.ZFS_XATTR_DIR;
    enum ZFS_XATTR_SA = _Anonymous_9.ZFS_XATTR_SA;
    alias zfs_xattr_type_t = _Anonymous_9;
    enum _Anonymous_10
    {
        ZFS_SYNC_STANDARD = 0,
        ZFS_SYNC_ALWAYS = 1,
        ZFS_SYNC_DISABLED = 2,
    }
    enum ZFS_SYNC_STANDARD = _Anonymous_10.ZFS_SYNC_STANDARD;
    enum ZFS_SYNC_ALWAYS = _Anonymous_10.ZFS_SYNC_ALWAYS;
    enum ZFS_SYNC_DISABLED = _Anonymous_10.ZFS_SYNC_DISABLED;
    alias zfs_sync_type_t = _Anonymous_10;
    enum zfs_cache_type
    {
        ZFS_CACHE_NONE = 0,
        ZFS_CACHE_METADATA = 1,
        ZFS_CACHE_ALL = 2,
    }
    enum ZFS_CACHE_NONE = zfs_cache_type.ZFS_CACHE_NONE;
    enum ZFS_CACHE_METADATA = zfs_cache_type.ZFS_CACHE_METADATA;
    enum ZFS_CACHE_ALL = zfs_cache_type.ZFS_CACHE_ALL;
    alias zfs_cache_type_t = zfs_cache_type;
    enum zfs_smb_acl_op
    {
        ZFS_SMB_ACL_ADD = 0,
        ZFS_SMB_ACL_REMOVE = 1,
        ZFS_SMB_ACL_RENAME = 2,
        ZFS_SMB_ACL_PURGE = 3,
    }
    enum ZFS_SMB_ACL_ADD = zfs_smb_acl_op.ZFS_SMB_ACL_ADD;
    enum ZFS_SMB_ACL_REMOVE = zfs_smb_acl_op.ZFS_SMB_ACL_REMOVE;
    enum ZFS_SMB_ACL_RENAME = zfs_smb_acl_op.ZFS_SMB_ACL_RENAME;
    enum ZFS_SMB_ACL_PURGE = zfs_smb_acl_op.ZFS_SMB_ACL_PURGE;
    alias zfs_smb_acl_op_t = zfs_smb_acl_op;
    enum zfs_share_op
    {
        ZFS_SHARE_NFS = 0,
        ZFS_UNSHARE_NFS = 1,
        ZFS_SHARE_SMB = 2,
        ZFS_UNSHARE_SMB = 3,
    }
    enum ZFS_SHARE_NFS = zfs_share_op.ZFS_SHARE_NFS;
    enum ZFS_UNSHARE_NFS = zfs_share_op.ZFS_UNSHARE_NFS;
    enum ZFS_SHARE_SMB = zfs_share_op.ZFS_SHARE_SMB;
    enum ZFS_UNSHARE_SMB = zfs_share_op.ZFS_UNSHARE_SMB;
    alias zfs_share_op_t = zfs_share_op;
    enum _Anonymous_11
    {
        ZFS_LOGBIAS_LATENCY = 0,
        ZFS_LOGBIAS_THROUGHPUT = 1,
    }
    enum ZFS_LOGBIAS_LATENCY = _Anonymous_11.ZFS_LOGBIAS_LATENCY;
    enum ZFS_LOGBIAS_THROUGHPUT = _Anonymous_11.ZFS_LOGBIAS_THROUGHPUT;
    alias zfs_logbias_op_t = _Anonymous_11;
    enum _Anonymous_12
    {
        ZFS_CANMOUNT_OFF = 0,
        ZFS_CANMOUNT_ON = 1,
        ZFS_CANMOUNT_NOAUTO = 2,
    }
    enum ZFS_CANMOUNT_OFF = _Anonymous_12.ZFS_CANMOUNT_OFF;
    enum ZFS_CANMOUNT_ON = _Anonymous_12.ZFS_CANMOUNT_ON;
    enum ZFS_CANMOUNT_NOAUTO = _Anonymous_12.ZFS_CANMOUNT_NOAUTO;
    alias zfs_canmount_type_t = _Anonymous_12;
    enum _Anonymous_13
    {
        ZFS_DELEG_NONE = 0,
        ZFS_DELEG_PERM_LOCAL = 1,
        ZFS_DELEG_PERM_DESCENDENT = 2,
        ZFS_DELEG_PERM_LOCALDESCENDENT = 3,
        ZFS_DELEG_PERM_CREATE = 4,
    }
    enum ZFS_DELEG_NONE = _Anonymous_13.ZFS_DELEG_NONE;
    enum ZFS_DELEG_PERM_LOCAL = _Anonymous_13.ZFS_DELEG_PERM_LOCAL;
    enum ZFS_DELEG_PERM_DESCENDENT = _Anonymous_13.ZFS_DELEG_PERM_DESCENDENT;
    enum ZFS_DELEG_PERM_LOCALDESCENDENT = _Anonymous_13.ZFS_DELEG_PERM_LOCALDESCENDENT;
    enum ZFS_DELEG_PERM_CREATE = _Anonymous_13.ZFS_DELEG_PERM_CREATE;
    alias zfs_deleg_inherit_t = _Anonymous_13;
    enum _Anonymous_14
    {
        ZFS_DELEG_WHO_UNKNOWN = 0,
        ZFS_DELEG_USER = 117,
        ZFS_DELEG_USER_SETS = 85,
        ZFS_DELEG_GROUP = 103,
        ZFS_DELEG_GROUP_SETS = 71,
        ZFS_DELEG_EVERYONE = 101,
        ZFS_DELEG_EVERYONE_SETS = 69,
        ZFS_DELEG_CREATE = 99,
        ZFS_DELEG_CREATE_SETS = 67,
        ZFS_DELEG_NAMED_SET = 115,
        ZFS_DELEG_NAMED_SET_SETS = 83,
    }
    enum ZFS_DELEG_WHO_UNKNOWN = _Anonymous_14.ZFS_DELEG_WHO_UNKNOWN;
    enum ZFS_DELEG_USER = _Anonymous_14.ZFS_DELEG_USER;
    enum ZFS_DELEG_USER_SETS = _Anonymous_14.ZFS_DELEG_USER_SETS;
    enum ZFS_DELEG_GROUP = _Anonymous_14.ZFS_DELEG_GROUP;
    enum ZFS_DELEG_GROUP_SETS = _Anonymous_14.ZFS_DELEG_GROUP_SETS;
    enum ZFS_DELEG_EVERYONE = _Anonymous_14.ZFS_DELEG_EVERYONE;
    enum ZFS_DELEG_EVERYONE_SETS = _Anonymous_14.ZFS_DELEG_EVERYONE_SETS;
    enum ZFS_DELEG_CREATE = _Anonymous_14.ZFS_DELEG_CREATE;
    enum ZFS_DELEG_CREATE_SETS = _Anonymous_14.ZFS_DELEG_CREATE_SETS;
    enum ZFS_DELEG_NAMED_SET = _Anonymous_14.ZFS_DELEG_NAMED_SET;
    enum ZFS_DELEG_NAMED_SET_SETS = _Anonymous_14.ZFS_DELEG_NAMED_SET_SETS;
    alias zfs_deleg_who_type_t = _Anonymous_14;
    ulong zpool_prop_random_value(zpool_prop_t, ulong) @nogc nothrow;
    int zpool_prop_string_to_index(zpool_prop_t, const(char)*, ulong*) @nogc nothrow;
    int zpool_prop_index_to_string(zpool_prop_t, ulong, const(char)**) @nogc nothrow;
    int zpool_prop_unsupported(const(char)*) @nogc nothrow;
    int zpool_prop_feature(const(char)*) @nogc nothrow;
    int zpool_prop_setonce(zpool_prop_t) @nogc nothrow;
    int zpool_prop_readonly(zpool_prop_t) @nogc nothrow;
    ulong zpool_prop_default_numeric(zpool_prop_t) @nogc nothrow;
    const(char)* zpool_prop_default_string(zpool_prop_t) @nogc nothrow;
    const(char)* zpool_prop_to_name(zpool_prop_t) @nogc nothrow;
    zpool_prop_t zpool_name_to_prop(const(char)*) @nogc nothrow;
    int zfs_prop_valid_for_type(int, zfs_type_t, int) @nogc nothrow;
    ulong zfs_prop_random_value(zfs_prop_t, ulong) @nogc nothrow;
    int zfs_prop_string_to_index(zfs_prop_t, const(char)*, ulong*) @nogc nothrow;
    int zfs_prop_index_to_string(zfs_prop_t, ulong, const(char)**) @nogc nothrow;
    int zfs_prop_written(const(char)*) @nogc nothrow;
    int zfs_prop_userquota(const(char)*) @nogc nothrow;
    int zfs_prop_user(const(char)*) @nogc nothrow;
    zfs_prop_t zfs_name_to_prop(const(char)*) @nogc nothrow;
    const(char)* zfs_prop_to_name(zfs_prop_t) @nogc nothrow;
    int zfs_prop_valid_keylocation(const(char)*, int) @nogc nothrow;
    int zfs_prop_encryption_key_param(zfs_prop_t) @nogc nothrow;
    int zfs_prop_setonce(zfs_prop_t) @nogc nothrow;
    int zfs_prop_inheritable(zfs_prop_t) @nogc nothrow;
    int zfs_prop_visible(zfs_prop_t) @nogc nothrow;
    int zfs_prop_readonly(zfs_prop_t) @nogc nothrow;
    ulong zfs_prop_default_numeric(zfs_prop_t) @nogc nothrow;
    const(char)* zfs_prop_default_string(zfs_prop_t) @nogc nothrow;
    alias zprop_func = int function(int, void*);
    enum _Anonymous_15
    {
        ZPROP_ERR_NOCLEAR = 1,
        ZPROP_ERR_NORESTORE = 2,
    }
    enum ZPROP_ERR_NOCLEAR = _Anonymous_15.ZPROP_ERR_NOCLEAR;
    enum ZPROP_ERR_NORESTORE = _Anonymous_15.ZPROP_ERR_NORESTORE;
    alias zprop_errflags_t = _Anonymous_15;
    enum _Anonymous_16
    {
        ZPROP_SRC_NONE = 1,
        ZPROP_SRC_DEFAULT = 2,
        ZPROP_SRC_TEMPORARY = 4,
        ZPROP_SRC_LOCAL = 8,
        ZPROP_SRC_INHERITED = 16,
        ZPROP_SRC_RECEIVED = 32,
    }
    enum ZPROP_SRC_NONE = _Anonymous_16.ZPROP_SRC_NONE;
    enum ZPROP_SRC_DEFAULT = _Anonymous_16.ZPROP_SRC_DEFAULT;
    enum ZPROP_SRC_TEMPORARY = _Anonymous_16.ZPROP_SRC_TEMPORARY;
    enum ZPROP_SRC_LOCAL = _Anonymous_16.ZPROP_SRC_LOCAL;
    enum ZPROP_SRC_INHERITED = _Anonymous_16.ZPROP_SRC_INHERITED;
    enum ZPROP_SRC_RECEIVED = _Anonymous_16.ZPROP_SRC_RECEIVED;
    alias zprop_source_t = _Anonymous_16;
    enum _Anonymous_17
    {
        ZPOOL_PROP_INVAL = -1,
        ZPOOL_PROP_NAME = 0,
        ZPOOL_PROP_SIZE = 1,
        ZPOOL_PROP_CAPACITY = 2,
        ZPOOL_PROP_ALTROOT = 3,
        ZPOOL_PROP_HEALTH = 4,
        ZPOOL_PROP_GUID = 5,
        ZPOOL_PROP_VERSION = 6,
        ZPOOL_PROP_BOOTFS = 7,
        ZPOOL_PROP_DELEGATION = 8,
        ZPOOL_PROP_AUTOREPLACE = 9,
        ZPOOL_PROP_CACHEFILE = 10,
        ZPOOL_PROP_FAILUREMODE = 11,
        ZPOOL_PROP_LISTSNAPS = 12,
        ZPOOL_PROP_AUTOEXPAND = 13,
        ZPOOL_PROP_DEDUPDITTO = 14,
        ZPOOL_PROP_DEDUPRATIO = 15,
        ZPOOL_PROP_FREE = 16,
        ZPOOL_PROP_ALLOCATED = 17,
        ZPOOL_PROP_READONLY = 18,
        ZPOOL_PROP_ASHIFT = 19,
        ZPOOL_PROP_COMMENT = 20,
        ZPOOL_PROP_EXPANDSZ = 21,
        ZPOOL_PROP_FREEING = 22,
        ZPOOL_PROP_FRAGMENTATION = 23,
        ZPOOL_PROP_LEAKED = 24,
        ZPOOL_PROP_MAXBLOCKSIZE = 25,
        ZPOOL_PROP_TNAME = 26,
        ZPOOL_PROP_MAXDNODESIZE = 27,
        ZPOOL_PROP_MULTIHOST = 28,
        ZPOOL_PROP_CHECKPOINT = 29,
        ZPOOL_PROP_LOAD_GUID = 30,
        ZPOOL_PROP_AUTOTRIM = 31,
        ZPOOL_NUM_PROPS = 32,
    }
    enum ZPOOL_PROP_INVAL = _Anonymous_17.ZPOOL_PROP_INVAL;
    enum ZPOOL_PROP_NAME = _Anonymous_17.ZPOOL_PROP_NAME;
    enum ZPOOL_PROP_SIZE = _Anonymous_17.ZPOOL_PROP_SIZE;
    enum ZPOOL_PROP_CAPACITY = _Anonymous_17.ZPOOL_PROP_CAPACITY;
    enum ZPOOL_PROP_ALTROOT = _Anonymous_17.ZPOOL_PROP_ALTROOT;
    enum ZPOOL_PROP_HEALTH = _Anonymous_17.ZPOOL_PROP_HEALTH;
    enum ZPOOL_PROP_GUID = _Anonymous_17.ZPOOL_PROP_GUID;
    enum ZPOOL_PROP_VERSION = _Anonymous_17.ZPOOL_PROP_VERSION;
    enum ZPOOL_PROP_BOOTFS = _Anonymous_17.ZPOOL_PROP_BOOTFS;
    enum ZPOOL_PROP_DELEGATION = _Anonymous_17.ZPOOL_PROP_DELEGATION;
    enum ZPOOL_PROP_AUTOREPLACE = _Anonymous_17.ZPOOL_PROP_AUTOREPLACE;
    enum ZPOOL_PROP_CACHEFILE = _Anonymous_17.ZPOOL_PROP_CACHEFILE;
    enum ZPOOL_PROP_FAILUREMODE = _Anonymous_17.ZPOOL_PROP_FAILUREMODE;
    enum ZPOOL_PROP_LISTSNAPS = _Anonymous_17.ZPOOL_PROP_LISTSNAPS;
    enum ZPOOL_PROP_AUTOEXPAND = _Anonymous_17.ZPOOL_PROP_AUTOEXPAND;
    enum ZPOOL_PROP_DEDUPDITTO = _Anonymous_17.ZPOOL_PROP_DEDUPDITTO;
    enum ZPOOL_PROP_DEDUPRATIO = _Anonymous_17.ZPOOL_PROP_DEDUPRATIO;
    enum ZPOOL_PROP_FREE = _Anonymous_17.ZPOOL_PROP_FREE;
    enum ZPOOL_PROP_ALLOCATED = _Anonymous_17.ZPOOL_PROP_ALLOCATED;
    enum ZPOOL_PROP_READONLY = _Anonymous_17.ZPOOL_PROP_READONLY;
    enum ZPOOL_PROP_ASHIFT = _Anonymous_17.ZPOOL_PROP_ASHIFT;
    enum ZPOOL_PROP_COMMENT = _Anonymous_17.ZPOOL_PROP_COMMENT;
    enum ZPOOL_PROP_EXPANDSZ = _Anonymous_17.ZPOOL_PROP_EXPANDSZ;
    enum ZPOOL_PROP_FREEING = _Anonymous_17.ZPOOL_PROP_FREEING;
    enum ZPOOL_PROP_FRAGMENTATION = _Anonymous_17.ZPOOL_PROP_FRAGMENTATION;
    enum ZPOOL_PROP_LEAKED = _Anonymous_17.ZPOOL_PROP_LEAKED;
    enum ZPOOL_PROP_MAXBLOCKSIZE = _Anonymous_17.ZPOOL_PROP_MAXBLOCKSIZE;
    enum ZPOOL_PROP_TNAME = _Anonymous_17.ZPOOL_PROP_TNAME;
    enum ZPOOL_PROP_MAXDNODESIZE = _Anonymous_17.ZPOOL_PROP_MAXDNODESIZE;
    enum ZPOOL_PROP_MULTIHOST = _Anonymous_17.ZPOOL_PROP_MULTIHOST;
    enum ZPOOL_PROP_CHECKPOINT = _Anonymous_17.ZPOOL_PROP_CHECKPOINT;
    enum ZPOOL_PROP_LOAD_GUID = _Anonymous_17.ZPOOL_PROP_LOAD_GUID;
    enum ZPOOL_PROP_AUTOTRIM = _Anonymous_17.ZPOOL_PROP_AUTOTRIM;
    enum ZPOOL_NUM_PROPS = _Anonymous_17.ZPOOL_NUM_PROPS;
    alias zpool_prop_t = _Anonymous_17;
    extern __gshared const(char)*[12] zfs_userquota_prop_prefixes;
    enum _Anonymous_18
    {
        ZFS_PROP_USERUSED = 0,
        ZFS_PROP_USERQUOTA = 1,
        ZFS_PROP_GROUPUSED = 2,
        ZFS_PROP_GROUPQUOTA = 3,
        ZFS_PROP_USEROBJUSED = 4,
        ZFS_PROP_USEROBJQUOTA = 5,
        ZFS_PROP_GROUPOBJUSED = 6,
        ZFS_PROP_GROUPOBJQUOTA = 7,
        ZFS_PROP_PROJECTUSED = 8,
        ZFS_PROP_PROJECTQUOTA = 9,
        ZFS_PROP_PROJECTOBJUSED = 10,
        ZFS_PROP_PROJECTOBJQUOTA = 11,
        ZFS_NUM_USERQUOTA_PROPS = 12,
    }
    enum ZFS_PROP_USERUSED = _Anonymous_18.ZFS_PROP_USERUSED;
    enum ZFS_PROP_USERQUOTA = _Anonymous_18.ZFS_PROP_USERQUOTA;
    enum ZFS_PROP_GROUPUSED = _Anonymous_18.ZFS_PROP_GROUPUSED;
    enum ZFS_PROP_GROUPQUOTA = _Anonymous_18.ZFS_PROP_GROUPQUOTA;
    enum ZFS_PROP_USEROBJUSED = _Anonymous_18.ZFS_PROP_USEROBJUSED;
    enum ZFS_PROP_USEROBJQUOTA = _Anonymous_18.ZFS_PROP_USEROBJQUOTA;
    enum ZFS_PROP_GROUPOBJUSED = _Anonymous_18.ZFS_PROP_GROUPOBJUSED;
    enum ZFS_PROP_GROUPOBJQUOTA = _Anonymous_18.ZFS_PROP_GROUPOBJQUOTA;
    enum ZFS_PROP_PROJECTUSED = _Anonymous_18.ZFS_PROP_PROJECTUSED;
    enum ZFS_PROP_PROJECTQUOTA = _Anonymous_18.ZFS_PROP_PROJECTQUOTA;
    enum ZFS_PROP_PROJECTOBJUSED = _Anonymous_18.ZFS_PROP_PROJECTOBJUSED;
    enum ZFS_PROP_PROJECTOBJQUOTA = _Anonymous_18.ZFS_PROP_PROJECTOBJQUOTA;
    enum ZFS_NUM_USERQUOTA_PROPS = _Anonymous_18.ZFS_NUM_USERQUOTA_PROPS;
    alias zfs_userquota_prop_t = _Anonymous_18;
    enum _Anonymous_19
    {
        ZPROP_CONT = -2,
        ZPROP_INVAL = -1,
        ZFS_PROP_TYPE = 0,
        ZFS_PROP_CREATION = 1,
        ZFS_PROP_USED = 2,
        ZFS_PROP_AVAILABLE = 3,
        ZFS_PROP_REFERENCED = 4,
        ZFS_PROP_COMPRESSRATIO = 5,
        ZFS_PROP_MOUNTED = 6,
        ZFS_PROP_ORIGIN = 7,
        ZFS_PROP_QUOTA = 8,
        ZFS_PROP_RESERVATION = 9,
        ZFS_PROP_VOLSIZE = 10,
        ZFS_PROP_VOLBLOCKSIZE = 11,
        ZFS_PROP_RECORDSIZE = 12,
        ZFS_PROP_MOUNTPOINT = 13,
        ZFS_PROP_SHARENFS = 14,
        ZFS_PROP_CHECKSUM = 15,
        ZFS_PROP_COMPRESSION = 16,
        ZFS_PROP_ATIME = 17,
        ZFS_PROP_DEVICES = 18,
        ZFS_PROP_EXEC = 19,
        ZFS_PROP_SETUID = 20,
        ZFS_PROP_READONLY = 21,
        ZFS_PROP_ZONED = 22,
        ZFS_PROP_SNAPDIR = 23,
        ZFS_PROP_PRIVATE = 24,
        ZFS_PROP_ACLINHERIT = 25,
        ZFS_PROP_CREATETXG = 26,
        ZFS_PROP_NAME = 27,
        ZFS_PROP_CANMOUNT = 28,
        ZFS_PROP_ISCSIOPTIONS = 29,
        ZFS_PROP_XATTR = 30,
        ZFS_PROP_NUMCLONES = 31,
        ZFS_PROP_COPIES = 32,
        ZFS_PROP_VERSION = 33,
        ZFS_PROP_UTF8ONLY = 34,
        ZFS_PROP_NORMALIZE = 35,
        ZFS_PROP_CASE = 36,
        ZFS_PROP_VSCAN = 37,
        ZFS_PROP_NBMAND = 38,
        ZFS_PROP_SHARESMB = 39,
        ZFS_PROP_REFQUOTA = 40,
        ZFS_PROP_REFRESERVATION = 41,
        ZFS_PROP_GUID = 42,
        ZFS_PROP_PRIMARYCACHE = 43,
        ZFS_PROP_SECONDARYCACHE = 44,
        ZFS_PROP_USEDSNAP = 45,
        ZFS_PROP_USEDDS = 46,
        ZFS_PROP_USEDCHILD = 47,
        ZFS_PROP_USEDREFRESERV = 48,
        ZFS_PROP_USERACCOUNTING = 49,
        ZFS_PROP_STMF_SHAREINFO = 50,
        ZFS_PROP_DEFER_DESTROY = 51,
        ZFS_PROP_USERREFS = 52,
        ZFS_PROP_LOGBIAS = 53,
        ZFS_PROP_UNIQUE = 54,
        ZFS_PROP_OBJSETID = 55,
        ZFS_PROP_DEDUP = 56,
        ZFS_PROP_MLSLABEL = 57,
        ZFS_PROP_SYNC = 58,
        ZFS_PROP_DNODESIZE = 59,
        ZFS_PROP_REFRATIO = 60,
        ZFS_PROP_WRITTEN = 61,
        ZFS_PROP_CLONES = 62,
        ZFS_PROP_LOGICALUSED = 63,
        ZFS_PROP_LOGICALREFERENCED = 64,
        ZFS_PROP_INCONSISTENT = 65,
        ZFS_PROP_VOLMODE = 66,
        ZFS_PROP_FILESYSTEM_LIMIT = 67,
        ZFS_PROP_SNAPSHOT_LIMIT = 68,
        ZFS_PROP_FILESYSTEM_COUNT = 69,
        ZFS_PROP_SNAPSHOT_COUNT = 70,
        ZFS_PROP_SNAPDEV = 71,
        ZFS_PROP_ACLTYPE = 72,
        ZFS_PROP_SELINUX_CONTEXT = 73,
        ZFS_PROP_SELINUX_FSCONTEXT = 74,
        ZFS_PROP_SELINUX_DEFCONTEXT = 75,
        ZFS_PROP_SELINUX_ROOTCONTEXT = 76,
        ZFS_PROP_RELATIME = 77,
        ZFS_PROP_REDUNDANT_METADATA = 78,
        ZFS_PROP_OVERLAY = 79,
        ZFS_PROP_PREV_SNAP = 80,
        ZFS_PROP_RECEIVE_RESUME_TOKEN = 81,
        ZFS_PROP_ENCRYPTION = 82,
        ZFS_PROP_KEYLOCATION = 83,
        ZFS_PROP_KEYFORMAT = 84,
        ZFS_PROP_PBKDF2_SALT = 85,
        ZFS_PROP_PBKDF2_ITERS = 86,
        ZFS_PROP_ENCRYPTION_ROOT = 87,
        ZFS_PROP_KEY_GUID = 88,
        ZFS_PROP_KEYSTATUS = 89,
        ZFS_PROP_REMAPTXG = 90,
        ZFS_PROP_SPECIAL_SMALL_BLOCKS = 91,
        ZFS_PROP_IVSET_GUID = 92,
        ZFS_NUM_PROPS = 93,
    }
    enum ZPROP_CONT = _Anonymous_19.ZPROP_CONT;
    enum ZPROP_INVAL = _Anonymous_19.ZPROP_INVAL;
    enum ZFS_PROP_TYPE = _Anonymous_19.ZFS_PROP_TYPE;
    enum ZFS_PROP_CREATION = _Anonymous_19.ZFS_PROP_CREATION;
    enum ZFS_PROP_USED = _Anonymous_19.ZFS_PROP_USED;
    enum ZFS_PROP_AVAILABLE = _Anonymous_19.ZFS_PROP_AVAILABLE;
    enum ZFS_PROP_REFERENCED = _Anonymous_19.ZFS_PROP_REFERENCED;
    enum ZFS_PROP_COMPRESSRATIO = _Anonymous_19.ZFS_PROP_COMPRESSRATIO;
    enum ZFS_PROP_MOUNTED = _Anonymous_19.ZFS_PROP_MOUNTED;
    enum ZFS_PROP_ORIGIN = _Anonymous_19.ZFS_PROP_ORIGIN;
    enum ZFS_PROP_QUOTA = _Anonymous_19.ZFS_PROP_QUOTA;
    enum ZFS_PROP_RESERVATION = _Anonymous_19.ZFS_PROP_RESERVATION;
    enum ZFS_PROP_VOLSIZE = _Anonymous_19.ZFS_PROP_VOLSIZE;
    enum ZFS_PROP_VOLBLOCKSIZE = _Anonymous_19.ZFS_PROP_VOLBLOCKSIZE;
    enum ZFS_PROP_RECORDSIZE = _Anonymous_19.ZFS_PROP_RECORDSIZE;
    enum ZFS_PROP_MOUNTPOINT = _Anonymous_19.ZFS_PROP_MOUNTPOINT;
    enum ZFS_PROP_SHARENFS = _Anonymous_19.ZFS_PROP_SHARENFS;
    enum ZFS_PROP_CHECKSUM = _Anonymous_19.ZFS_PROP_CHECKSUM;
    enum ZFS_PROP_COMPRESSION = _Anonymous_19.ZFS_PROP_COMPRESSION;
    enum ZFS_PROP_ATIME = _Anonymous_19.ZFS_PROP_ATIME;
    enum ZFS_PROP_DEVICES = _Anonymous_19.ZFS_PROP_DEVICES;
    enum ZFS_PROP_EXEC = _Anonymous_19.ZFS_PROP_EXEC;
    enum ZFS_PROP_SETUID = _Anonymous_19.ZFS_PROP_SETUID;
    enum ZFS_PROP_READONLY = _Anonymous_19.ZFS_PROP_READONLY;
    enum ZFS_PROP_ZONED = _Anonymous_19.ZFS_PROP_ZONED;
    enum ZFS_PROP_SNAPDIR = _Anonymous_19.ZFS_PROP_SNAPDIR;
    enum ZFS_PROP_PRIVATE = _Anonymous_19.ZFS_PROP_PRIVATE;
    enum ZFS_PROP_ACLINHERIT = _Anonymous_19.ZFS_PROP_ACLINHERIT;
    enum ZFS_PROP_CREATETXG = _Anonymous_19.ZFS_PROP_CREATETXG;
    enum ZFS_PROP_NAME = _Anonymous_19.ZFS_PROP_NAME;
    enum ZFS_PROP_CANMOUNT = _Anonymous_19.ZFS_PROP_CANMOUNT;
    enum ZFS_PROP_ISCSIOPTIONS = _Anonymous_19.ZFS_PROP_ISCSIOPTIONS;
    enum ZFS_PROP_XATTR = _Anonymous_19.ZFS_PROP_XATTR;
    enum ZFS_PROP_NUMCLONES = _Anonymous_19.ZFS_PROP_NUMCLONES;
    enum ZFS_PROP_COPIES = _Anonymous_19.ZFS_PROP_COPIES;
    enum ZFS_PROP_VERSION = _Anonymous_19.ZFS_PROP_VERSION;
    enum ZFS_PROP_UTF8ONLY = _Anonymous_19.ZFS_PROP_UTF8ONLY;
    enum ZFS_PROP_NORMALIZE = _Anonymous_19.ZFS_PROP_NORMALIZE;
    enum ZFS_PROP_CASE = _Anonymous_19.ZFS_PROP_CASE;
    enum ZFS_PROP_VSCAN = _Anonymous_19.ZFS_PROP_VSCAN;
    enum ZFS_PROP_NBMAND = _Anonymous_19.ZFS_PROP_NBMAND;
    enum ZFS_PROP_SHARESMB = _Anonymous_19.ZFS_PROP_SHARESMB;
    enum ZFS_PROP_REFQUOTA = _Anonymous_19.ZFS_PROP_REFQUOTA;
    enum ZFS_PROP_REFRESERVATION = _Anonymous_19.ZFS_PROP_REFRESERVATION;
    enum ZFS_PROP_GUID = _Anonymous_19.ZFS_PROP_GUID;
    enum ZFS_PROP_PRIMARYCACHE = _Anonymous_19.ZFS_PROP_PRIMARYCACHE;
    enum ZFS_PROP_SECONDARYCACHE = _Anonymous_19.ZFS_PROP_SECONDARYCACHE;
    enum ZFS_PROP_USEDSNAP = _Anonymous_19.ZFS_PROP_USEDSNAP;
    enum ZFS_PROP_USEDDS = _Anonymous_19.ZFS_PROP_USEDDS;
    enum ZFS_PROP_USEDCHILD = _Anonymous_19.ZFS_PROP_USEDCHILD;
    enum ZFS_PROP_USEDREFRESERV = _Anonymous_19.ZFS_PROP_USEDREFRESERV;
    enum ZFS_PROP_USERACCOUNTING = _Anonymous_19.ZFS_PROP_USERACCOUNTING;
    enum ZFS_PROP_STMF_SHAREINFO = _Anonymous_19.ZFS_PROP_STMF_SHAREINFO;
    enum ZFS_PROP_DEFER_DESTROY = _Anonymous_19.ZFS_PROP_DEFER_DESTROY;
    enum ZFS_PROP_USERREFS = _Anonymous_19.ZFS_PROP_USERREFS;
    enum ZFS_PROP_LOGBIAS = _Anonymous_19.ZFS_PROP_LOGBIAS;
    enum ZFS_PROP_UNIQUE = _Anonymous_19.ZFS_PROP_UNIQUE;
    enum ZFS_PROP_OBJSETID = _Anonymous_19.ZFS_PROP_OBJSETID;
    enum ZFS_PROP_DEDUP = _Anonymous_19.ZFS_PROP_DEDUP;
    enum ZFS_PROP_MLSLABEL = _Anonymous_19.ZFS_PROP_MLSLABEL;
    enum ZFS_PROP_SYNC = _Anonymous_19.ZFS_PROP_SYNC;
    enum ZFS_PROP_DNODESIZE = _Anonymous_19.ZFS_PROP_DNODESIZE;
    enum ZFS_PROP_REFRATIO = _Anonymous_19.ZFS_PROP_REFRATIO;
    enum ZFS_PROP_WRITTEN = _Anonymous_19.ZFS_PROP_WRITTEN;
    enum ZFS_PROP_CLONES = _Anonymous_19.ZFS_PROP_CLONES;
    enum ZFS_PROP_LOGICALUSED = _Anonymous_19.ZFS_PROP_LOGICALUSED;
    enum ZFS_PROP_LOGICALREFERENCED = _Anonymous_19.ZFS_PROP_LOGICALREFERENCED;
    enum ZFS_PROP_INCONSISTENT = _Anonymous_19.ZFS_PROP_INCONSISTENT;
    enum ZFS_PROP_VOLMODE = _Anonymous_19.ZFS_PROP_VOLMODE;
    enum ZFS_PROP_FILESYSTEM_LIMIT = _Anonymous_19.ZFS_PROP_FILESYSTEM_LIMIT;
    enum ZFS_PROP_SNAPSHOT_LIMIT = _Anonymous_19.ZFS_PROP_SNAPSHOT_LIMIT;
    enum ZFS_PROP_FILESYSTEM_COUNT = _Anonymous_19.ZFS_PROP_FILESYSTEM_COUNT;
    enum ZFS_PROP_SNAPSHOT_COUNT = _Anonymous_19.ZFS_PROP_SNAPSHOT_COUNT;
    enum ZFS_PROP_SNAPDEV = _Anonymous_19.ZFS_PROP_SNAPDEV;
    enum ZFS_PROP_ACLTYPE = _Anonymous_19.ZFS_PROP_ACLTYPE;
    enum ZFS_PROP_SELINUX_CONTEXT = _Anonymous_19.ZFS_PROP_SELINUX_CONTEXT;
    enum ZFS_PROP_SELINUX_FSCONTEXT = _Anonymous_19.ZFS_PROP_SELINUX_FSCONTEXT;
    enum ZFS_PROP_SELINUX_DEFCONTEXT = _Anonymous_19.ZFS_PROP_SELINUX_DEFCONTEXT;
    enum ZFS_PROP_SELINUX_ROOTCONTEXT = _Anonymous_19.ZFS_PROP_SELINUX_ROOTCONTEXT;
    enum ZFS_PROP_RELATIME = _Anonymous_19.ZFS_PROP_RELATIME;
    enum ZFS_PROP_REDUNDANT_METADATA = _Anonymous_19.ZFS_PROP_REDUNDANT_METADATA;
    enum ZFS_PROP_OVERLAY = _Anonymous_19.ZFS_PROP_OVERLAY;
    enum ZFS_PROP_PREV_SNAP = _Anonymous_19.ZFS_PROP_PREV_SNAP;
    enum ZFS_PROP_RECEIVE_RESUME_TOKEN = _Anonymous_19.ZFS_PROP_RECEIVE_RESUME_TOKEN;
    enum ZFS_PROP_ENCRYPTION = _Anonymous_19.ZFS_PROP_ENCRYPTION;
    enum ZFS_PROP_KEYLOCATION = _Anonymous_19.ZFS_PROP_KEYLOCATION;
    enum ZFS_PROP_KEYFORMAT = _Anonymous_19.ZFS_PROP_KEYFORMAT;
    enum ZFS_PROP_PBKDF2_SALT = _Anonymous_19.ZFS_PROP_PBKDF2_SALT;
    enum ZFS_PROP_PBKDF2_ITERS = _Anonymous_19.ZFS_PROP_PBKDF2_ITERS;
    enum ZFS_PROP_ENCRYPTION_ROOT = _Anonymous_19.ZFS_PROP_ENCRYPTION_ROOT;
    enum ZFS_PROP_KEY_GUID = _Anonymous_19.ZFS_PROP_KEY_GUID;
    enum ZFS_PROP_KEYSTATUS = _Anonymous_19.ZFS_PROP_KEYSTATUS;
    enum ZFS_PROP_REMAPTXG = _Anonymous_19.ZFS_PROP_REMAPTXG;
    enum ZFS_PROP_SPECIAL_SMALL_BLOCKS = _Anonymous_19.ZFS_PROP_SPECIAL_SMALL_BLOCKS;
    enum ZFS_PROP_IVSET_GUID = _Anonymous_19.ZFS_PROP_IVSET_GUID;
    enum ZFS_NUM_PROPS = _Anonymous_19.ZFS_NUM_PROPS;
    alias zfs_prop_t = _Anonymous_19;
    enum dmu_objset_type
    {
        DMU_OST_NONE = 0,
        DMU_OST_META = 1,
        DMU_OST_ZFS = 2,
        DMU_OST_ZVOL = 3,
        DMU_OST_OTHER = 4,
        DMU_OST_ANY = 5,
        DMU_OST_NUMTYPES = 6,
    }
    enum DMU_OST_NONE = dmu_objset_type.DMU_OST_NONE;
    enum DMU_OST_META = dmu_objset_type.DMU_OST_META;
    enum DMU_OST_ZFS = dmu_objset_type.DMU_OST_ZFS;
    enum DMU_OST_ZVOL = dmu_objset_type.DMU_OST_ZVOL;
    enum DMU_OST_OTHER = dmu_objset_type.DMU_OST_OTHER;
    enum DMU_OST_ANY = dmu_objset_type.DMU_OST_ANY;
    enum DMU_OST_NUMTYPES = dmu_objset_type.DMU_OST_NUMTYPES;
    alias dmu_objset_type_t = dmu_objset_type;
    enum _Anonymous_20
    {
        ZFS_TYPE_FILESYSTEM = 1,
        ZFS_TYPE_SNAPSHOT = 2,
        ZFS_TYPE_VOLUME = 4,
        ZFS_TYPE_POOL = 8,
        ZFS_TYPE_BOOKMARK = 16,
    }
    enum ZFS_TYPE_FILESYSTEM = _Anonymous_20.ZFS_TYPE_FILESYSTEM;
    enum ZFS_TYPE_SNAPSHOT = _Anonymous_20.ZFS_TYPE_SNAPSHOT;
    enum ZFS_TYPE_VOLUME = _Anonymous_20.ZFS_TYPE_VOLUME;
    enum ZFS_TYPE_POOL = _Anonymous_20.ZFS_TYPE_POOL;
    enum ZFS_TYPE_BOOKMARK = _Anonymous_20.ZFS_TYPE_BOOKMARK;
    alias zfs_type_t = _Anonymous_20;
    int nvpair_value_match(nvpair*, int, char*, char**) @nogc nothrow;
    int nvpair_value_match_regex(nvpair*, int, char*, re_pattern_buffer*, char**) @nogc nothrow;
    void nvlist_print(_IO_FILE*, nvlist*) @nogc nothrow;
    int nvlist_print_json(_IO_FILE*, nvlist*) @nogc nothrow;
    void dump_nvlist(nvlist*, int) @nogc nothrow;
    alias nvlist_prtctl_t = nvlist_prtctl*;
    struct nvlist_prtctl;
    enum nvlist_indent_mode
    {
        NVLIST_INDENT_ABS = 0,
        NVLIST_INDENT_TABBED = 1,
    }
    enum NVLIST_INDENT_ABS = nvlist_indent_mode.NVLIST_INDENT_ABS;
    enum NVLIST_INDENT_TABBED = nvlist_indent_mode.NVLIST_INDENT_TABBED;
    nvlist_prtctl* nvlist_prtctl_alloc() @nogc nothrow;
    void nvlist_prtctl_free(nvlist_prtctl*) @nogc nothrow;
    void nvlist_prt(nvlist*, nvlist_prtctl*) @nogc nothrow;
    void nvlist_prtctl_setdest(nvlist_prtctl*, _IO_FILE*) @nogc nothrow;
    _IO_FILE* nvlist_prtctl_getdest(nvlist_prtctl*) @nogc nothrow;
    void nvlist_prtctl_setindent(nvlist_prtctl*, nvlist_indent_mode, int, int) @nogc nothrow;
    void nvlist_prtctl_doindent(nvlist_prtctl*, int) @nogc nothrow;
    enum nvlist_prtctl_fmt
    {
        NVLIST_FMT_MEMBER_NAME = 0,
        NVLIST_FMT_MEMBER_POSTAMBLE = 1,
        NVLIST_FMT_BTWN_ARRAY = 2,
    }
    enum NVLIST_FMT_MEMBER_NAME = nvlist_prtctl_fmt.NVLIST_FMT_MEMBER_NAME;
    enum NVLIST_FMT_MEMBER_POSTAMBLE = nvlist_prtctl_fmt.NVLIST_FMT_MEMBER_POSTAMBLE;
    enum NVLIST_FMT_BTWN_ARRAY = nvlist_prtctl_fmt.NVLIST_FMT_BTWN_ARRAY;
    void nvlist_prtctl_setfmt(nvlist_prtctl*, nvlist_prtctl_fmt, const(char)*) @nogc nothrow;
    void nvlist_prtctl_dofmt(nvlist_prtctl*, nvlist_prtctl_fmt, ...) @nogc nothrow;
    alias wchar_t = int;
    void nvlist_prtctlop_boolean(nvlist_prtctl*, int function(nvlist_prtctl*, void*, nvlist*, const(char)*, int), void*) @nogc nothrow;
    void nvlist_prtctlop_boolean_value(nvlist_prtctl*, int function(nvlist_prtctl*, void*, nvlist*, const(char)*, int), void*) @nogc nothrow;
    void nvlist_prtctlop_byte(nvlist_prtctl*, int function(nvlist_prtctl*, void*, nvlist*, const(char)*, ubyte), void*) @nogc nothrow;
    void nvlist_prtctlop_int8(nvlist_prtctl*, int function(nvlist_prtctl*, void*, nvlist*, const(char)*, byte), void*) @nogc nothrow;
    void nvlist_prtctlop_uint8(nvlist_prtctl*, int function(nvlist_prtctl*, void*, nvlist*, const(char)*, ubyte), void*) @nogc nothrow;
    void nvlist_prtctlop_int16(nvlist_prtctl*, int function(nvlist_prtctl*, void*, nvlist*, const(char)*, short), void*) @nogc nothrow;
    void nvlist_prtctlop_uint16(nvlist_prtctl*, int function(nvlist_prtctl*, void*, nvlist*, const(char)*, ushort), void*) @nogc nothrow;
    void nvlist_prtctlop_int32(nvlist_prtctl*, int function(nvlist_prtctl*, void*, nvlist*, const(char)*, int), void*) @nogc nothrow;
    void nvlist_prtctlop_uint32(nvlist_prtctl*, int function(nvlist_prtctl*, void*, nvlist*, const(char)*, uint), void*) @nogc nothrow;
    void nvlist_prtctlop_int64(nvlist_prtctl*, int function(nvlist_prtctl*, void*, nvlist*, const(char)*, c_long), void*) @nogc nothrow;
    void nvlist_prtctlop_uint64(nvlist_prtctl*, int function(nvlist_prtctl*, void*, nvlist*, const(char)*, ulong), void*) @nogc nothrow;
    void nvlist_prtctlop_double(nvlist_prtctl*, int function(nvlist_prtctl*, void*, nvlist*, const(char)*, double), void*) @nogc nothrow;
    void nvlist_prtctlop_string(nvlist_prtctl*, int function(nvlist_prtctl*, void*, nvlist*, const(char)*, char*), void*) @nogc nothrow;
    void nvlist_prtctlop_hrtime(nvlist_prtctl*, int function(nvlist_prtctl*, void*, nvlist*, const(char)*, ulong), void*) @nogc nothrow;
    void nvlist_prtctlop_nvlist(nvlist_prtctl*, int function(nvlist_prtctl*, void*, nvlist*, const(char)*, nvlist*), void*) @nogc nothrow;
    void nvlist_prtctlop_boolean_array(nvlist_prtctl*, int function(nvlist_prtctl*, void*, nvlist*, const(char)*, int*, uint), void*) @nogc nothrow;
    void nvlist_prtctlop_byte_array(nvlist_prtctl*, int function(nvlist_prtctl*, void*, nvlist*, const(char)*, ubyte*, uint), void*) @nogc nothrow;
    void nvlist_prtctlop_int8_array(nvlist_prtctl*, int function(nvlist_prtctl*, void*, nvlist*, const(char)*, byte*, uint), void*) @nogc nothrow;
    void nvlist_prtctlop_uint8_array(nvlist_prtctl*, int function(nvlist_prtctl*, void*, nvlist*, const(char)*, ubyte*, uint), void*) @nogc nothrow;
    void nvlist_prtctlop_int16_array(nvlist_prtctl*, int function(nvlist_prtctl*, void*, nvlist*, const(char)*, short*, uint), void*) @nogc nothrow;
    void nvlist_prtctlop_uint16_array(nvlist_prtctl*, int function(nvlist_prtctl*, void*, nvlist*, const(char)*, ushort*, uint), void*) @nogc nothrow;
    void nvlist_prtctlop_int32_array(nvlist_prtctl*, int function(nvlist_prtctl*, void*, nvlist*, const(char)*, int*, uint), void*) @nogc nothrow;
    void nvlist_prtctlop_uint32_array(nvlist_prtctl*, int function(nvlist_prtctl*, void*, nvlist*, const(char)*, uint*, uint), void*) @nogc nothrow;
    void nvlist_prtctlop_int64_array(nvlist_prtctl*, int function(nvlist_prtctl*, void*, nvlist*, const(char)*, c_long*, uint), void*) @nogc nothrow;
    void nvlist_prtctlop_uint64_array(nvlist_prtctl*, int function(nvlist_prtctl*, void*, nvlist*, const(char)*, ulong*, uint), void*) @nogc nothrow;
    void nvlist_prtctlop_string_array(nvlist_prtctl*, int function(nvlist_prtctl*, void*, nvlist*, const(char)*, char**, uint), void*) @nogc nothrow;
    void nvlist_prtctlop_nvlist_array(nvlist_prtctl*, int function(nvlist_prtctl*, void*, nvlist*, const(char)*, nvlist**, uint), void*) @nogc nothrow;
    int libzfs_core_init() @nogc nothrow;
    void libzfs_core_fini() @nogc nothrow;
    enum lzc_dataset_type
    {
        LZC_DATSET_TYPE_ZFS = 2,
        LZC_DATSET_TYPE_ZVOL = 3,
    }
    enum LZC_DATSET_TYPE_ZFS = lzc_dataset_type.LZC_DATSET_TYPE_ZFS;
    enum LZC_DATSET_TYPE_ZVOL = lzc_dataset_type.LZC_DATSET_TYPE_ZVOL;
    int lzc_remap(const(char)*) @nogc nothrow;
    int lzc_snapshot(nvlist*, nvlist*, nvlist**) @nogc nothrow;
    int lzc_create(const(char)*, lzc_dataset_type, nvlist*, ubyte*, uint) @nogc nothrow;
    int lzc_clone(const(char)*, const(char)*, nvlist*) @nogc nothrow;
    int lzc_promote(const(char)*, char*, int) @nogc nothrow;
    int lzc_destroy_snaps(nvlist*, int, nvlist**) @nogc nothrow;
    int lzc_bookmark(nvlist*, nvlist**) @nogc nothrow;
    int lzc_get_bookmarks(const(char)*, nvlist*, nvlist**) @nogc nothrow;
    int lzc_destroy_bookmarks(nvlist*, nvlist**) @nogc nothrow;
    int lzc_load_key(const(char)*, int, ubyte*, uint) @nogc nothrow;
    int lzc_unload_key(const(char)*) @nogc nothrow;
    int lzc_change_key(const(char)*, ulong, nvlist*, ubyte*, uint) @nogc nothrow;
    int lzc_initialize(const(char)*, pool_initialize_func, nvlist*, nvlist**) @nogc nothrow;
    int lzc_trim(const(char)*, pool_trim_func, ulong, int, nvlist*, nvlist**) @nogc nothrow;
    int lzc_snaprange_space(const(char)*, const(char)*, ulong*) @nogc nothrow;
    int lzc_hold(nvlist*, int, nvlist**) @nogc nothrow;
    int lzc_release(nvlist*, nvlist**) @nogc nothrow;
    int lzc_get_holds(const(char)*, nvlist**) @nogc nothrow;
    enum lzc_send_flags
    {
        LZC_SEND_FLAG_EMBED_DATA = 1,
        LZC_SEND_FLAG_LARGE_BLOCK = 2,
        LZC_SEND_FLAG_COMPRESS = 4,
        LZC_SEND_FLAG_RAW = 8,
    }
    enum LZC_SEND_FLAG_EMBED_DATA = lzc_send_flags.LZC_SEND_FLAG_EMBED_DATA;
    enum LZC_SEND_FLAG_LARGE_BLOCK = lzc_send_flags.LZC_SEND_FLAG_LARGE_BLOCK;
    enum LZC_SEND_FLAG_COMPRESS = lzc_send_flags.LZC_SEND_FLAG_COMPRESS;
    enum LZC_SEND_FLAG_RAW = lzc_send_flags.LZC_SEND_FLAG_RAW;
    int lzc_send(const(char)*, const(char)*, int, lzc_send_flags) @nogc nothrow;
    int lzc_send_resume(const(char)*, const(char)*, int, lzc_send_flags, ulong, ulong) @nogc nothrow;
    int lzc_send_space(const(char)*, const(char)*, lzc_send_flags, ulong*) @nogc nothrow;
    struct dmu_replay_record;
    int lzc_receive(const(char)*, nvlist*, const(char)*, int, int, int) @nogc nothrow;
    int lzc_receive_resumable(const(char)*, nvlist*, const(char)*, int, int, int) @nogc nothrow;
    int lzc_receive_with_header(const(char)*, nvlist*, const(char)*, int, int, int, int, const(dmu_replay_record)*) @nogc nothrow;
    int lzc_receive_one(const(char)*, nvlist*, const(char)*, int, int, int, int, const(dmu_replay_record)*, int, ulong*, ulong*, ulong*, nvlist**) @nogc nothrow;
    int lzc_receive_with_cmdprops(const(char)*, nvlist*, nvlist*, ubyte*, uint, const(char)*, int, int, int, int, const(dmu_replay_record)*, int, ulong*, ulong*, ulong*, nvlist**) @nogc nothrow;
    int lzc_exists(const(char)*) @nogc nothrow;
    int lzc_rollback(const(char)*, char*, int) @nogc nothrow;
    int lzc_rollback_to(const(char)*, const(char)*) @nogc nothrow;
    int lzc_rename(const(char)*, const(char)*) @nogc nothrow;
    int lzc_destroy(const(char)*) @nogc nothrow;
    int lzc_channel_program(const(char)*, const(char)*, ulong, ulong, nvlist*, nvlist**) @nogc nothrow;
    int lzc_channel_program_nosync(const(char)*, const(char)*, ulong, ulong, nvlist*, nvlist**) @nogc nothrow;
    int lzc_sync(const(char)*, nvlist*, nvlist**) @nogc nothrow;
    int lzc_reopen(const(char)*, int) @nogc nothrow;
    int lzc_pool_checkpoint(const(char)*) @nogc nothrow;
    int lzc_pool_checkpoint_discard(const(char)*) @nogc nothrow;
    pragma(mangle, "alloca") void* alloca_(c_ulong) @nogc nothrow;
    alias size_t = c_ulong;
    struct ucontext_t
    {
        @DppOffsetSize(0,8) c_ulong uc_flags;
        @DppOffsetSize(8,8) ucontext_t* uc_link;
        @DppOffsetSize(16,24) stack_t uc_stack;
        @DppOffsetSize(40,256) mcontext_t uc_mcontext;
        @DppOffsetSize(296,128) __sigset_t uc_sigmask;
        @DppOffsetSize(424,512) _libc_fpstate __fpregs_mem;
        @DppOffsetSize(936,32) ulong[4] __ssp;
    }
    struct mcontext_t
    {
        @DppOffsetSize(0,184) long[23] gregs;
        @DppOffsetSize(184,8) _libc_fpstate* fpregs;
        @DppOffsetSize(192,64) ulong[8] __reserved1;
    }
    alias fpregset_t = _libc_fpstate*;
    struct _libc_fpstate
    {
        @DppOffsetSize(0,2) ushort cwd;
        @DppOffsetSize(2,2) ushort swd;
        @DppOffsetSize(4,2) ushort ftw;
        @DppOffsetSize(6,2) ushort fop;
        @DppOffsetSize(8,8) c_ulong rip;
        @DppOffsetSize(16,8) c_ulong rdp;
        @DppOffsetSize(24,4) uint mxcsr;
        @DppOffsetSize(28,4) uint mxcr_mask;
        @DppOffsetSize(32,128) _libc_fpxreg[8] _st;
        @DppOffsetSize(160,256) _libc_xmmreg[16] _xmm;
        @DppOffsetSize(416,96) uint[24] __glibc_reserved1;
    }
    struct _libc_xmmreg
    {
        @DppOffsetSize(0,16) uint[4] element;
    }
    struct _libc_fpxreg
    {
        @DppOffsetSize(0,8) ushort[4] significand;
        @DppOffsetSize(8,2) ushort exponent;
        @DppOffsetSize(10,6) ushort[3] __glibc_reserved1;
    }
    alias gregset_t = long[23];
    alias greg_t = long;
    alias fsfilcnt_t = c_ulong;
    alias fsblkcnt_t = c_ulong;
    alias blkcnt_t = c_long;
    alias blksize_t = c_long;
    alias register_t = c_long;
    alias u_int64_t = c_ulong;
    alias u_int32_t = uint;
    alias u_int16_t = ushort;
    alias u_int8_t = ubyte;
    alias key_t = int;
    alias caddr_t = char*;
    alias daddr_t = int;
    alias ssize_t = c_long;
    alias id_t = uint;
    alias pid_t = int;
    alias off_t = c_long;
    alias uid_t = uint;
    alias nlink_t = c_ulong;
    alias mode_t = uint;
    alias gid_t = uint;
    alias dev_t = c_ulong;
    alias ino_t = c_ulong;
    alias loff_t = c_long;
    alias fsid_t = __fsid_t;
    alias u_quad_t = c_ulong;
    alias quad_t = c_long;
    alias u_long = c_ulong;
    alias u_int = uint;
    alias u_short = ushort;
    alias u_char = ubyte;
    int futimes(int, const(timeval)*) @nogc nothrow;
    int lutimes(const(char)*, const(timeval)*) @nogc nothrow;
    int utimes(const(char)*, const(timeval)*) @nogc nothrow;
    int setitimer(int, const(itimerval)*, itimerval*) @nogc nothrow;
    int getitimer(int, itimerval*) @nogc nothrow;
    alias __itimer_which_t = int;
    struct itimerval
    {
        @DppOffsetSize(0,16) timeval it_interval;
        @DppOffsetSize(16,16) timeval it_value;
    }
    enum __itimer_which
    {
        ITIMER_REAL = 0,
        ITIMER_VIRTUAL = 1,
        ITIMER_PROF = 2,
    }
    enum ITIMER_REAL = __itimer_which.ITIMER_REAL;
    enum ITIMER_VIRTUAL = __itimer_which.ITIMER_VIRTUAL;
    enum ITIMER_PROF = __itimer_which.ITIMER_PROF;
    int adjtime(const(timeval)*, timeval*) @nogc nothrow;
    int settimeofday(const(timeval)*, const(timezone)*) @nogc nothrow;
    int gettimeofday(timeval*, timezone*) @nogc nothrow;
    alias __timezone_ptr_t = timezone*;
    struct timezone
    {
        @DppOffsetSize(0,4) int tz_minuteswest;
        @DppOffsetSize(4,4) int tz_dsttime;
    }
    alias _Float32 = float;
    alias _Float64 = double;
    alias _Float32x = double;
    int pselect(int, fd_set*, fd_set*, fd_set*, const(timespec)*, const(__sigset_t)*) @nogc nothrow;
    alias _Float64x = real;
    int select(int, fd_set*, fd_set*, fd_set*, timeval*) @nogc nothrow;
    alias fd_mask = c_long;
    struct fd_set
    {
        @DppOffsetSize(0,128) c_long[16] __fds_bits;
    }
    alias __fd_mask = c_long;
    alias suseconds_t = c_long;
    int getloadavg(double*, int) @nogc nothrow;
    int getsubopt(char**, char**, char**) @nogc nothrow;
    struct __pthread_rwlock_arch_t
    {
        @DppOffsetSize(0,4) uint __readers;
        @DppOffsetSize(4,4) uint __writers;
        @DppOffsetSize(8,4) uint __wrphase_futex;
        @DppOffsetSize(12,4) uint __writers_futex;
        @DppOffsetSize(16,4) uint __pad3;
        @DppOffsetSize(20,4) uint __pad4;
        @DppOffsetSize(24,4) int __cur_writer;
        @DppOffsetSize(28,4) int __shared;
        @DppOffsetSize(32,1) byte __rwelision;
        @DppOffsetSize(33,7) ubyte[7] __pad1;
        @DppOffsetSize(40,8) c_ulong __pad2;
        @DppOffsetSize(48,4) uint __flags;
    }
    int rpmatch(const(char)*) @nogc nothrow;
    alias pthread_t = c_ulong;
    union pthread_mutexattr_t
    {
        @DppOffsetSize(0,4) char[4] __size;
        @DppOffsetSize(0,4) int __align;
    }
    union pthread_condattr_t
    {
        @DppOffsetSize(0,4) char[4] __size;
        @DppOffsetSize(0,4) int __align;
    }
    alias pthread_key_t = uint;
    alias pthread_once_t = int;
    union pthread_attr_t
    {
        @DppOffsetSize(0,56) char[56] __size;
        @DppOffsetSize(0,8) c_long __align;
    }
    union pthread_mutex_t
    {
        @DppOffsetSize(0,40) __pthread_mutex_s __data;
        @DppOffsetSize(0,40) char[40] __size;
        @DppOffsetSize(0,8) c_long __align;
    }
    union pthread_cond_t
    {
        @DppOffsetSize(0,48) __pthread_cond_s __data;
        @DppOffsetSize(0,48) char[48] __size;
        @DppOffsetSize(0,8) long __align;
    }
    union pthread_rwlock_t
    {
        @DppOffsetSize(0,56) __pthread_rwlock_arch_t __data;
        @DppOffsetSize(0,56) char[56] __size;
        @DppOffsetSize(0,8) c_long __align;
    }
    union pthread_rwlockattr_t
    {
        @DppOffsetSize(0,8) char[8] __size;
        @DppOffsetSize(0,8) c_long __align;
    }
    alias pthread_spinlock_t = int;
    union pthread_barrier_t
    {
        @DppOffsetSize(0,32) char[32] __size;
        @DppOffsetSize(0,8) c_long __align;
    }
    union pthread_barrierattr_t
    {
        @DppOffsetSize(0,4) char[4] __size;
        @DppOffsetSize(0,4) int __align;
    }
    c_ulong wcstombs(char*, const(int)*, c_ulong) @nogc nothrow;
    c_ulong mbstowcs(int*, const(char)*, c_ulong) @nogc nothrow;
    int wctomb(char*, int) @nogc nothrow;
    struct sigaction
    {
        static union _Anonymous_21
        {
            @DppOffsetSize(0,8) void function(int) sa_handler;
            @DppOffsetSize(0,8) void function(int, siginfo_t*, void*) sa_sigaction;
        }
        @DppOffsetSize(0,8) _Anonymous_21 __sigaction_handler;
        @DppOffsetSize(8,128) __sigset_t sa_mask;
        @DppOffsetSize(136,4) int sa_flags;
        @DppOffsetSize(144,8) void function() sa_restorer;
    }
    int mbtowc(int*, const(char)*, c_ulong) @nogc nothrow;
    int mblen(const(char)*, c_ulong) @nogc nothrow;
    int qfcvt_r(real, int, int*, int*, char*, c_ulong) @nogc nothrow;
    int qecvt_r(real, int, int*, int*, char*, c_ulong) @nogc nothrow;
    int fcvt_r(double, int, int*, int*, char*, c_ulong) @nogc nothrow;
    int ecvt_r(double, int, int*, int*, char*, c_ulong) @nogc nothrow;
    char* qgcvt(real, int, char*) @nogc nothrow;
    struct _fpx_sw_bytes
    {
        @DppOffsetSize(0,4) uint magic1;
        @DppOffsetSize(4,4) uint extended_size;
        @DppOffsetSize(8,8) c_ulong xstate_bv;
        @DppOffsetSize(16,4) uint xstate_size;
        @DppOffsetSize(20,28) uint[7] __glibc_reserved1;
    }
    struct _fpreg
    {
        @DppOffsetSize(0,8) ushort[4] significand;
        @DppOffsetSize(8,2) ushort exponent;
    }
    struct _fpxreg
    {
        @DppOffsetSize(0,8) ushort[4] significand;
        @DppOffsetSize(8,2) ushort exponent;
        @DppOffsetSize(10,6) ushort[3] __glibc_reserved1;
    }
    struct _xmmreg
    {
        @DppOffsetSize(0,16) uint[4] element;
    }
    struct _fpstate
    {
        @DppOffsetSize(0,2) ushort cwd;
        @DppOffsetSize(2,2) ushort swd;
        @DppOffsetSize(4,2) ushort ftw;
        @DppOffsetSize(6,2) ushort fop;
        @DppOffsetSize(8,8) c_ulong rip;
        @DppOffsetSize(16,8) c_ulong rdp;
        @DppOffsetSize(24,4) uint mxcsr;
        @DppOffsetSize(28,4) uint mxcr_mask;
        @DppOffsetSize(32,128) _fpxreg[8] _st;
        @DppOffsetSize(160,256) _xmmreg[16] _xmm;
        @DppOffsetSize(416,96) uint[24] __glibc_reserved1;
    }
    struct sigcontext
    {
        @DppOffsetSize(0,8) c_ulong r8;
        @DppOffsetSize(8,8) c_ulong r9;
        @DppOffsetSize(16,8) c_ulong r10;
        @DppOffsetSize(24,8) c_ulong r11;
        @DppOffsetSize(32,8) c_ulong r12;
        @DppOffsetSize(40,8) c_ulong r13;
        @DppOffsetSize(48,8) c_ulong r14;
        @DppOffsetSize(56,8) c_ulong r15;
        @DppOffsetSize(64,8) c_ulong rdi;
        @DppOffsetSize(72,8) c_ulong rsi;
        @DppOffsetSize(80,8) c_ulong rbp;
        @DppOffsetSize(88,8) c_ulong rbx;
        @DppOffsetSize(96,8) c_ulong rdx;
        @DppOffsetSize(104,8) c_ulong rax;
        @DppOffsetSize(112,8) c_ulong rcx;
        @DppOffsetSize(120,8) c_ulong rsp;
        @DppOffsetSize(128,8) c_ulong rip;
        @DppOffsetSize(136,8) c_ulong eflags;
        @DppOffsetSize(144,2) ushort cs;
        @DppOffsetSize(146,2) ushort gs;
        @DppOffsetSize(148,2) ushort fs;
        @DppOffsetSize(150,2) ushort __pad0;
        @DppOffsetSize(152,8) c_ulong err;
        @DppOffsetSize(160,8) c_ulong trapno;
        @DppOffsetSize(168,8) c_ulong oldmask;
        @DppOffsetSize(176,8) c_ulong cr2;
        static union _Anonymous_22
        {
            @DppOffsetSize(0,8) _fpstate* fpstate;
            @DppOffsetSize(0,8) c_ulong __fpstate_word;
        }
        _Anonymous_22 _anonymous_23;
        auto fpstate() @property @nogc pure nothrow { return _anonymous_23.fpstate; }
        void fpstate(_T_)(auto ref _T_ val) @property @nogc pure nothrow { _anonymous_23.fpstate = val; }
        auto __fpstate_word() @property @nogc pure nothrow { return _anonymous_23.__fpstate_word; }
        void __fpstate_word(_T_)(auto ref _T_ val) @property @nogc pure nothrow { _anonymous_23.__fpstate_word = val; }
        @DppOffsetSize(192,64) c_ulong[8] __reserved1;
    }
    struct _xsave_hdr
    {
        @DppOffsetSize(0,8) c_ulong xstate_bv;
        @DppOffsetSize(8,16) c_ulong[2] __glibc_reserved1;
        @DppOffsetSize(24,40) c_ulong[5] __glibc_reserved2;
    }
    struct _ymmh_state
    {
        @DppOffsetSize(0,256) uint[64] ymmh_space;
    }
    struct _xstate
    {
        @DppOffsetSize(0,512) _fpstate fpstate;
        @DppOffsetSize(512,64) _xsave_hdr xstate_hdr;
        @DppOffsetSize(576,256) _ymmh_state ymmh;
    }
    enum _Anonymous_24
    {
        SIGEV_SIGNAL = 0,
        SIGEV_NONE = 1,
        SIGEV_THREAD = 2,
        SIGEV_THREAD_ID = 4,
    }
    enum SIGEV_SIGNAL = _Anonymous_24.SIGEV_SIGNAL;
    enum SIGEV_NONE = _Anonymous_24.SIGEV_NONE;
    enum SIGEV_THREAD = _Anonymous_24.SIGEV_THREAD;
    enum SIGEV_THREAD_ID = _Anonymous_24.SIGEV_THREAD_ID;
    char* qfcvt(real, int, int*, int*) @nogc nothrow;
    char* qecvt(real, int, int*, int*) @nogc nothrow;
    enum _Anonymous_25
    {
        SI_ASYNCNL = -60,
        SI_DETHREAD = -7,
        SI_TKILL = -6,
        SI_SIGIO = -5,
        SI_ASYNCIO = -4,
        SI_MESGQ = -3,
        SI_TIMER = -2,
        SI_QUEUE = -1,
        SI_USER = 0,
        SI_KERNEL = 128,
    }
    enum SI_ASYNCNL = _Anonymous_25.SI_ASYNCNL;
    enum SI_DETHREAD = _Anonymous_25.SI_DETHREAD;
    enum SI_TKILL = _Anonymous_25.SI_TKILL;
    enum SI_SIGIO = _Anonymous_25.SI_SIGIO;
    enum SI_ASYNCIO = _Anonymous_25.SI_ASYNCIO;
    enum SI_MESGQ = _Anonymous_25.SI_MESGQ;
    enum SI_TIMER = _Anonymous_25.SI_TIMER;
    enum SI_QUEUE = _Anonymous_25.SI_QUEUE;
    enum SI_USER = _Anonymous_25.SI_USER;
    enum SI_KERNEL = _Anonymous_25.SI_KERNEL;
    char* gcvt(double, int, char*) @nogc nothrow;
    char* fcvt(double, int, int*, int*) @nogc nothrow;
    enum _Anonymous_26
    {
        ILL_ILLOPC = 1,
        ILL_ILLOPN = 2,
        ILL_ILLADR = 3,
        ILL_ILLTRP = 4,
        ILL_PRVOPC = 5,
        ILL_PRVREG = 6,
        ILL_COPROC = 7,
        ILL_BADSTK = 8,
        ILL_BADIADDR = 9,
    }
    enum ILL_ILLOPC = _Anonymous_26.ILL_ILLOPC;
    enum ILL_ILLOPN = _Anonymous_26.ILL_ILLOPN;
    enum ILL_ILLADR = _Anonymous_26.ILL_ILLADR;
    enum ILL_ILLTRP = _Anonymous_26.ILL_ILLTRP;
    enum ILL_PRVOPC = _Anonymous_26.ILL_PRVOPC;
    enum ILL_PRVREG = _Anonymous_26.ILL_PRVREG;
    enum ILL_COPROC = _Anonymous_26.ILL_COPROC;
    enum ILL_BADSTK = _Anonymous_26.ILL_BADSTK;
    enum ILL_BADIADDR = _Anonymous_26.ILL_BADIADDR;
    char* ecvt(double, int, int*, int*) @nogc nothrow;
    lldiv_t lldiv(long, long) @nogc nothrow;
    enum _Anonymous_27
    {
        FPE_INTDIV = 1,
        FPE_INTOVF = 2,
        FPE_FLTDIV = 3,
        FPE_FLTOVF = 4,
        FPE_FLTUND = 5,
        FPE_FLTRES = 6,
        FPE_FLTINV = 7,
        FPE_FLTSUB = 8,
        FPE_FLTUNK = 14,
        FPE_CONDTRAP = 15,
    }
    enum FPE_INTDIV = _Anonymous_27.FPE_INTDIV;
    enum FPE_INTOVF = _Anonymous_27.FPE_INTOVF;
    enum FPE_FLTDIV = _Anonymous_27.FPE_FLTDIV;
    enum FPE_FLTOVF = _Anonymous_27.FPE_FLTOVF;
    enum FPE_FLTUND = _Anonymous_27.FPE_FLTUND;
    enum FPE_FLTRES = _Anonymous_27.FPE_FLTRES;
    enum FPE_FLTINV = _Anonymous_27.FPE_FLTINV;
    enum FPE_FLTSUB = _Anonymous_27.FPE_FLTSUB;
    enum FPE_FLTUNK = _Anonymous_27.FPE_FLTUNK;
    enum FPE_CONDTRAP = _Anonymous_27.FPE_CONDTRAP;
    ldiv_t ldiv(c_long, c_long) @nogc nothrow;
    div_t div(int, int) @nogc nothrow;
    long llabs(long) @nogc nothrow;
    enum _Anonymous_28
    {
        SEGV_MAPERR = 1,
        SEGV_ACCERR = 2,
        SEGV_BNDERR = 3,
        SEGV_PKUERR = 4,
        SEGV_ACCADI = 5,
        SEGV_ADIDERR = 6,
        SEGV_ADIPERR = 7,
    }
    enum SEGV_MAPERR = _Anonymous_28.SEGV_MAPERR;
    enum SEGV_ACCERR = _Anonymous_28.SEGV_ACCERR;
    enum SEGV_BNDERR = _Anonymous_28.SEGV_BNDERR;
    enum SEGV_PKUERR = _Anonymous_28.SEGV_PKUERR;
    enum SEGV_ACCADI = _Anonymous_28.SEGV_ACCADI;
    enum SEGV_ADIDERR = _Anonymous_28.SEGV_ADIDERR;
    enum SEGV_ADIPERR = _Anonymous_28.SEGV_ADIPERR;
    c_long labs(c_long) @nogc nothrow;
    int abs(int) @nogc nothrow;
    void qsort(void*, c_ulong, c_ulong, int function(const(void)*, const(void)*)) @nogc nothrow;
    enum _Anonymous_29
    {
        BUS_ADRALN = 1,
        BUS_ADRERR = 2,
        BUS_OBJERR = 3,
        BUS_MCEERR_AR = 4,
        BUS_MCEERR_AO = 5,
    }
    enum BUS_ADRALN = _Anonymous_29.BUS_ADRALN;
    enum BUS_ADRERR = _Anonymous_29.BUS_ADRERR;
    enum BUS_OBJERR = _Anonymous_29.BUS_OBJERR;
    enum BUS_MCEERR_AR = _Anonymous_29.BUS_MCEERR_AR;
    enum BUS_MCEERR_AO = _Anonymous_29.BUS_MCEERR_AO;
    void* bsearch(const(void)*, const(void)*, c_ulong, c_ulong, int function(const(void)*, const(void)*)) @nogc nothrow;
    alias __compar_fn_t = int function(const(void)*, const(void)*);
    enum _Anonymous_30
    {
        CLD_EXITED = 1,
        CLD_KILLED = 2,
        CLD_DUMPED = 3,
        CLD_TRAPPED = 4,
        CLD_STOPPED = 5,
        CLD_CONTINUED = 6,
    }
    enum CLD_EXITED = _Anonymous_30.CLD_EXITED;
    enum CLD_KILLED = _Anonymous_30.CLD_KILLED;
    enum CLD_DUMPED = _Anonymous_30.CLD_DUMPED;
    enum CLD_TRAPPED = _Anonymous_30.CLD_TRAPPED;
    enum CLD_STOPPED = _Anonymous_30.CLD_STOPPED;
    enum CLD_CONTINUED = _Anonymous_30.CLD_CONTINUED;
    char* realpath(const(char)*, char*) @nogc nothrow;
    int system(const(char)*) @nogc nothrow;
    enum _Anonymous_31
    {
        POLL_IN = 1,
        POLL_OUT = 2,
        POLL_MSG = 3,
        POLL_ERR = 4,
        POLL_PRI = 5,
        POLL_HUP = 6,
    }
    enum POLL_IN = _Anonymous_31.POLL_IN;
    enum POLL_OUT = _Anonymous_31.POLL_OUT;
    enum POLL_MSG = _Anonymous_31.POLL_MSG;
    enum POLL_ERR = _Anonymous_31.POLL_ERR;
    enum POLL_PRI = _Anonymous_31.POLL_PRI;
    enum POLL_HUP = _Anonymous_31.POLL_HUP;
    char* mkdtemp(char*) @nogc nothrow;
    int mkstemps(char*, int) @nogc nothrow;
    int mkstemp(char*) @nogc nothrow;
    char* mktemp(char*) @nogc nothrow;
    int clearenv() @nogc nothrow;
    int unsetenv(const(char)*) @nogc nothrow;
    int setenv(const(char)*, const(char)*, int) @nogc nothrow;
    int putenv(char*) @nogc nothrow;
    char* getenv(const(char)*) @nogc nothrow;
    void _Exit(int) @nogc nothrow;
    void quick_exit(int) @nogc nothrow;
    void exit(int) @nogc nothrow;
    int on_exit(void function(int, void*), void*) @nogc nothrow;
    int at_quick_exit(void function()) @nogc nothrow;
    int atexit(void function()) @nogc nothrow;
    void abort() @nogc nothrow;
    void* aligned_alloc(c_ulong, c_ulong) @nogc nothrow;
    int pthread_sigmask(int, const(__sigset_t)*, __sigset_t*) @nogc nothrow;
    int pthread_kill(c_ulong, int) @nogc nothrow;
    enum _Anonymous_32
    {
        SS_ONSTACK = 1,
        SS_DISABLE = 2,
    }
    enum SS_ONSTACK = _Anonymous_32.SS_ONSTACK;
    enum SS_DISABLE = _Anonymous_32.SS_DISABLE;
    int posix_memalign(void**, c_ulong, c_ulong) @nogc nothrow;
    alias int8_t = byte;
    void* valloc(c_ulong) @nogc nothrow;
    extern __gshared int sys_nerr;
    extern __gshared const(const(char)*)[0] sys_errlist;
    alias __pthread_list_t = __pthread_internal_list;
    struct __pthread_internal_list
    {
        @DppOffsetSize(0,8) __pthread_internal_list* __prev;
        @DppOffsetSize(8,8) __pthread_internal_list* __next;
    }
    void free(void*) @nogc nothrow;
    struct __pthread_mutex_s
    {
        @DppOffsetSize(0,4) int __lock;
        @DppOffsetSize(4,4) uint __count;
        @DppOffsetSize(8,4) int __owner;
        @DppOffsetSize(12,4) uint __nusers;
        @DppOffsetSize(16,4) int __kind;
        @DppOffsetSize(20,2) short __spins;
        @DppOffsetSize(22,2) short __elision;
        @DppOffsetSize(24,16) __pthread_internal_list __list;
    }
    struct __pthread_cond_s
    {
        static union _Anonymous_33
        {
            @DppOffsetSize(0,8) ulong __wseq;
            static struct _Anonymous_34
            {
                @DppOffsetSize(0,4) uint __low;
                @DppOffsetSize(4,4) uint __high;
            }
            @DppOffsetSize(0,8) _Anonymous_34 __wseq32;
        }
        _Anonymous_33 _anonymous_35;
        auto __wseq() @property @nogc pure nothrow { return _anonymous_35.__wseq; }
        void __wseq(_T_)(auto ref _T_ val) @property @nogc pure nothrow { _anonymous_35.__wseq = val; }
        auto __wseq32() @property @nogc pure nothrow { return _anonymous_35.__wseq32; }
        void __wseq32(_T_)(auto ref _T_ val) @property @nogc pure nothrow { _anonymous_35.__wseq32 = val; }
        static union _Anonymous_36
        {
            @DppOffsetSize(0,8) ulong __g1_start;
            static struct _Anonymous_37
            {
                @DppOffsetSize(0,4) uint __low;
                @DppOffsetSize(4,4) uint __high;
            }
            @DppOffsetSize(0,8) _Anonymous_37 __g1_start32;
        }
        _Anonymous_36 _anonymous_38;
        auto __g1_start() @property @nogc pure nothrow { return _anonymous_38.__g1_start; }
        void __g1_start(_T_)(auto ref _T_ val) @property @nogc pure nothrow { _anonymous_38.__g1_start = val; }
        auto __g1_start32() @property @nogc pure nothrow { return _anonymous_38.__g1_start32; }
        void __g1_start32(_T_)(auto ref _T_ val) @property @nogc pure nothrow { _anonymous_38.__g1_start32 = val; }
        @DppOffsetSize(16,8) uint[2] __g_refs;
        @DppOffsetSize(24,8) uint[2] __g_size;
        @DppOffsetSize(32,4) uint __g1_orig_size;
        @DppOffsetSize(36,4) uint __wrefs;
        @DppOffsetSize(40,8) uint[2] __g_signals;
    }
    void* reallocarray(void*, c_ulong, c_ulong) @nogc nothrow;
    alias __u_char = ubyte;
    alias __u_short = ushort;
    alias __u_int = uint;
    alias __u_long = c_ulong;
    alias __int8_t = byte;
    alias __uint8_t = ubyte;
    alias __int16_t = short;
    alias __uint16_t = ushort;
    alias __int32_t = int;
    alias __uint32_t = uint;
    alias __int64_t = c_long;
    alias __uint64_t = c_ulong;
    alias __int_least8_t = byte;
    alias __uint_least8_t = ubyte;
    alias __int_least16_t = short;
    alias __uint_least16_t = ushort;
    alias __int_least32_t = int;
    alias __uint_least32_t = uint;
    alias __int_least64_t = c_long;
    alias __uint_least64_t = c_ulong;
    alias __quad_t = c_long;
    alias __u_quad_t = c_ulong;
    alias __intmax_t = c_long;
    alias __uintmax_t = c_ulong;
    void* realloc(void*, c_ulong) @nogc nothrow;
    void* calloc(c_ulong, c_ulong) @nogc nothrow;
    void* malloc(c_ulong) @nogc nothrow;
    int lcong48_r(ushort*, drand48_data*) @nogc nothrow;
    alias __dev_t = c_ulong;
    alias __uid_t = uint;
    alias __gid_t = uint;
    alias __ino_t = c_ulong;
    alias __ino64_t = c_ulong;
    alias __mode_t = uint;
    alias __nlink_t = c_ulong;
    alias __off_t = c_long;
    alias __off64_t = c_long;
    alias __pid_t = int;
    struct __fsid_t
    {
        @DppOffsetSize(0,8) int[2] __val;
    }
    alias __clock_t = c_long;
    alias __rlim_t = c_ulong;
    alias __rlim64_t = c_ulong;
    alias __id_t = uint;
    alias __time_t = c_long;
    alias __useconds_t = uint;
    alias __suseconds_t = c_long;
    alias __daddr_t = int;
    alias __key_t = int;
    alias __clockid_t = int;
    alias __timer_t = void*;
    alias __blksize_t = c_long;
    alias __blkcnt_t = c_long;
    alias __blkcnt64_t = c_long;
    alias __fsblkcnt_t = c_ulong;
    alias __fsblkcnt64_t = c_ulong;
    alias __fsfilcnt_t = c_ulong;
    alias __fsfilcnt64_t = c_ulong;
    alias __fsword_t = c_long;
    alias __ssize_t = c_long;
    alias __syscall_slong_t = c_long;
    alias __syscall_ulong_t = c_ulong;
    alias __loff_t = c_long;
    alias __caddr_t = char*;
    alias __intptr_t = c_long;
    alias __socklen_t = uint;
    alias __sig_atomic_t = int;
    int seed48_r(ushort*, drand48_data*) @nogc nothrow;
    alias FILE = _IO_FILE;
    struct _IO_FILE
    {
        @DppOffsetSize(0,4) int _flags;
        @DppOffsetSize(8,8) char* _IO_read_ptr;
        @DppOffsetSize(16,8) char* _IO_read_end;
        @DppOffsetSize(24,8) char* _IO_read_base;
        @DppOffsetSize(32,8) char* _IO_write_base;
        @DppOffsetSize(40,8) char* _IO_write_ptr;
        @DppOffsetSize(48,8) char* _IO_write_end;
        @DppOffsetSize(56,8) char* _IO_buf_base;
        @DppOffsetSize(64,8) char* _IO_buf_end;
        @DppOffsetSize(72,8) char* _IO_save_base;
        @DppOffsetSize(80,8) char* _IO_backup_base;
        @DppOffsetSize(88,8) char* _IO_save_end;
        @DppOffsetSize(96,8) _IO_marker* _markers;
        @DppOffsetSize(104,8) _IO_FILE* _chain;
        @DppOffsetSize(112,4) int _fileno;
        @DppOffsetSize(116,4) int _flags2;
        @DppOffsetSize(120,8) c_long _old_offset;
        @DppOffsetSize(128,2) ushort _cur_column;
        @DppOffsetSize(130,1) byte _vtable_offset;
        @DppOffsetSize(131,1) char[1] _shortbuf;
        @DppOffsetSize(136,8) void* _lock;
        @DppOffsetSize(144,8) c_long _offset;
        @DppOffsetSize(152,8) _IO_codecvt* _codecvt;
        @DppOffsetSize(160,8) _IO_wide_data* _wide_data;
        @DppOffsetSize(168,8) _IO_FILE* _freeres_list;
        @DppOffsetSize(176,8) void* _freeres_buf;
        @DppOffsetSize(184,8) c_ulong __pad5;
        @DppOffsetSize(192,4) int _mode;
        @DppOffsetSize(196,20) char[20] _unused2;
    }
    alias __FILE = _IO_FILE;
    int srand48_r(c_long, drand48_data*) @nogc nothrow;
    alias __fpos64_t = _G_fpos64_t;
    struct _G_fpos64_t
    {
        @DppOffsetSize(0,8) c_long __pos;
        @DppOffsetSize(8,8) __mbstate_t __state;
    }
    alias __fpos_t = _G_fpos_t;
    struct _G_fpos_t
    {
        @DppOffsetSize(0,8) c_long __pos;
        @DppOffsetSize(8,8) __mbstate_t __state;
    }
    struct __mbstate_t
    {
        @DppOffsetSize(0,4) int __count;
        static union _Anonymous_39
        {
            @DppOffsetSize(0,4) uint __wch;
            @DppOffsetSize(0,4) char[4] __wchb;
        }
        @DppOffsetSize(4,4) _Anonymous_39 __value;
    }
    int jrand48_r(ushort*, drand48_data*, c_long*) @nogc nothrow;
    struct __sigset_t
    {
        @DppOffsetSize(0,128) c_ulong[16] __val;
    }
    union sigval
    {
        @DppOffsetSize(0,4) int sival_int;
        @DppOffsetSize(0,8) void* sival_ptr;
    }
    alias __sigval_t = sigval;
    int mrand48_r(drand48_data*, c_long*) @nogc nothrow;
    alias clock_t = c_long;
    alias clockid_t = int;
    alias sig_atomic_t = int;
    int nrand48_r(ushort*, drand48_data*, c_long*) @nogc nothrow;
    alias sigevent_t = sigevent;
    struct sigevent
    {
        @DppOffsetSize(0,8) sigval sigev_value;
        @DppOffsetSize(8,4) int sigev_signo;
        @DppOffsetSize(12,4) int sigev_notify;
        static union _Anonymous_40
        {
            @DppOffsetSize(0,48) int[12] _pad;
            @DppOffsetSize(0,4) int _tid;
            static struct _Anonymous_41
            {
                @DppOffsetSize(0,8) void function(sigval) _function;
                @DppOffsetSize(8,8) pthread_attr_t* _attribute;
            }
            @DppOffsetSize(0,16) _Anonymous_41 _sigev_thread;
        }
        @DppOffsetSize(16,48) _Anonymous_40 _sigev_un;
    }
    int lrand48_r(drand48_data*, c_long*) @nogc nothrow;
    int erand48_r(ushort*, drand48_data*, double*) @nogc nothrow;
    int drand48_r(drand48_data*, double*) @nogc nothrow;
    struct drand48_data
    {
        @DppOffsetSize(0,6) ushort[3] __x;
        @DppOffsetSize(6,6) ushort[3] __old_x;
        @DppOffsetSize(12,2) ushort __c;
        @DppOffsetSize(14,2) ushort __init;
        @DppOffsetSize(16,8) ulong __a;
    }
    struct siginfo_t
    {
        @DppOffsetSize(0,4) int si_signo;
        @DppOffsetSize(4,4) int si_errno;
        @DppOffsetSize(8,4) int si_code;
        @DppOffsetSize(12,4) int __pad0;
        static union _Anonymous_42
        {
            @DppOffsetSize(0,112) int[28] _pad;
            static struct _Anonymous_43
            {
                @DppOffsetSize(0,4) int si_pid;
                @DppOffsetSize(4,4) uint si_uid;
            }
            @DppOffsetSize(0,8) _Anonymous_43 _kill;
            static struct _Anonymous_44
            {
                @DppOffsetSize(0,4) int si_tid;
                @DppOffsetSize(4,4) int si_overrun;
                @DppOffsetSize(8,8) sigval si_sigval;
            }
            @DppOffsetSize(0,16) _Anonymous_44 _timer;
            static struct _Anonymous_45
            {
                @DppOffsetSize(0,4) int si_pid;
                @DppOffsetSize(4,4) uint si_uid;
                @DppOffsetSize(8,8) sigval si_sigval;
            }
            @DppOffsetSize(0,16) _Anonymous_45 _rt;
            static struct _Anonymous_46
            {
                @DppOffsetSize(0,4) int si_pid;
                @DppOffsetSize(4,4) uint si_uid;
                @DppOffsetSize(8,4) int si_status;
                @DppOffsetSize(16,8) c_long si_utime;
                @DppOffsetSize(24,8) c_long si_stime;
            }
            @DppOffsetSize(0,32) _Anonymous_46 _sigchld;
            static struct _Anonymous_47
            {
                @DppOffsetSize(0,8) void* si_addr;
                @DppOffsetSize(8,2) short si_addr_lsb;
                static union _Anonymous_48
                {
                    static struct _Anonymous_49
                    {
                        @DppOffsetSize(0,8) void* _lower;
                        @DppOffsetSize(8,8) void* _upper;
                    }
                    @DppOffsetSize(0,16) _Anonymous_49 _addr_bnd;
                    @DppOffsetSize(0,4) uint _pkey;
                }
                @DppOffsetSize(16,16) _Anonymous_48 _bounds;
            }
            @DppOffsetSize(0,32) _Anonymous_47 _sigfault;
            static struct _Anonymous_50
            {
                @DppOffsetSize(0,8) c_long si_band;
                @DppOffsetSize(8,4) int si_fd;
            }
            @DppOffsetSize(0,16) _Anonymous_50 _sigpoll;
            static struct _Anonymous_51
            {
                @DppOffsetSize(0,8) void* _call_addr;
                @DppOffsetSize(8,4) int _syscall;
                @DppOffsetSize(12,4) uint _arch;
            }
            @DppOffsetSize(0,16) _Anonymous_51 _sigsys;
        }
        @DppOffsetSize(16,112) _Anonymous_42 _sifields;
    }
    void lcong48(ushort*) @nogc nothrow;
    ushort* seed48(ushort*) @nogc nothrow;
    void srand48(c_long) @nogc nothrow;
    c_long jrand48(ushort*) @nogc nothrow;
    c_long mrand48() @nogc nothrow;
    c_long nrand48(ushort*) @nogc nothrow;
    c_long lrand48() @nogc nothrow;
    double erand48(ushort*) @nogc nothrow;
    double drand48() @nogc nothrow;
    alias sigset_t = __sigset_t;
    alias sigval_t = sigval;
    int rand_r(uint*) @nogc nothrow;
    struct stack_t
    {
        @DppOffsetSize(0,8) void* ss_sp;
        @DppOffsetSize(8,4) int ss_flags;
        @DppOffsetSize(16,8) c_ulong ss_size;
    }
    struct _IO_marker;
    struct _IO_codecvt;
    struct _IO_wide_data;
    alias _IO_lock_t = void;
    void srand(uint) @nogc nothrow;
    int rand() @nogc nothrow;
    int setstate_r(char*, random_data*) @nogc nothrow;
    struct sigstack
    {
        @DppOffsetSize(0,8) void* ss_sp;
        @DppOffsetSize(8,4) int ss_onstack;
    }
    struct timespec
    {
        @DppOffsetSize(0,8) c_long tv_sec;
        @DppOffsetSize(8,8) c_long tv_nsec;
    }
    int initstate_r(uint, char*, c_ulong, random_data*) @nogc nothrow;
    struct timeval
    {
        @DppOffsetSize(0,8) c_long tv_sec;
        @DppOffsetSize(8,8) c_long tv_usec;
    }
    alias time_t = c_long;
    alias timer_t = void*;
    int srandom_r(uint, random_data*) @nogc nothrow;
    int random_r(random_data*, int*) @nogc nothrow;
    struct random_data
    {
        @DppOffsetSize(0,8) int* fptr;
        @DppOffsetSize(8,8) int* rptr;
        @DppOffsetSize(16,8) int* state;
        @DppOffsetSize(24,4) int rand_type;
        @DppOffsetSize(28,4) int rand_deg;
        @DppOffsetSize(32,4) int rand_sep;
        @DppOffsetSize(40,8) int* end_ptr;
    }
    char* setstate(char*) @nogc nothrow;
    char* initstate(uint, char*, c_ulong) @nogc nothrow;
    void srandom(uint) @nogc nothrow;
    c_long random() @nogc nothrow;
    c_long a64l(const(char)*) @nogc nothrow;
    char* l64a(c_long) @nogc nothrow;
    ulong strtoull(const(char)*, char**, int) @nogc nothrow;
    long strtoll(const(char)*, char**, int) @nogc nothrow;
    ulong strtouq(const(char)*, char**, int) @nogc nothrow;
    long strtoq(const(char)*, char**, int) @nogc nothrow;
    c_ulong strtoul(const(char)*, char**, int) @nogc nothrow;
    c_long strtol(const(char)*, char**, int) @nogc nothrow;
    real strtold(const(char)*, char**) @nogc nothrow;
    float strtof(const(char)*, char**) @nogc nothrow;
    double strtod(const(char)*, char**) @nogc nothrow;
    long atoll(const(char)*) @nogc nothrow;
    c_long atol(const(char)*) @nogc nothrow;
    int atoi(const(char)*) @nogc nothrow;
    int* __errno_location() @nogc nothrow;
    double atof(const(char)*) @nogc nothrow;
    c_ulong __ctype_get_mb_cur_max() @nogc nothrow;
    struct lldiv_t
    {
        @DppOffsetSize(0,8) long quot;
        @DppOffsetSize(8,8) long rem;
    }
    struct ldiv_t
    {
        @DppOffsetSize(0,8) c_long quot;
        @DppOffsetSize(8,8) c_long rem;
    }
    struct div_t
    {
        @DppOffsetSize(0,4) int quot;
        @DppOffsetSize(4,4) int rem;
    }
    int __overflow(_IO_FILE*, int) @nogc nothrow;
    int __uflow(_IO_FILE*) @nogc nothrow;
    void funlockfile(_IO_FILE*) @nogc nothrow;
    int ftrylockfile(_IO_FILE*) @nogc nothrow;
    void flockfile(_IO_FILE*) @nogc nothrow;
    char* ctermid(char*) @nogc nothrow;
    int pclose(_IO_FILE*) @nogc nothrow;
    _IO_FILE* popen(const(char)*, const(char)*) @nogc nothrow;
    int fileno_unlocked(_IO_FILE*) @nogc nothrow;
    int fileno(_IO_FILE*) @nogc nothrow;
    void perror(const(char)*) @nogc nothrow;
    int ferror_unlocked(_IO_FILE*) @nogc nothrow;
    int feof_unlocked(_IO_FILE*) @nogc nothrow;
    void clearerr_unlocked(_IO_FILE*) @nogc nothrow;
    int ferror(_IO_FILE*) @nogc nothrow;
    int feof(_IO_FILE*) @nogc nothrow;
    alias __re_size_t = uint;
    alias __re_long_size_t = c_ulong;
    alias s_reg_t = c_long;
    alias active_reg_t = c_ulong;
    alias reg_syntax_t = c_ulong;
    extern __gshared c_ulong re_syntax_options;
    void clearerr(_IO_FILE*) @nogc nothrow;
    int fsetpos(_IO_FILE*, const(_G_fpos_t)*) @nogc nothrow;
    int fgetpos(_IO_FILE*, _G_fpos_t*) @nogc nothrow;
    c_long ftello(_IO_FILE*) @nogc nothrow;
    int fseeko(_IO_FILE*, c_long, int) @nogc nothrow;
    alias reg_errcode_t = _Anonymous_52;
    enum _Anonymous_52
    {
        _REG_ENOSYS = -1,
        _REG_NOERROR = 0,
        _REG_NOMATCH = 1,
        _REG_BADPAT = 2,
        _REG_ECOLLATE = 3,
        _REG_ECTYPE = 4,
        _REG_EESCAPE = 5,
        _REG_ESUBREG = 6,
        _REG_EBRACK = 7,
        _REG_EPAREN = 8,
        _REG_EBRACE = 9,
        _REG_BADBR = 10,
        _REG_ERANGE = 11,
        _REG_ESPACE = 12,
        _REG_BADRPT = 13,
        _REG_EEND = 14,
        _REG_ESIZE = 15,
        _REG_ERPAREN = 16,
    }
    enum _REG_ENOSYS = _Anonymous_52._REG_ENOSYS;
    enum _REG_NOERROR = _Anonymous_52._REG_NOERROR;
    enum _REG_NOMATCH = _Anonymous_52._REG_NOMATCH;
    enum _REG_BADPAT = _Anonymous_52._REG_BADPAT;
    enum _REG_ECOLLATE = _Anonymous_52._REG_ECOLLATE;
    enum _REG_ECTYPE = _Anonymous_52._REG_ECTYPE;
    enum _REG_EESCAPE = _Anonymous_52._REG_EESCAPE;
    enum _REG_ESUBREG = _Anonymous_52._REG_ESUBREG;
    enum _REG_EBRACK = _Anonymous_52._REG_EBRACK;
    enum _REG_EPAREN = _Anonymous_52._REG_EPAREN;
    enum _REG_EBRACE = _Anonymous_52._REG_EBRACE;
    enum _REG_BADBR = _Anonymous_52._REG_BADBR;
    enum _REG_ERANGE = _Anonymous_52._REG_ERANGE;
    enum _REG_ESPACE = _Anonymous_52._REG_ESPACE;
    enum _REG_BADRPT = _Anonymous_52._REG_BADRPT;
    enum _REG_EEND = _Anonymous_52._REG_EEND;
    enum _REG_ESIZE = _Anonymous_52._REG_ESIZE;
    enum _REG_ERPAREN = _Anonymous_52._REG_ERPAREN;
    void rewind(_IO_FILE*) @nogc nothrow;
    c_long ftell(_IO_FILE*) @nogc nothrow;
    int fseek(_IO_FILE*, c_long, int) @nogc nothrow;
    c_ulong fwrite_unlocked(const(void)*, c_ulong, c_ulong, _IO_FILE*) @nogc nothrow;
    c_ulong fread_unlocked(void*, c_ulong, c_ulong, _IO_FILE*) @nogc nothrow;
    c_ulong fwrite(const(void)*, c_ulong, c_ulong, _IO_FILE*) @nogc nothrow;
    c_ulong fread(void*, c_ulong, c_ulong, _IO_FILE*) @nogc nothrow;
    int ungetc(int, _IO_FILE*) @nogc nothrow;
    int puts(const(char)*) @nogc nothrow;
    int fputs(const(char)*, _IO_FILE*) @nogc nothrow;
    c_long getline(char**, c_ulong*, _IO_FILE*) @nogc nothrow;
    c_long getdelim(char**, c_ulong*, int, _IO_FILE*) @nogc nothrow;
    struct re_pattern_buffer
    {
        import std.bitmanip: bitfields;

        align(4):
        @DppOffsetSize(0,8) re_dfa_t* __buffer;
        @DppOffsetSize(8,8) c_ulong __allocated;
        @DppOffsetSize(16,8) c_ulong __used;
        @DppOffsetSize(24,8) c_ulong __syntax;
        @DppOffsetSize(32,8) char* __fastmap;
        @DppOffsetSize(40,8) ubyte* __translate;
        @DppOffsetSize(48,8) c_ulong re_nsub;
        mixin(bitfields!(
            uint, "__can_be_null", 1,
            uint, "__regs_allocated", 2,
            uint, "__fastmap_accurate", 1,
            uint, "__no_sub", 1,
            uint, "__not_bol", 1,
            uint, "__not_eol", 1,
            uint, "__newline_anchor", 1,
        ));
    }
    alias regex_t = re_pattern_buffer;
    alias regoff_t = int;
    struct regmatch_t
    {
        @DppOffsetSize(0,4) int rm_so;
        @DppOffsetSize(4,4) int rm_eo;
    }
    c_long __getdelim(char**, c_ulong*, int, _IO_FILE*) @nogc nothrow;
    int regcomp(re_pattern_buffer*, const(char)*, int) @nogc nothrow;
    int regexec(const(re_pattern_buffer)*, const(char)*, c_ulong, regmatch_t*, int) @nogc nothrow;
    c_ulong regerror(int, const(re_pattern_buffer)*, char*, c_ulong) @nogc nothrow;
    void regfree(re_pattern_buffer*) @nogc nothrow;
    alias __sighandler_t = void function(int);
    void function(int) __sysv_signal(int, void function(int)) @nogc nothrow;
    void function(int) signal(int, void function(int)) @nogc nothrow;
    int kill(int, int) @nogc nothrow;
    int killpg(int, int) @nogc nothrow;
    int raise(int) @nogc nothrow;
    void function(int) ssignal(int, void function(int)) @nogc nothrow;
    int gsignal(int) @nogc nothrow;
    void psignal(int, const(char)*) @nogc nothrow;
    void psiginfo(const(siginfo_t)*, const(char)*) @nogc nothrow;
    int sigblock(int) @nogc nothrow;
    int sigsetmask(int) @nogc nothrow;
    int siggetmask() @nogc nothrow;
    alias sig_t = void function();
    int sigemptyset(__sigset_t*) @nogc nothrow;
    int sigfillset(__sigset_t*) @nogc nothrow;
    int sigaddset(__sigset_t*, int) @nogc nothrow;
    int sigdelset(__sigset_t*, int) @nogc nothrow;
    int sigismember(const(__sigset_t)*, int) @nogc nothrow;
    int sigprocmask(int, const(__sigset_t)*, __sigset_t*) @nogc nothrow;
    int sigsuspend(const(__sigset_t)*) @nogc nothrow;
    pragma(mangle, "sigaction") int sigaction_(int, const(sigaction)*, sigaction*) @nogc nothrow;
    int sigpending(__sigset_t*) @nogc nothrow;
    int sigwait(const(__sigset_t)*, int*) @nogc nothrow;
    int sigwaitinfo(const(__sigset_t)*, siginfo_t*) @nogc nothrow;
    int sigtimedwait(const(__sigset_t)*, siginfo_t*, const(timespec)*) @nogc nothrow;
    int sigqueue(int, int, const(sigval)) @nogc nothrow;
    extern __gshared const(const(char)*)[65] _sys_siglist;
    extern __gshared const(const(char)*)[65] sys_siglist;
    int sigreturn(sigcontext*) @nogc nothrow;
    char* fgets(char*, int, _IO_FILE*) @nogc nothrow;
    int siginterrupt(int, int) @nogc nothrow;
    int sigaltstack(const(stack_t)*, stack_t*) @nogc nothrow;
    pragma(mangle, "sigstack") int sigstack_(sigstack*, sigstack*) @nogc nothrow;
    int __libc_current_sigrtmin() @nogc nothrow;
    int __libc_current_sigrtmax() @nogc nothrow;
    int putw(int, _IO_FILE*) @nogc nothrow;
    int getw(_IO_FILE*) @nogc nothrow;
    int putchar_unlocked(int) @nogc nothrow;
    int putc_unlocked(int, _IO_FILE*) @nogc nothrow;
    int fputc_unlocked(int, _IO_FILE*) @nogc nothrow;
    int putchar(int) @nogc nothrow;
    int putc(int, _IO_FILE*) @nogc nothrow;
    int fputc(int, _IO_FILE*) @nogc nothrow;
    alias fpos_t = _G_fpos_t;
    int fgetc_unlocked(_IO_FILE*) @nogc nothrow;
    int getchar_unlocked() @nogc nothrow;
    int getc_unlocked(_IO_FILE*) @nogc nothrow;
    int getchar() @nogc nothrow;
    int getc(_IO_FILE*) @nogc nothrow;
    int fgetc(_IO_FILE*) @nogc nothrow;
    extern __gshared _IO_FILE* stdin;
    extern __gshared _IO_FILE* stdout;
    extern __gshared _IO_FILE* stderr;
    int remove(const(char)*) @nogc nothrow;
    int rename(const(char)*, const(char)*) @nogc nothrow;
    int renameat(int, const(char)*, int, const(char)*) @nogc nothrow;
    _IO_FILE* tmpfile() @nogc nothrow;
    char* tmpnam(char*) @nogc nothrow;
    char* tmpnam_r(char*) @nogc nothrow;
    char* tempnam(const(char)*, const(char)*) @nogc nothrow;
    int fclose(_IO_FILE*) @nogc nothrow;
    int fflush(_IO_FILE*) @nogc nothrow;
    int fflush_unlocked(_IO_FILE*) @nogc nothrow;
    _IO_FILE* fopen(const(char)*, const(char)*) @nogc nothrow;
    _IO_FILE* freopen(const(char)*, const(char)*, _IO_FILE*) @nogc nothrow;
    _IO_FILE* fdopen(int, const(char)*) @nogc nothrow;
    _IO_FILE* fmemopen(void*, c_ulong, const(char)*) @nogc nothrow;
    _IO_FILE* open_memstream(char**, c_ulong*) @nogc nothrow;
    void setbuf(_IO_FILE*, char*) @nogc nothrow;
    int setvbuf(_IO_FILE*, char*, int, c_ulong) @nogc nothrow;
    void setbuffer(_IO_FILE*, char*, c_ulong) @nogc nothrow;
    void setlinebuf(_IO_FILE*) @nogc nothrow;
    int fprintf(_IO_FILE*, const(char)*, ...) @nogc nothrow;
    int printf(const(char)*, ...) @nogc nothrow;
    int sprintf(char*, const(char)*, ...) @nogc nothrow;
    int vfprintf(_IO_FILE*, const(char)*, va_list*) @nogc nothrow;
    int vprintf(const(char)*, va_list*) @nogc nothrow;
    int vsprintf(char*, const(char)*, va_list*) @nogc nothrow;
    int snprintf(char*, c_ulong, const(char)*, ...) @nogc nothrow;
    int vsnprintf(char*, c_ulong, const(char)*, va_list*) @nogc nothrow;
    int vdprintf(int, const(char)*, va_list*) @nogc nothrow;
    int dprintf(int, const(char)*, ...) @nogc nothrow;
    int fscanf(_IO_FILE*, const(char)*, ...) @nogc nothrow;
    int scanf(const(char)*, ...) @nogc nothrow;
    int sscanf(const(char)*, const(char)*, ...) @nogc nothrow;
    int vfscanf(_IO_FILE*, const(char)*, va_list*) @nogc nothrow;
    int vscanf(const(char)*, va_list*) @nogc nothrow;
    int vsscanf(const(char)*, const(char)*, va_list*) @nogc nothrow;
    enum DPP_ENUM_SEEK_END = 2;


    enum DPP_ENUM_SEEK_CUR = 1;


    enum DPP_ENUM_SEEK_SET = 0;




    enum DPP_ENUM_BUFSIZ = 8192;


    enum DPP_ENUM__IONBF = 2;


    enum DPP_ENUM__IOLBF = 1;


    enum DPP_ENUM__IOFBF = 0;
    enum DPP_ENUM__STDIO_H = 1;


    enum DPP_ENUM__STDC_PREDEF_H = 1;
    enum DPP_ENUM_REG_NOTBOL = 1;
    enum DPP_ENUM_REG_EXTENDED = 1;


    enum DPP_ENUM__REGEX_H = 1;




    enum DPP_ENUM_RTSIG_MAX = 32;


    enum DPP_ENUM_XATTR_LIST_MAX = 65536;


    enum DPP_ENUM_XATTR_SIZE_MAX = 65536;


    enum DPP_ENUM_XATTR_NAME_MAX = 255;


    enum DPP_ENUM_PIPE_BUF = 4096;


    enum DPP_ENUM_PATH_MAX = 4096;


    enum DPP_ENUM_NAME_MAX = 255;


    enum DPP_ENUM_MAX_INPUT = 255;


    enum DPP_ENUM_MAX_CANON = 255;


    enum DPP_ENUM_LINK_MAX = 127;


    enum DPP_ENUM_ARG_MAX = 131072;


    enum DPP_ENUM_NGROUPS_MAX = 65536;


    enum DPP_ENUM_NR_OPEN = 1024;
    enum DPP_ENUM_MB_LEN_MAX = 16;


    enum DPP_ENUM__LIBC_LIMITS_H_ = 1;
    enum DPP_ENUM___GLIBC_MINOR__ = 29;


    enum DPP_ENUM___GLIBC__ = 2;


    enum DPP_ENUM___GNU_LIBRARY__ = 6;


    enum DPP_ENUM___GLIBC_USE_DEPRECATED_SCANF = 0;


    enum DPP_ENUM___GLIBC_USE_DEPRECATED_GETS = 0;


    enum DPP_ENUM___USE_FORTIFY_LEVEL = 0;


    enum DPP_ENUM___USE_ATFILE = 1;


    enum DPP_ENUM___USE_MISC = 1;


    enum DPP_ENUM__ATFILE_SOURCE = 1;


    enum DPP_ENUM___USE_XOPEN2K8 = 1;


    enum DPP_ENUM___USE_ISOC99 = 1;




    enum DPP_ENUM___USE_ISOC95 = 1;


    enum DPP_ENUM___USE_XOPEN2K = 1;


    enum DPP_ENUM__STDLIB_H = 1;


    enum DPP_ENUM___USE_POSIX199506 = 1;


    enum DPP_ENUM___USE_POSIX199309 = 1;


    enum DPP_ENUM___USE_POSIX2 = 1;
    enum DPP_ENUM___USE_POSIX = 1;






    enum DPP_ENUM__POSIX_SOURCE = 1;


    enum DPP_ENUM___USE_POSIX_IMPLICITLY = 1;


    enum DPP_ENUM___ldiv_t_defined = 1;


    enum DPP_ENUM___USE_ISOC11 = 1;


    enum DPP_ENUM__DEFAULT_SOURCE = 1;




    enum DPP_ENUM___lldiv_t_defined = 1;


    enum DPP_ENUM_RAND_MAX = 2147483647;


    enum DPP_ENUM_EXIT_FAILURE = 1;


    enum DPP_ENUM_EXIT_SUCCESS = 0;
    enum DPP_ENUM__FEATURES_H = 1;




    enum DPP_ENUM__ERRNO_H = 1;
    enum DPP_ENUM___PDP_ENDIAN = 3412;


    enum DPP_ENUM___BIG_ENDIAN = 4321;


    enum DPP_ENUM___LITTLE_ENDIAN = 1234;


    enum DPP_ENUM__ENDIAN_H = 1;


    enum DPP_ENUM___SYSCALL_WORDSIZE = 64;


    enum DPP_ENUM___WORDSIZE_TIME64_COMPAT32 = 1;


    enum DPP_ENUM___WORDSIZE = 64;
    enum DPP_ENUM_WCONTINUED = 8;


    enum DPP_ENUM_WEXITED = 4;


    enum DPP_ENUM_WSTOPPED = 2;


    enum DPP_ENUM_WUNTRACED = 2;


    enum DPP_ENUM_WNOHANG = 1;


    enum DPP_ENUM__BITS_UINTN_IDENTITY_H = 1;


    enum DPP_ENUM___FD_SETSIZE = 1024;


    enum DPP_ENUM___RLIM_T_MATCHES_RLIM64_T = 1;


    enum DPP_ENUM___INO_T_MATCHES_INO64_T = 1;


    enum DPP_ENUM___OFF_T_MATCHES_OFF64_T = 1;
    enum DPP_ENUM__BITS_TYPESIZES_H = 1;


    enum DPP_ENUM___timer_t_defined = 1;


    enum DPP_ENUM___time_t_defined = 1;


    enum DPP_ENUM___timeval_defined = 1;


    enum DPP_ENUM__STRUCT_TIMESPEC = 1;


    enum DPP_ENUM___sigstack_defined = 1;
    enum DPP_ENUM___struct_FILE_defined = 1;


    enum DPP_ENUM___stack_t_defined = 1;




    enum DPP_ENUM___sigset_t_defined = 1;
    enum DPP_ENUM___SI_HAVE_SIGSYS = 1;


    enum DPP_ENUM___SI_ERRNO_THEN_CODE = 1;
    enum DPP_ENUM___SI_MAX_SIZE = 128;


    enum DPP_ENUM___siginfo_t_defined = 1;
    enum DPP_ENUM___SIGEV_MAX_SIZE = 64;


    enum DPP_ENUM___sigevent_t_defined = 1;


    enum DPP_ENUM___sig_atomic_t_defined = 1;


    enum DPP_ENUM___clockid_t_defined = 1;


    enum DPP_ENUM___clock_t_defined = 1;
    enum DPP_ENUM_____mbstate_t_defined = 1;


    enum DPP_ENUM______fpos_t_defined = 1;


    enum DPP_ENUM______fpos64_t_defined = 1;


    enum DPP_ENUM_____FILE_defined = 1;


    enum DPP_ENUM___FILE_defined = 1;
    enum DPP_ENUM__BITS_TYPES_H = 1;






    enum DPP_ENUM__BITS_TIME64_H = 1;


    enum DPP_ENUM___PTHREAD_MUTEX_HAVE_PREV = 1;
    enum DPP_ENUM__THREAD_SHARED_TYPES_H = 1;


    enum DPP_ENUM_FOPEN_MAX = 16;


    enum DPP_ENUM_L_ctermid = 9;


    enum DPP_ENUM_FILENAME_MAX = 4096;


    enum DPP_ENUM_TMP_MAX = 238328;


    enum DPP_ENUM_L_tmpnam = 20;


    enum DPP_ENUM__BITS_STDIO_LIM_H = 1;


    enum DPP_ENUM__BITS_STDINT_INTN_H = 1;






    enum DPP_ENUM__BITS_SS_FLAGS_H = 1;


    enum DPP_ENUM__BITS_SIGTHREAD_H = 1;


    enum DPP_ENUM_SIGSTKSZ = 8192;


    enum DPP_ENUM_MINSIGSTKSZ = 2048;


    enum DPP_ENUM__BITS_SIGSTACK_H = 1;


    enum DPP_ENUM___SIGRTMAX = 64;


    enum DPP_ENUM_SIGSYS = 31;


    enum DPP_ENUM_SIGPOLL = 29;


    enum DPP_ENUM_SIGURG = 23;


    enum DPP_ENUM_SIGTSTP = 20;


    enum DPP_ENUM_SIGSTOP = 19;


    enum DPP_ENUM_SIGCONT = 18;


    enum DPP_ENUM_SIGCHLD = 17;


    enum DPP_ENUM_SIGUSR2 = 12;


    enum DPP_ENUM_SIGUSR1 = 10;


    enum DPP_ENUM_SIGBUS = 7;


    enum DPP_ENUM_SIGPWR = 30;


    enum DPP_ENUM_SIGSTKFLT = 16;


    enum DPP_ENUM__BITS_SIGNUM_H = 1;




    enum DPP_ENUM___SIGRTMIN = 32;
    enum DPP_ENUM_SIGWINCH = 28;


    enum DPP_ENUM_SIGPROF = 27;


    enum DPP_ENUM_SIGVTALRM = 26;


    enum DPP_ENUM_SIGXFSZ = 25;


    enum DPP_ENUM_SIGXCPU = 24;


    enum DPP_ENUM_SIGTTOU = 22;


    enum DPP_ENUM_SIGTTIN = 21;


    enum DPP_ENUM_SIGALRM = 14;


    enum DPP_ENUM_SIGPIPE = 13;


    enum DPP_ENUM_SIGKILL = 9;


    enum DPP_ENUM_SIGTRAP = 5;


    enum DPP_ENUM_SIGQUIT = 3;


    enum DPP_ENUM_SIGHUP = 1;


    enum DPP_ENUM_SIGTERM = 15;


    enum DPP_ENUM_SIGSEGV = 11;


    enum DPP_ENUM_SIGFPE = 8;


    enum DPP_ENUM_SIGABRT = 6;


    enum DPP_ENUM_SIGILL = 4;


    enum DPP_ENUM_SIGINT = 2;
    enum DPP_ENUM__BITS_SIGNUM_GENERIC_H = 1;
    enum DPP_ENUM___SI_ASYNCIO_AFTER_SIGIO = 1;


    enum DPP_ENUM__BITS_SIGINFO_CONSTS_H = 1;


    enum DPP_ENUM__BITS_SIGINFO_ARCH_H = 1;
    enum DPP_ENUM__BITS_SIGEVENT_CONSTS_H = 1;
    enum DPP_ENUM__BITS_SIGCONTEXT_H = 1;


    enum DPP_ENUM_SIG_SETMASK = 2;


    enum DPP_ENUM_SIG_UNBLOCK = 1;


    enum DPP_ENUM_SIG_BLOCK = 0;
    enum DPP_ENUM_SA_SIGINFO = 4;


    enum DPP_ENUM_SA_NOCLDWAIT = 2;


    enum DPP_ENUM_SA_NOCLDSTOP = 1;






    enum DPP_ENUM__BITS_SIGACTION_H = 1;
    enum DPP_ENUM___have_pthread_attr_t = 1;


    enum DPP_ENUM__BITS_PTHREADTYPES_COMMON_H = 1;


    enum DPP_ENUM___PTHREAD_RWLOCK_INT_FLAGS_SHARED = 1;
    enum DPP_ENUM___PTHREAD_MUTEX_USE_UNION = 0;


    enum DPP_ENUM___PTHREAD_MUTEX_NUSERS_AFTER_KIND = 0;


    enum DPP_ENUM___PTHREAD_MUTEX_LOCK_ELISION = 1;






    enum DPP_ENUM___SIZEOF_PTHREAD_BARRIERATTR_T = 4;


    enum DPP_ENUM___SIZEOF_PTHREAD_RWLOCKATTR_T = 8;


    enum DPP_ENUM___SIZEOF_PTHREAD_CONDATTR_T = 4;


    enum DPP_ENUM___SIZEOF_PTHREAD_COND_T = 48;


    enum DPP_ENUM___SIZEOF_PTHREAD_MUTEXATTR_T = 4;


    enum DPP_ENUM___SIZEOF_PTHREAD_BARRIER_T = 32;


    enum DPP_ENUM___SIZEOF_PTHREAD_RWLOCK_T = 56;


    enum DPP_ENUM___SIZEOF_PTHREAD_MUTEX_T = 40;


    enum DPP_ENUM___SIZEOF_PTHREAD_ATTR_T = 56;


    enum DPP_ENUM__SYS_CDEFS_H = 1;


    enum DPP_ENUM__BITS_PTHREADTYPES_ARCH_H = 1;




    enum DPP_ENUM_CHARCLASS_NAME_MAX = 2048;
    enum DPP_ENUM_COLL_WEIGHTS_MAX = 255;
    enum DPP_ENUM___glibc_c99_flexarr_available = 1;


    enum DPP_ENUM__POSIX2_CHARCLASS_NAME_MAX = 14;


    enum DPP_ENUM__POSIX2_RE_DUP_MAX = 255;
    enum DPP_ENUM__POSIX2_LINE_MAX = 2048;


    enum DPP_ENUM__POSIX2_EXPR_NEST_MAX = 32;


    enum DPP_ENUM__POSIX2_COLL_WEIGHTS_MAX = 2;




    enum DPP_ENUM__POSIX2_BC_STRING_MAX = 1000;




    enum DPP_ENUM__POSIX2_BC_SCALE_MAX = 99;




    enum DPP_ENUM__POSIX2_BC_DIM_MAX = 2048;




    enum DPP_ENUM__POSIX2_BC_BASE_MAX = 99;






    enum DPP_ENUM__BITS_POSIX2_LIM_H = 1;






    enum DPP_ENUM__POSIX_CLOCKRES_MIN = 20000000;





    enum DPP_ENUM__POSIX_TZNAME_MAX = 6;




    enum DPP_ENUM__POSIX_TTY_NAME_MAX = 9;





    enum DPP_ENUM__POSIX_TIMER_MAX = 32;




    enum DPP_ENUM__POSIX_SYMLOOP_MAX = 8;





    enum DPP_ENUM__POSIX_SYMLINK_MAX = 255;




    enum DPP_ENUM__POSIX_STREAM_MAX = 8;




    enum DPP_ENUM__POSIX_SSIZE_MAX = 32767;




    enum DPP_ENUM__POSIX_SIGQUEUE_MAX = 32;


    enum DPP_ENUM__POSIX_SEM_VALUE_MAX = 32767;


    enum DPP_ENUM__POSIX_SEM_NSEMS_MAX = 256;


    enum DPP_ENUM__POSIX_RTSIG_MAX = 8;







    enum DPP_ENUM__POSIX_RE_DUP_MAX = 255;




    enum DPP_ENUM__POSIX_PIPE_BUF = 512;


    enum DPP_ENUM__POSIX_PATH_MAX = 256;


    enum DPP_ENUM__POSIX_OPEN_MAX = 20;


    enum DPP_ENUM__POSIX_NGROUPS_MAX = 8;




    enum DPP_ENUM__POSIX_NAME_MAX = 14;






    enum DPP_ENUM__POSIX_MQ_PRIO_MAX = 32;




    enum DPP_ENUM__POSIX_MQ_OPEN_MAX = 8;


    enum DPP_ENUM__POSIX_MAX_INPUT = 255;


    enum DPP_ENUM__POSIX_MAX_CANON = 255;


    enum DPP_ENUM__POSIX_LOGIN_NAME_MAX = 9;




    enum DPP_ENUM__POSIX_LINK_MAX = 8;




    enum DPP_ENUM__POSIX_HOST_NAME_MAX = 255;


    enum DPP_ENUM__POSIX_DELAYTIMER_MAX = 32;


    enum DPP_ENUM__POSIX_CHILD_MAX = 25;


    enum DPP_ENUM__POSIX_ARG_MAX = 4096;


    enum DPP_ENUM__POSIX_AIO_MAX = 1;


    enum DPP_ENUM__POSIX_AIO_LISTIO_MAX = 2;
    enum DPP_ENUM__BITS_POSIX1_LIM_H = 1;







    enum DPP_ENUM_NCARGS = 131072;


    enum DPP_ENUM_NOFILE = 256;







    enum DPP_ENUM_MAXSYMLINKS = 20;






    enum DPP_ENUM_MQ_PRIO_MAX = 32768;


    enum DPP_ENUM_HOST_NAME_MAX = 64;


    enum DPP_ENUM___HAVE_GENERIC_SELECTION = 1;


    enum DPP_ENUM_LOGIN_NAME_MAX = 256;


    enum DPP_ENUM__SYS_PARAM_H = 1;


    enum DPP_ENUM_TTY_NAME_MAX = 32;


    enum DPP_ENUM_DELAYTIMER_MAX = 2147483647;


    enum DPP_ENUM_PTHREAD_STACK_MIN = 16384;


    enum DPP_ENUM_AIO_PRIO_DELTA_MAX = 20;


    enum DPP_ENUM__POSIX_THREAD_THREADS_MAX = 64;






    enum DPP_ENUM__POSIX_THREAD_DESTRUCTOR_ITERATIONS = 4;




    enum DPP_ENUM_PTHREAD_KEYS_MAX = 1024;


    enum DPP_ENUM__POSIX_THREAD_KEYS_MAX = 128;
    enum DPP_ENUM___GLIBC_USE_IEC_60559_TYPES_EXT = 0;




    enum DPP_ENUM_DEV_BSIZE = 512;
    enum DPP_ENUM__SYS_SELECT_H = 1;


    enum DPP_ENUM___GLIBC_USE_IEC_60559_FUNCS_EXT = 0;


    enum DPP_ENUM___GLIBC_USE_IEC_60559_BFP_EXT = 0;


    enum DPP_ENUM___GLIBC_USE_LIB_EXT2 = 0;




    enum DPP_ENUM___HAVE_FLOAT64X_LONG_DOUBLE = 1;
    enum DPP_ENUM___HAVE_FLOAT64X = 1;


    enum DPP_ENUM___HAVE_DISTINCT_FLOAT128 = 0;


    enum DPP_ENUM___HAVE_FLOAT128 = 0;
    enum DPP_ENUM__SYS_TIME_H = 1;
    enum DPP_ENUM___HAVE_FLOATN_NOT_TYPEDEF = 0;







    enum DPP_ENUM___HAVE_DISTINCT_FLOAT64X = 0;
    enum DPP_ENUM___HAVE_DISTINCT_FLOAT32X = 0;


    enum DPP_ENUM___HAVE_DISTINCT_FLOAT64 = 0;


    enum DPP_ENUM___HAVE_DISTINCT_FLOAT32 = 0;




    enum DPP_ENUM___HAVE_FLOAT128X = 0;


    enum DPP_ENUM___HAVE_FLOAT32X = 1;


    enum DPP_ENUM___HAVE_FLOAT64 = 1;


    enum DPP_ENUM___HAVE_FLOAT32 = 1;


    enum DPP_ENUM___HAVE_FLOAT16 = 0;






    enum DPP_ENUM__BITS_ERRNO_H = 1;
    enum DPP_ENUM__BITS_BYTESWAP_H = 1;


    enum DPP_ENUM__SYS_TYPES_H = 1;


    enum DPP_ENUM_MAXHOSTNAMELEN = 64;




    enum DPP_ENUM_EXEC_PAGESIZE = 4096;


    enum DPP_ENUM_HZ = 100;




    enum DPP_ENUM_EHWPOISON = 133;


    enum DPP_ENUM_ERFKILL = 132;


    enum DPP_ENUM_ENOTRECOVERABLE = 131;


    enum DPP_ENUM_EOWNERDEAD = 130;


    enum DPP_ENUM_EKEYREJECTED = 129;


    enum DPP_ENUM_EKEYREVOKED = 128;




    enum DPP_ENUM_EKEYEXPIRED = 127;


    enum DPP_ENUM_ENOKEY = 126;




    enum DPP_ENUM_ECANCELED = 125;




    enum DPP_ENUM_EMEDIUMTYPE = 124;




    enum DPP_ENUM_ENOMEDIUM = 123;




    enum DPP_ENUM_EDQUOT = 122;




    enum DPP_ENUM_EREMOTEIO = 121;




    enum DPP_ENUM_EISNAM = 120;




    enum DPP_ENUM_ENAVAIL = 119;




    enum DPP_ENUM_ENOTNAM = 118;


    enum DPP_ENUM_EUCLEAN = 117;




    enum DPP_ENUM_ESTALE = 116;




    enum DPP_ENUM_EINPROGRESS = 115;


    enum DPP_ENUM_EALREADY = 114;


    enum DPP_ENUM_EHOSTUNREACH = 113;




    enum DPP_ENUM_EHOSTDOWN = 112;


    enum DPP_ENUM_ECONNREFUSED = 111;




    enum DPP_ENUM_ETIMEDOUT = 110;


    enum DPP_ENUM_ETOOMANYREFS = 109;


    enum DPP_ENUM_ESHUTDOWN = 108;


    enum DPP_ENUM_ENOTCONN = 107;


    enum DPP_ENUM_EISCONN = 106;


    enum DPP_ENUM_ENOBUFS = 105;


    enum DPP_ENUM_ECONNRESET = 104;


    enum DPP_ENUM_ECONNABORTED = 103;


    enum DPP_ENUM_ENETRESET = 102;


    enum DPP_ENUM_ENETUNREACH = 101;


    enum DPP_ENUM_ENETDOWN = 100;


    enum DPP_ENUM_EADDRNOTAVAIL = 99;





    enum DPP_ENUM_EADDRINUSE = 98;


    enum DPP_ENUM_EAFNOSUPPORT = 97;


    enum DPP_ENUM_EPFNOSUPPORT = 96;


    enum DPP_ENUM_EOPNOTSUPP = 95;


    enum DPP_ENUM_ESOCKTNOSUPPORT = 94;


    enum DPP_ENUM_EPROTONOSUPPORT = 93;


    enum DPP_ENUM_ENOPROTOOPT = 92;


    enum DPP_ENUM_EPROTOTYPE = 91;


    enum DPP_ENUM_EMSGSIZE = 90;


    enum DPP_ENUM___BIT_TYPES_DEFINED__ = 1;


    enum DPP_ENUM_EDESTADDRREQ = 89;


    enum DPP_ENUM_ENOTSOCK = 88;


    enum DPP_ENUM_EUSERS = 87;


    enum DPP_ENUM_ESTRPIPE = 86;


    enum DPP_ENUM_ERESTART = 85;




    enum DPP_ENUM_EILSEQ = 84;




    enum DPP_ENUM_ELIBEXEC = 83;




    enum DPP_ENUM_ELIBMAX = 82;




    enum DPP_ENUM_ELIBSCN = 81;


    enum DPP_ENUM_ELIBBAD = 80;


    enum DPP_ENUM_ELIBACC = 79;


    enum DPP_ENUM__SYS_UCONTEXT_H = 1;


    enum DPP_ENUM_EREMCHG = 78;


    enum DPP_ENUM_EBADFD = 77;


    enum DPP_ENUM_ENOTUNIQ = 76;


    enum DPP_ENUM_EOVERFLOW = 75;


    enum DPP_ENUM_EBADMSG = 74;




    enum DPP_ENUM_EDOTDOT = 73;


    enum DPP_ENUM_EMULTIHOP = 72;


    enum DPP_ENUM___NGREG = 23;


    enum DPP_ENUM_EPROTO = 71;




    enum DPP_ENUM_ECOMM = 70;


    enum DPP_ENUM_ESRMNT = 69;


    enum DPP_ENUM_EADV = 68;


    enum DPP_ENUM_ENOLINK = 67;


    enum DPP_ENUM_EREMOTE = 66;


    enum DPP_ENUM_ENOPKG = 65;


    enum DPP_ENUM_ENONET = 64;


    enum DPP_ENUM_ENOSR = 63;


    enum DPP_ENUM_ETIME = 62;


    enum DPP_ENUM_ENODATA = 61;


    enum DPP_ENUM_ENOSTR = 60;


    enum DPP_ENUM_EBFONT = 59;




    enum DPP_ENUM_EBADSLT = 57;


    enum DPP_ENUM_EBADRQC = 56;


    enum DPP_ENUM_ENOANO = 55;


    enum DPP_ENUM_EXFULL = 54;


    enum DPP_ENUM_EBADR = 53;


    enum DPP_ENUM_EBADE = 52;


    enum DPP_ENUM_EL2HLT = 51;


    enum DPP_ENUM_ENOCSI = 50;


    enum DPP_ENUM_EUNATCH = 49;


    enum DPP_ENUM_ELNRNG = 48;


    enum DPP_ENUM_EL3RST = 47;




    enum DPP_ENUM_EL3HLT = 46;




    enum DPP_ENUM_EL2NSYNC = 45;


    enum DPP_ENUM_ECHRNG = 44;


    enum DPP_ENUM_EIDRM = 43;
    enum DPP_ENUM_ENOMSG = 42;
    enum DPP_ENUM_ELOOP = 40;




    enum DPP_ENUM_ENOTEMPTY = 39;
    enum DPP_ENUM_ENOSYS = 38;




    enum DPP_ENUM___GNUC_VA_LIST = 1;


    enum DPP_ENUM_ENOLCK = 37;


    enum DPP_ENUM_ENAMETOOLONG = 36;


    enum DPP_ENUM_EDEADLK = 35;




    enum DPP_ENUM_ERANGE = 34;


    enum DPP_ENUM_EDOM = 33;


    enum DPP_ENUM_EPIPE = 32;


    enum DPP_ENUM_EMLINK = 31;


    enum DPP_ENUM_EROFS = 30;


    enum DPP_ENUM_ESPIPE = 29;


    enum DPP_ENUM_ENOSPC = 28;


    enum DPP_ENUM_EFBIG = 27;


    enum DPP_ENUM_ETXTBSY = 26;


    enum DPP_ENUM_ENOTTY = 25;


    enum DPP_ENUM_EMFILE = 24;


    enum DPP_ENUM_ENFILE = 23;


    enum DPP_ENUM_EINVAL = 22;


    enum DPP_ENUM_EISDIR = 21;


    enum DPP_ENUM_ENOTDIR = 20;


    enum DPP_ENUM_ENODEV = 19;


    enum DPP_ENUM_EXDEV = 18;


    enum DPP_ENUM_EEXIST = 17;


    enum DPP_ENUM_EBUSY = 16;


    enum DPP_ENUM_ENOTBLK = 15;


    enum DPP_ENUM_EFAULT = 14;


    enum DPP_ENUM_EACCES = 13;


    enum DPP_ENUM_ENOMEM = 12;


    enum DPP_ENUM_EAGAIN = 11;


    enum DPP_ENUM_ECHILD = 10;


    enum DPP_ENUM_EBADF = 9;


    enum DPP_ENUM_ENOEXEC = 8;


    enum DPP_ENUM_E2BIG = 7;


    enum DPP_ENUM_ENXIO = 6;


    enum DPP_ENUM_EIO = 5;


    enum DPP_ENUM_EINTR = 4;


    enum DPP_ENUM_ESRCH = 3;


    enum DPP_ENUM_ENOENT = 2;


    enum DPP_ENUM_EPERM = 1;
    enum DPP_ENUM__ALLOCA_H = 1;
    enum DPP_ENUM_ZAP_MAXNAMELEN = 256;




    enum DPP_ENUM_ZAP_OLDMAXVALUELEN = 1024;


    enum DPP_ENUM_ZFS_MAX_DATASET_NAME_LEN = 256;


    enum DPP_ENUM_ZPROP_MAX_COMMENT = 32;
    enum DPP_ENUM_ZFS_WRITTEN_PROP_PREFIX_LEN = 8;
    enum DPP_ENUM_DEFAULT_PBKDF2_ITERATIONS = 350000;


    enum DPP_ENUM_MIN_PBKDF2_ITERATIONS = 100000;
    enum DPP_ENUM_ZPOOL_NO_REWIND = 1;


    enum DPP_ENUM_ZPOOL_NEVER_REWIND = 2;


    enum DPP_ENUM_ZPOOL_TRY_REWIND = 4;


    enum DPP_ENUM_ZPOOL_DO_REWIND = 8;


    enum DPP_ENUM_ZPOOL_EXTREME_REWIND = 16;


    enum DPP_ENUM_ZPOOL_REWIND_MASK = 28;


    enum DPP_ENUM_ZPOOL_REWIND_POLICIES = 31;
    enum DPP_ENUM_VS_ZIO_TYPES = 6;


    enum DPP_ENUM_VDEV_L_HISTO_BUCKETS = 37;


    enum DPP_ENUM_VDEV_RQ_HISTO_BUCKETS = 25;
    enum DPP_ENUM_ZVOL_MAJOR = 230;


    enum DPP_ENUM_ZVOL_MINOR_BITS = 4;
    enum DPP_ENUM_ZVOL_DEFAULT_BLOCKSIZE = 8192;
    enum DPP_ENUM_NV_VERSION = 0;


    enum DPP_ENUM_NV_ENCODE_NATIVE = 0;


    enum DPP_ENUM_NV_ENCODE_XDR = 1;
}


struct re_dfa_t;

/+
 work towards Dlang wrapper for libzfs-core
+/




import std.string:toStringz, fromStringz;
import std.exception;
import taggedalgebraic;
import std.conv:to;

alias toCString = toStringz;
alias fromCString = fromStringz;

struct SILdoc {string value; }

void rename(string from, string to)
{
 auto result = lzc_rename(from.toCString, to.toCString);
 enforce(result==0,"something went wrong");
}



enum DatasetType
{
 zfs = LZC_DATSET_TYPE_ZFS,
 zvol = LZC_DATSET_TYPE_ZVOL,
}


enum VdevType
{
 root,
 mirror,
 replacing,
 raidz,
 disk,
 file,
 missing,
 hole,
 spare,
 log,
 l2cache,
}

enum PoolStatus
{
 corruptCache,
 missingDevR,
 missingDevNr,
 corruptLabelR,
 corruptLabelNr,
 badGUIDSum,
 corruptPool,
 corruptData,
 failingDev,
 versionNewer,
 hostidMismatch,
 hosidActive,
 hostidRequired,
 ioFailureWait,
 ioFailureContinue,
 ioFailureMap,
 badLog,
 errata,







 unsupFeatRead,
 unsupFeatWrite,






 faultedDevR,
 faultedDevNr,






 versionOlder,
 featDisabled,
 resilvering,
 offlineDev,
 removedDev,




 ok,
}


enum PoolState
{
 active,
 exported,
 destroyed,
 spare,
 l2cache,
 uninitialized,
 unavail,
 potentiallyActive
}



enum PoolProperty
{
 cont,
 inval,
 name,
 size,
 capacity,
 altroot,
 health,
 guid,
 version_,
 bootfs,
 delegation,
 autoReplace,
 cacheFile,
 failureMode,
 listSnaps,
 autoExpand,
 dedupDitto,
 dedupRatio,
 free,
 allocated,
 readOnly,
 ashift,
 comment,
 expandSize,
 freeing,
 fragmentation,
 leaked,
 maxBlockSize,
 tName,
 maxNodeSize,
 multiHost,
 poolNumProps,
}
enum DatasetProperty
{
 cont,
 bad,
 type,
 creation,
 used,
 available,
 referenced,
 compressRatio,
 mounted,
 origin,
 quota,
 reservation,
 volSize,
 volBlockSize,
 recordsize,
 mountpoint,
 sharenfs,
 checksum,
 compression,
 atime,
 devices,
 exec,
 setuid,
 readonly,
 zoned,
 snapdir,
 private_,
 aclinherit,
 createTXG,
 name,
 canmount,
 iscsioptions,
 xattr,
 numclones,
 copies,
 version_,
 utf8only,
 normalize,
 case_,
 vscan,
 nbmand,
 sharesmb,
 refquota,
 refreservation,
 guid,
 primarycache,
 secondarycache,
 usedsnap,
 usedds,
 usedchild,
 usedrefreserv,
 useraccounting,
 stmfShareinfo,
 deferDestroy,
 userrefs,
 logbias,
 unique,
 objsetid,
 dedup,
 mlslabel,
 sync,
 dnodeSize,
 refratio,
 written,
 clones,
 logicalused,
 logicalreferenced,
 inconsistent,
 volmode,
 filesystemLimit,
 snapshotLimit,
 filesystemCount,
 snapshotCount,
 snapdev,
 acltype,
 selinuxContext,
 selinuxFsContext,
 selinuxDefContext,
 selinuxRootContext,
 relatime,
 redundantMetadata,
 overlay,
 prevSnap,
 receiveResumeToken,
 encryption,
 keyLocation,
 keyFormat,
 pBKDF2Salt,
 pBKDF2Iters,
 encryptionRoot,
 keyGUID,
 keyStatus,
 remapTXG,
 datasetNumProps,
}



enum ZfsError
{
 success = 0,
 nomem ,
 badprop,
 propreadonly,
 proptype,
 propnoninherit,
 propspace,
 badtype,
 busy,
 exists,
 noent,
 badstream,
 dsreadonly,
 voltoobig,
 invalidname,
 badrestore,
 badbackup,
 badtarget,
 nodevice,
 baddev,
 noreplicas,
 resilvering,
 badversion,
 poolunavail,
 devoverflow,
 badpath,
 crosstarget,
 zoned,
 mountfailed,
 umountfailed,
 unsharenfsfailed,
 sharenfsfailed,
 perm,
 nospc,
 fault,
 io,
 intr,
 isspare,
 invalconfig,
 recursive,
 nohistory,
 poolprops,
 poolNotsup,
 poolInvalarg,
 nametoolong,
 openfailed,
 nocap,
 labelfailed,
 badwho,
 badperm,
 badpermset,
 nodelegation,
 unsharesmbfailed,
 sharesmbfailed,
 badcache,
 isl2CACHE,
 vdevnotsup,
 notsup,
 activeSpare,
 unplayedLogs,
 reftagRele,
 reftagHold,
 tagtoolong,
 pipefailed,
 threadcreatefailed,
 postsplitOnline,
 scrubbing,
 noScrub,
 diff,
 diffdata,
 poolreadonly,
 unknown,
}



enum VdevState
{
 unknown,
 closed,
 offline,
 removed,
 cantOpen,
 faulted,
 degraded,
 healthy,
}



enum VdevAux
{
 none,
 openFailed,
 corruptData,
 noReplicas,
 badGUIDSum,
 tooSmall,
 badLabel,
 versionNewer,
 versionOlder,
 unsupFeat,
 spared,
 errExceeded,
 ioFailure,
 badLog,
 external,
 splitPool,
}



struct ZfsErrorResult
{
 int num;
 string text;
}


shared static this()
{
 enforce(libzfs_core_init() == 0, "Error initialising ZFS");
}

shared static ~this()
{
 libzfs_core_fini();
}

version(None)
{
 auto toList(string[string] args)
 {
  nvlist_t** pNvList = nvlist_alloc(nvlistp,1,0);
  enforce(pNvList !is null, "nvlist_alloca failed");
  scope(exit)
   nvlist_free(pNvList);
  return dictToNvList(args,pNvList);
 }

 auto asDict(nv_list* list)
 {
  string[string] ret;

  pair = nvlist_next_nvpair(list,null);
  while (pair !is null)
  {
   auto name = nvpair_name(pair).fromCString;
   auto id = type(pair);
  }
 }

 auto type(nvpair* pair)
 {
  auto id = nvpair_typie(pair);
 }
}

enum NvType
{
 unknown = DATA_TYPE_UNKNOWN,
 boolean = DATA_TYPE_BOOLEAN,
 byte_ = DATA_TYPE_BYTE,
 short_ = DATA_TYPE_INT16,
 ushort_ = DATA_TYPE_UINT16,
 int_ = DATA_TYPE_INT32,
 uint_ = DATA_TYPE_UINT32,
 long_ = DATA_TYPE_INT64,
 ulong_ = DATA_TYPE_UINT64,
 string_ = DATA_TYPE_STRING,
 byteArray = DATA_TYPE_BYTE_ARRAY,
 shortArray = DATA_TYPE_INT16_ARRAY,
 ushortArray = DATA_TYPE_UINT16_ARRAY,
 intArray = DATA_TYPE_INT32_ARRAY,
 uintArray = DATA_TYPE_UINT32_ARRAY,
 longArray = DATA_TYPE_INT64_ARRAY,
 ulongArray = DATA_TYPE_UINT64_ARRAY,
 stringArray = DATA_TYPE_STRING_ARRAY,
 hrTime = DATA_TYPE_HRTIME,
 nvList = DATA_TYPE_NVLIST,
 nvListArray = DATA_TYPE_NVLIST_ARRAY,
 booleanValue = DATA_TYPE_BOOLEAN_VALUE,
 int8 = DATA_TYPE_INT8,
 uint8 = DATA_TYPE_UINT8,
 booleanArray = DATA_TYPE_BOOLEAN_ARRAY,
 int8Array = DATA_TYPE_INT8_ARRAY,
 uint8Array = DATA_TYPE_UINT8_ARRAY,
 double_ = DATA_TYPE_DOUBLE
}

union ZfsValueUnion
{
 bool boolean;
 byte byte_;
 char int8Value;
 ubyte ubyteValue;
 short short_;
 ushort ushort_;
 int int_;
 uint uint_;
 long long_;
 ulong ulong_;
 string string_;
 bool[] booleanArray;
 char[] charArray;
 ubyte[] ubyteArray;
 short[] shortArray;
 ushort[] ushortArray;
 int[] intArray;
 uint[] uintArray;
 long[] longArray;
 ulong[] ulongArray;
 string[] stringArray;




 double double_;
 ZfsValueUnion[] valueArray;
 ZfsValueUnion[string] valueDict;
}

alias ZfsValue = TaggedAlgebraic!ZfsValueUnion;

/+
nvlist_t* asList(ZfsValue[string] values)
{
 foreach(entry;values.byKeyValue)
 {
  final switch(entry.value.kind)
  {
   case ZfsValue.Kind.valueDict:
    nvlist_add_nvlist(list,entry.key.toCString,entry.value.asCValue);
    break;

   case ZfsValue.Kind.valueArray:
    nvlist_add_array(list,entry.key.toCString,entry.value.asCValue);
    break;

   case ZfsValue.
+/

void create(string filesystem, DatasetType dataSetType, ubyte[] wkeyData)
{
 auto props = nvlistAlloc(0x1, 0);
 scope(exit)
  nvlistFree(props);
 auto result = lzc_create(filesystem.toCString, cast(lzc_dataset_type) dataSetType, props,wkeyData.ptr,wkeyData.length.to!uint_t);
 enforce(result==0,"something went wrong");
}

void clone(string filesystem, string origin)
{
 auto props = nvlistAlloc(0x1, 0);
 scope(exit)
  nvlistFree(props);
 auto result = lzc_clone(filesystem.toCString,origin.toCString,props);
 enforce(result==0,"something went wrong");
}

string promote(string filesystem)
{
 char[16384] buf;
 auto result = lzc_promote(filesystem.toCString,buf.ptr, buf.length);
 enforce(result==0,"something went wrong");
 return buf.ptr.fromCString.idup;
}

void remap(string filesystem)
{
 auto result = lzc_remap(filesystem.toCString);
 enforce(result==0,"something went wrong");
}


ulong snapRangeSpace(string firstSnap, string lastSnap)
{
 ulong ret;
 auto result = lzc_snaprange_space(firstSnap.toCString, lastSnap.toCString,&ret);
 enforce(result>=0, "zfs error");
 return ret;
}

/+
auto poolSync(string poolName, NVL[] nvl)
{

 nvlist_t* outnvl;
 auto result = lzc_sync(poolName.toCString,innvl,&outnvl);
}


void holdSnapshot(Snap[] holdSnapshots, int cleanUpFD)
{
 int lzc_hold(nvlist_t *holds, int cleanup_fd, nvlist_t **errlist)
}


void unholdSnapshot(Snap[] holdSnapshots, int cleanupFD)
{
 int lzc_hold(nvlist_t *holds, int cleanup_fd, nvlist_t **errlist)
}

auto getHeldSnapshots(stringsource/libzfs_core.d.tmp:6432:44: warning: missing terminating ' character
 Note: this interface does not work on dedup'd streams (those with DMU_BACKUP_FEATURE_DEDUP).
                                            ^
 snapName)
{
 int lzc_get_holds(const char *snapname, nvlist_t **holdsp)
}
+/

enum SendFlag
{
 largeBlock = LZC_SEND_FLAG_LARGE_BLOCK,
 embedData = LZC_SEND_FLAG_EMBED_DATA,
 compress = LZC_SEND_FLAG_COMPRESS,
 raw = LZC_SEND_FLAG_RAW
}

void sendSnapshot(string snapshotName, string fromSnapshot, int fileDescriptor, SendFlag[] flags)
{
 import std.algorithm:fold;
 auto lzcFlags = flags.fold!((a,b) => a| b)(cast(SendFlag)0).to!lzc_send_flags;
 auto result = lzc_send(snapshotName.toCString, fromSnapshot.toCString,fileDescriptor,lzcFlags);
 enforce(result == 0, "zfs error");
}

auto sendResume(string snapshotName, string fromSnapshot, int fileDescriptor, SendFlag[] flags, ulong resumeObj, ulong resumeOff)
{
 import std.algorithm:fold;
 auto lzcFlags = flags.fold!((a,b) => a| b)(cast(SendFlag)0).to!lzc_send_flags;
 auto result = lzc_send_resume(snapshotName.toCString, fromSnapshot.toCString, fileDescriptor, lzcFlags, resumeObj, resumeOff);
 enforce(result == 0, "zfs error");
}

@SILdoc(`
"from" can be (cast(void*)0), a snapshot, or a bookmark.

If from is (cast(void*)0), a full (non-incremental) stream will be estimated. This
is calculated very efficiently.

If from is a snapshot, lzc_send_space uses the deadlists attached to
each snapshot to efficiently estimate the stream size.

If from is a bookmark, the indirect blocks in the destination snapshot
are traversed, looking for blocks with a birth time since the creation TXG of
the snapshot this bookmark was created from. This will result in
significantly more I/O and be less efficient than a send space estimation on
an equivalent snapshot.
`)
auto sendSpace(string snapshotName, string from, SendFlag[] flags)
{
 import std.algorithm:fold;
 auto lzcFlags = flags.fold!((a,b) => a| b)(cast(SendFlag)0).to!lzc_send_flags;
 ulong retSpace;
 auto result = lzc_send_space(snapshotName.toCString, from.toCString, lzcFlags,&retSpace);
 enforce(result == 0, "zfs error");
 return retSpace;
}

/+
auto recvRead(int fileDescriptor, ubyte[] buf)
{
 import std.format:format;
 auto result = lzc_recv_read(fileDescriptor,cast(void*)buf.ptr,buf.length.to!int);
 enforce(result == 0, format!"zfs error: %s"(result));
}

*
 * Linux adds ZFS_IOC_RECV_NEW for resumable and raw streams and preserves the
 * legacy ZFS_IOC_RECV user/kernel interface. The new interface supports all
 * stream options but is currently only used for resumable streams. This way
 * updated user space utilities will interoperate with older kernel modules.
 *
 * Non-Linux OpenZFS platforms have opted to modify the legacy interface.
 */
int recv_impl(const char *snapname, nvlist_t *recvdprops, nvlist_t *localprops, uint8_t *wkeydata, uint_t wkeylen, const char *origin, boolean_t force, boolean_t resumable, boolean_t raw, int input_fd, const dmu_replay_record_t *begin_record, int cleanup_fd, uint64_t *read_bytes, uint64_t *errflags, uint64_t *action_handle, nvlist_t **errors)

+/

@SILdoc(`zfs receive:
The simplest receive case: receive from the specified fd, creating the
specified snapshot. Apply the specified properties as "received" properties
(which can be overridden by locally-set properties). If the stream is a
clone, its origin snapshot must be specified by 'origin'. The 'force'
flag will cause the target filesystem to be rolled back or destroyed if
necessary to receive.

Return 0 on success or an (*__errno_location ()) on failure.

Note: this interface does not work on dedup'd streams (those with DMU_BACKUP_FEATURE_DEDUP).

resumable: Like lzc_receive, but if the receive fails due to premature stream termination, the intermediate state will be preserved on disk. In this case, ECKSUM will be returned. The receive may subsequently be resumed with a resuming send stream generated by lzc_send_resume().
`)
auto zfsReceive(string snapName, string origin, bool force, bool raw, int fileDescriptor, bool resumable = false)
{
 import std.format:format;

 auto props = nvlistAlloc(0x1, 0);
 scope(exit)
  nvlistFree(props);
 auto result = resumable ? lzc_receive(snapName.toCString, props,origin.toCString, force? 1:0, raw?1:0, fileDescriptor) :
   lzc_receive_resumable(snapName.toCString, props,origin.toCString, force?1:0, raw? 1:0, fileDescriptor);
 enforce(result == 0, format!"zfs error: %s"(result));
}

/+
int
lzc_receive_with_header(const char *snapname, nvlist_t *props,
    const char *origin, boolean_t force, boolean_t resumable, boolean_t raw,
    int fd, const dmu_replay_record_t *begin_record)

*
 * Like lzc_receive, but allows the caller to pass all supported arguments
 * and retrieve all values returned. The only additional input parameter
 * is 'cleanup_fd' which is used to set a cleanup-on-exit file descriptor.
 *
 * The following parameters all provide return values. Several may be set
 * in the failure case and will contain additional information.
 *
 * The 'read_bytes' value will be set to the total number of bytes read.
 *
 * The 'errflags' value will contain zprop_errflags_t flags which are
 * used to describe any failures.
 *
 * The 'action_handle' is used to pass the handle for this guid/ds mapping.
 * It should be set to zero on first call and will contain an updated handle
 * on success, it should be passed in subsequent calls.
 *
 * The 'errors' nvlist contains an entry for each unapplied received
 * property. Callers are responsible for freeing this nvlist.
 */
int lzc_receive_one(const char *snapname, nvlist_t *props,
    const char *origin, boolean_t force, boolean_t resumable, boolean_t raw,
    int input_fd, const dmu_replay_record_t *begin_record, int cleanup_fd,
    uint64_t *read_bytes, uint64_t *errflags, uint64_t *action_handle,
    nvlist_t **errors)

@SILdoc(`Like lzc_receive_one, but allows the caller to pass an additional 'cmdprops' argument.

The 'cmdprops' nvlist contains both override ('zfs receive -o') and
exclude ('zfs receive -x') properties. Callers are responsible for freeing
this nvlist
`)
auto zfsReceiveWithCommandProperties(string snapName, Property[] properties, Property[] commandProperties, ubyte[] keyData, string origin, bool force, bool resumable, bool raw, int inputFileDescriptor, DmuReplyRecord* beginRecord, int cleanupFileDescriptor)
{
 ulong readBytes;
 ulong errFlags;
 ulong actionHandle;
 nvlist_t* errors;

 auto result = lzc_receive_with_cmdprops(snapName.toCString, properties.asPtr, commandProperties.asPtr, keyData.ptr, keyData.length.to!uint, origin.toCString, force ? 1 :0, resumable ? 1 :0, raw ? 1 : 0, inputFileDescriptor, beginRecord, cleanupFileDescriptor, &readBytes, &errFlags, &actionHandle, &errors);
 enforce(result == 0, format!"zfs error %s"(result));
}

+/

@SILdoc(`Roll back this filesystem or volume to its most recent snapshot
If snapnamebuf is not (cast(void*)0), it will be filled in with the name
of the most recent snapshot.
Note that the latest snapshot may change if a new one is concurrently
created or the current one is destroyed. lzc_rollback_to can be used
to roll back to a specific latest snapshot.

Return 0 on success or an (*__errno_location ()) on failure.
`)
string rollback(string fsname)
{
 import std.format:format;
 char[16384] buf;
 auto result = lzc_rollback(fsname.toCString, buf.ptr, buf.length.to!int);
 enforce(result ==0, format!"libzfs_core error %s rolling back on %s"(result,fsname));
 return buf.ptr.fromCString.idup;
}

@SILdoc(`Roll back this filesystem or volume to the specified snapshot, if possible`)
void rollbackTo(string fsName, string snapName)
{
 import std.format:format;
 auto result = lzc_rollback_to(fsName.toCString, snapName.toCString);
 enforce(result == 0, format!"zfs error: %s"(result));
}

/+
@SILdoc(`Creates bookmarks.

The bookmarks nvlist maps from name of the bookmark (e.g. "pool/fs#bmark") to
the name of the snapshot (e.g. "pool/fs@snap"). All the bookmarks and
snapshots must be in the same pool.

The returned results nvlist will have an entry for each bookmark that failed.
The value will be the (int32) error code.

The return value will be 0 if all bookmarks were created, otherwise it will
be the (*__errno_location ()) of a (undetermined) bookmarks that failed.
`)
auto createBookmarks(Bookmark[] bookmarks)
{
 nvlist_t* errlist;
 auto result = lzc_bookmark(bookmarks.asPtr, &errlist);
 enforce(result == 0, format!" zfs error: %s"(result));
}


@SILdoc(`
Retrieve bookmarks.

Retrieve the list of bookmarks for the given file system. The props
parameter is an nvlist of property names (with no values) that will be
returned for each bookmark.

The following are valid properties on bookmarks, all of which are numbers
(represented as uint64 in the nvlist)

"guid" - globally unique identifier of the snapshot it refers to
"createtxg" - txg when the snapshot it refers to was created
"creation" - timestamp when the snapshot it refers to was created

The format of the returned nvlist as follows:
 <short name of bookmark> -> {
    <name of property> -> {
         "value" -> uint64
    }
  }
`)
auto getBookmarks(string fsName, Property[] properties)
{
 nvlist_t* bmarks;
 auto result = lzc_get_bookmarks(fsName.toStringz, properties.asPtr,&bmarks);
 enforce(result == 0, "ZFS error");
 return NvList(bmarks);
}

@SILdoc(`Destroys bookmarks

The keys in the bmarks nvlist are the bookmarks to be destroyed.
They must all be in the same pool. Bookmarks are specified as
<fs>#<bmark>.

Bookmarks that do not exist will be silently ignored.

The return value will be 0 if all bookmarks that existed were destroyed.

Otherwise the return value will be the (*__errno_location ()) of a (undetermined) bookmark
that failed, no bookmarks will be destroyed, and the errlist will have an
entry for each bookmarks that failed. The value in the errlist will be
the (int32) error code.
`)
auto destroyBookmarks(Bookmark[] bookmarks)
{
 nvlist_t* errlist;
 auto result = lzc_destroy_bookmarks(bookmarks.asPtr,&errlist);
 enforce(result == 0, "zfs error");
 return 0;
}


@SILdoc(`Executes a channel program

If this function returns 0 the channel program was successfully loaded and
ran without failing. Note that individual commands the channel program ran
may have failed and the channel program is responsible for reporting such
errors through outnvl if they are important.

This method may also return:

 22 The program contains syntax errors, or an invalid memory or time
          limit was given. No part of the channel program was executed.
          If caused by syntax errors, 'outnvl' contains information about the
          errors.

 44 The program was executed, but encountered a runtime error, such as
          calling a function with incorrect arguments, invoking the error()
          function directly, failing an assert() command, etc. Some portion
          of the channel program may have executed and committed changes.
          Information about the failure can be found in 'outnvl'.

 12 The program fully executed, but the output buffer was not large
          enough to store the returned value. No output is returned through
          'outnvl'.

 28 The program was terminated because it exceeded its memory usage
          limit. Some portion of the channel program may have executed and
          committed changes to disk. No output is returned through 'outnvl'.

 62 The program was terminated because it exceeded its Lua instruction
          limit. Some portion of the channel program may have executed and
          committed changes to disk. No output is returned through 'outnvl'.
`)
void executeChannelProgram(string pool, string program, ulong instrLimit, ulong memLimit, NvList args)
{
 nvlist_t** outnvl;
 auto result = lzc_channel_program(pool.toCString, program.toCString, instrLimit, memLimit, args.asPtr, &outnvl);
 enforce(result == 0, format!"zfs error: %s"(result));
}

+/

@SILdoc(`Creates a checkpoint for the specified pool.

If this function returns 0 the pool was successfully checkpointed.

This method may also return:

 ZFS_ERR_CHECKPOINT_EXISTS
 The pool already has a checkpoint. A pools can only have one
    checkpoint at most, at any given time.

 ZFS_ERR_DISCARDING_CHECKPOINT
  ZFS is in the middle of discarding a checkpoint for this pool.
  The pool can be checkpointed again once the discard is done.

 ZFS_DEVRM_IN_PROGRESS
  A vdev is currently being removed. The pool cannot be
  checkpointed until the device removal is done.

 ZFS_VDEV_TOO_BIG
  One or more top-level vdevs exceed the maximum vdev size
  supported for this feature.
`)
void createCheckpoint(string pool)
{
 import std.format:format;
 auto result = lzc_pool_checkpoint(pool.toCString);
 enforce(result == 0, format!"zfs error: %s"(result));
}

@SILdoc(`Discard the checkpoint from the specified pool`)
void discardCheckpoint(string pool)
{
 auto result = lzc_pool_checkpoint_discard(pool.toCString);
 enforce(result != ZFS_ERR_NO_CHECKPOINT, "The pool does not have a checkpoint.");
 enforce(result != ZFS_ERR_DISCARDING_CHECKPOINT, "ZFS is already in the middle of discarding the checkpoint.");
 enforce(result != ZFS_ERR_CHECKPOINT_EXISTS, "ZFS checkpoint already exists");


}

/+
@SILdoc(`
Executes a read-only channel program.

A read-only channel program works programmatically the same way as a
normal channel program executed with lzc_channel_program(). The only
difference is it runs exclusively in open-context and therefore can
return faster. The downside to that, is that the program cannot change
on-disk state by calling functions from the zfs.sync submodule.

The return values of this function (and their meaning) are exactly the
same as the ones described in lzc_channel_program().
`)
auto executeChannelProgramNoSync(string pool, string program, ulong timeout, ulong memLimit, NvList[] args)
{
 nvlist_t* outnvl;
 auto result = lzc_channel_program_nosync(pool.toCString, program.toCString, timeout, memLimit, args.asPtr, &ret);
 enforce(result == 0, "zfs error");
 return NvList(outnvl);
}

+/
auto loadKey(string fsName, bool noOp, ubyte[] wkeyData)
{
 import std.format:format;
 auto result = lzc_load_key(fsName.toCString, noOp ? 1 : 0, wkeyData.ptr, wkeyData.length.to!uint);
 enforce(result ==0, format!"loadkey failed with %s"(result));
}

void unloadKey(string fsName)
{
 import std.format:format;
 auto result = lzc_unload_key(fsName.toCString);
 enforce(result ==0, format!"unLoadkey failed with %s"(result));
}
string zfsVersion()
{
 import std.process: executeShell;
 import std.string: splitLines, startsWith, strip, join;
 import std.algorithm: filter;
 import std.format:format;

 auto result = executeShell("modinfo zfs");
 enforce(result.status == 0, result.output);
 auto lines = result.output.splitLines.filter!(line => line.startsWith("version:"));
 return lines.front.strip;
}





void cloneSnapshot(string from, string target)
{
 import std.format:format;
 auto props = nvlistAlloc(0x1, 0);
 scope(exit)
  nvlistFree(props);
 auto result = lzc_clone(target.toCString, from.toCString, props);
 enforce(result ==0, format!"failed clone: %s %s %s"(from,target,result));
}



bool snapshotExists(string path)
{
 return lzc_exists(path.toCString) !=0;
}



void snapshot(string[] snapshotNames)
{
 import std.format:format;
 import std.string: join;
 auto snapshots = nvlistAlloc(0x1, 0);
 foreach(name;snapshotNames)
 {
  nvlistAddBoolean(snapshots,name);
 }


 auto props = nvlistAlloc(0x1, 0);
 scope(exit)
  nvlistFree(props);

 nvlist_t* errList;
 auto result = lzc_snapshot(snapshots, props, &errList);
 if (result != 0)
 {
  auto ret2 = processErrorList(errList);
  enforce(ret2.length ==0, format!" failed libzfs_core snapshot: %s, %s"(snapshotNames,ret2.join(",")));
 }
}


void destroySnapshots(string[] snapshotNames, bool deferDelete)
{
 import std.format:format;
 import std.string:join;
 auto snapshots = nvlistAlloc(0x1, 0);
 scope(exit) nvlistFree(snapshots);
 foreach(name;snapshotNames)
 {
  nvlistAddBoolean(snapshots, name);
 }

 nvlist_t* errList;
 boolean_t cdeferDelete = (deferDelete) ? 1 : 0;
 auto result = lzc_destroy_snaps(snapshots, cdeferDelete, &errList);
 if (result != 0)
 {
  auto ret2 = processErrorList(errList);
  enforce(ret2.length ==0, format!" failed libzfs_core snapshot: %s, %s"(snapshotNames,ret2.join(",")));
 }
}


nvlist_t* nvlistAlloc(uint nvflag, int kmflag)
{
 nvlist_t* cnvlist;
 auto result = nvlist_alloc(&cnvlist, nvflag, kmflag);
 enforce(result ==0, "failed to allocate nvlist");
 return cnvlist;
}


void nvlistFree(nvlist_t* cnvlist)
{
 nvlist_free(cnvlist);
}

@SILdoc(`Destroy is the wrapper for lzc_destroy`)
ZfsResult destroy(string name)
{
 import std.format:format;
 auto result = lzc_destroy(name.toCString);
 return zfsResult(result==0, ZfsError.noent, format!"failed to destroy %s: %s"(name,result));
}





string[] processErrorList(nvlist_t* errList)
{
 import std.format:format;
 string[] ret;
 if (isNvlistEmpty(errList)) {
  return ret;
 }

 scope(exit)
  nvlistFree(errList);
 int errNum;
 nvpair_t* elem = nextNvPair(errList);
 while(elem !is null)
 {
  auto s = nvpair_name(elem).fromCString;
  nvpair_value_int32(elem, &errNum);
  ret ~= format!"Failed Snapshot '%s':%s"(s,errNum);
  elem = nvlist_next_nvpair(errList, elem);
 }
 return ret;
}


nvpair_t* nextNvPair(nvlist_t* list, nvpair_t* elemArg = null)
{
 nvpair_t* elem;
 if (elemArg !is null)
  elem = elemArg;
 elem = nvlist_next_nvpair(list, elem);
 return elem;
}



void nvlistAddBoolean(nvlist_t* nvlist, string name)
{
 import std.format:format;
 auto errnoResult = nvlist_add_boolean(nvlist, name.toCString);
 enforce(errnoResult ==0, format!"Failed to add boolean: %s"(errnoResult));
}

bool isNvlistEmpty(nvlist_t* cnvlist)
{
 return (nvlist_empty(cnvlist) !=0);
}





void createFileSystem(string path, void* datasetType=null, void* properties=null, ubyte[] wkeyData =[])
{
 import std.format:format;
 auto props = nvlistAlloc(0x1, 0);
 enforce(props !is null, "alloc failure for props for "~path );
 scope(exit)
  nvlistFree(props);

 auto cpath = path.toCString;

 auto result = lzc_create(cpath, LZC_DATSET_TYPE_ZFS, props,null,0);
 enforce(result ==0, format!"Failed libzfs_core create: %s"(result));
}

void destroyFileSystem(string path)
{
 throw new Exception("Not implemented");
}

auto getSnapshotSpace()
{
 throw new Exception("Not implemented");
}

auto getFSAndDescendantsSpace(string fs)
{


}

ZfsResult validate(string zpool)
{
 import std.file:exists;
 import std.process:executeShell;
 import std.exception;
 import std.format:format;
 auto result = executeShell("modprobe zfs");
 enforce(result.status==0, "ZFS Kernel module not found");
 return zfsResult(exists(zpool), ZfsError.noent, format!"pool %s not found"(zpool));
}

struct ZfsResult
{
 ZfsError status;
 string message;
}

auto zfsResult(bool success, ZfsError status, string message)
{
 return success ? ZfsResult(ZfsError.success,"") : ZfsResult(status,message);
}


void main(string[] args)
{
 import std.stdio;


 auto testSnap = ["tank3/shared/kaleidic@snapfoo"];
 snapshot(testSnap);
 writeln("success creating");
 destroySnapshots(testSnap,false);
 writeln("success destroying");
}
