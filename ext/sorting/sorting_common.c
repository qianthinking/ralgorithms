#include "ruby/ruby.h"
#include <assert.h>

const char*
obj_inspect(VALUE obj) {
    VALUE str = rb_funcall(obj, rb_intern("inspect"), 0);
    const char * result = RSTRING_PTR(str);
    return result;
}

void 
print_ruby_obj(const char* prefix, VALUE obj)
{
    const char* str = obj_inspect(obj);
    printf("%s: %s\n", prefix, str);
}

void 
printp_ruby_obj(const char* prefix, void* base)
{
    VALUE obj = *(const VALUE*)base;
    print_ruby_obj(prefix, obj);
}

static ID id_cmp; 
struct ary_sort_data {
    VALUE ary;
    int opt_methods;
    int opt_inited;
};
enum {
    sort_opt_Fixnum,
    sort_opt_String,
    sort_optimizable_count
};

#define STRING_P(s) (TYPE(s) == T_STRING && CLASS_OF(s) == rb_cString)

#define SORT_OPTIMIZABLE_BIT(type) (1U << TOKEN_PASTE(sort_opt_,type))
#define SORT_OPTIMIZABLE(data, type) \
    ((data->opt_inited & SORT_OPTIMIZABLE_BIT(type)) ? \
     (data->opt_methods & SORT_OPTIMIZABLE_BIT(type)) : \
     ((data->opt_inited |= SORT_OPTIMIZABLE_BIT(type)), \
      rb_method_basic_definition_p(TOKEN_PASTE(rb_c,type), id_cmp) && \
      (data->opt_methods |= SORT_OPTIMIZABLE_BIT(type))))

# define ARY_SHARED_P(ary) \
    (assert(!FL_TEST(ary, ELTS_SHARED) || !FL_TEST(ary, RARRAY_EMBED_FLAG)), \
     FL_TEST(ary,ELTS_SHARED)!=0)
# define ARY_EMBED_P(ary) \
    (assert(!FL_TEST(ary, ELTS_SHARED) || !FL_TEST(ary, RARRAY_EMBED_FLAG)), \
     FL_TEST(ary, RARRAY_EMBED_FLAG)!=0)

#define ARY_HEAP_PTR(a) (assert(!ARY_EMBED_P(a)), RARRAY(a)->as.heap.ptr)
#define ARY_HEAP_LEN(a) (assert(!ARY_EMBED_P(a)), RARRAY(a)->as.heap.len)
#define ARY_EMBED_PTR(a) (assert(ARY_EMBED_P(a)), RARRAY(a)->as.ary)
#define ARY_EMBED_LEN(a) \
    (assert(ARY_EMBED_P(a)), \
     (long)((RBASIC(a)->flags >> RARRAY_EMBED_LEN_SHIFT) & \
	 (RARRAY_EMBED_LEN_MASK >> RARRAY_EMBED_LEN_SHIFT)))

#define ARY_OWNS_HEAP_P(a) (!FL_TEST(a, ELTS_SHARED|RARRAY_EMBED_FLAG))
#define FL_SET_EMBED(a) do { \
    assert(!ARY_SHARED_P(a)); \
    assert(!OBJ_FROZEN(a)); \
    FL_SET(a, RARRAY_EMBED_FLAG); \
} while (0)
#define FL_UNSET_EMBED(ary) FL_UNSET(ary, RARRAY_EMBED_FLAG|RARRAY_EMBED_LEN_MASK)
#define FL_SET_SHARED(ary) do { \
    assert(!ARY_EMBED_P(ary)); \
    FL_SET(ary, ELTS_SHARED); \
} while (0)
#define FL_UNSET_SHARED(ary) FL_UNSET(ary, ELTS_SHARED)

#define ARY_SET_PTR(ary, p) do { \
    assert(!ARY_EMBED_P(ary)); \
    assert(!OBJ_FROZEN(ary)); \
    RARRAY(ary)->as.heap.ptr = (p); \
} while (0)
#define ARY_SET_EMBED_LEN(ary, n) do { \
    long tmp_n = n; \
    assert(ARY_EMBED_P(ary)); \
    assert(!OBJ_FROZEN(ary)); \
    RBASIC(ary)->flags &= ~RARRAY_EMBED_LEN_MASK; \
    RBASIC(ary)->flags |= (tmp_n) << RARRAY_EMBED_LEN_SHIFT; \
} while (0)
#define ARY_SET_HEAP_LEN(ary, n) do { \
    assert(!ARY_EMBED_P(ary)); \
    RARRAY(ary)->as.heap.len = n; \
} while (0)
#define ARY_SET_LEN(ary, n) do { \
    if (ARY_EMBED_P(ary)) { \
        ARY_SET_EMBED_LEN(ary, n); \
    } \
    else { \
        ARY_SET_HEAP_LEN(ary, n); \
    } \
    assert(RARRAY_LEN(ary) == n); \
} while (0)
#define ARY_INCREASE_PTR(ary, n) do  { \
    assert(!ARY_EMBED_P(ary)); \
    assert(!OBJ_FROZEN(ary)); \
    RARRAY(ary)->as.heap.ptr += n; \
} while (0)
#define ARY_INCREASE_LEN(ary, n) do  { \
    assert(!OBJ_FROZEN(ary)); \
    if (ARY_EMBED_P(ary)) { \
        ARY_SET_EMBED_LEN(ary, RARRAY_LEN(ary)+n); \
    } \
    else { \
        RARRAY(ary)->as.heap.len += n; \
    } \
} while (0)

#define ARY_CAPA(ary) (ARY_EMBED_P(ary) ? RARRAY_EMBED_LEN_MAX : \
		       ARY_SHARED_ROOT_P(ary) ? RARRAY_LEN(ary) : RARRAY(ary)->as.heap.aux.capa)
#define ARY_SET_CAPA(ary, n) do { \
    assert(!ARY_EMBED_P(ary)); \
    assert(!ARY_SHARED_P(ary)); \
    assert(!OBJ_FROZEN(ary)); \
    RARRAY(ary)->as.heap.aux.capa = (n); \
} while (0)

#define ARY_SHARED(ary) (assert(ARY_SHARED_P(ary)), RARRAY(ary)->as.heap.aux.shared)
#define ARY_SET_SHARED(ary, value) do { \
    assert(!ARY_EMBED_P(ary)); \
    assert(ARY_SHARED_P(ary)); \
    assert(ARY_SHARED_ROOT_P(value)); \
    RARRAY(ary)->as.heap.aux.shared = (value); \
} while (0)
#define RARRAY_SHARED_ROOT_FLAG FL_USER5
#define ARY_SHARED_ROOT_P(ary) (FL_TEST(ary, RARRAY_SHARED_ROOT_FLAG))
#define ARY_SHARED_NUM(ary) \
    (assert(ARY_SHARED_ROOT_P(ary)), RARRAY(ary)->as.heap.aux.capa)
#define ARY_SET_SHARED_NUM(ary, value) do { \
    assert(ARY_SHARED_ROOT_P(ary)); \
    RARRAY(ary)->as.heap.aux.capa = (value); \
} while (0)
#define FL_SET_SHARED_ROOT(ary) do { \
    assert(!ARY_EMBED_P(ary)); \
    FL_SET(ary, RARRAY_SHARED_ROOT_FLAG); \
} while (0)

static VALUE
rb_ary_increment_share(VALUE shared)
{
    long num = ARY_SHARED_NUM(shared);
    if (num >= 0) {
	ARY_SET_SHARED_NUM(shared, num + 1);
    }
    return shared;
}

static void
rb_ary_decrement_share(VALUE shared)
{
    if (shared) {
	long num = ARY_SHARED_NUM(shared) - 1;
	if (num == 0) {
	    rb_ary_free(shared);
	    rb_gc_force_recycle(shared);
	}
	else if (num > 0) {
	    ARY_SET_SHARED_NUM(shared, num);
	}
    }
}

static void
rb_ary_unshare(VALUE ary)
{
    VALUE shared = RARRAY(ary)->as.heap.aux.shared;
    rb_ary_decrement_share(shared);
    FL_UNSET_SHARED(ary);
}

static VALUE
ary_make_shared(VALUE ary)
{
    assert(!ARY_EMBED_P(ary));
    if (ARY_SHARED_P(ary)) {
	return ARY_SHARED(ary);
    }
    else if (ARY_SHARED_ROOT_P(ary)) {
	return ary;
    }
    else if (OBJ_FROZEN(ary)) {
	ary_resize_capa(ary, ARY_HEAP_LEN(ary));
	FL_SET_SHARED_ROOT(ary);
	ARY_SET_SHARED_NUM(ary, 1);
	return ary;
    }
    else {
	NEWOBJ(shared, struct RArray);
	OBJSETUP(shared, 0, T_ARRAY);
        FL_UNSET_EMBED(shared);

        ARY_SET_LEN((VALUE)shared, RARRAY_LEN(ary));
        ARY_SET_PTR((VALUE)shared, RARRAY_PTR(ary));
	FL_SET_SHARED_ROOT(shared);
	ARY_SET_SHARED_NUM((VALUE)shared, 1);
	FL_SET_SHARED(ary);
	ARY_SET_SHARED(ary, (VALUE)shared);
	OBJ_FREEZE(shared);
	return (VALUE)shared;
    }
}
static VALUE
ary_make_substitution(VALUE ary)
{
    if (RARRAY_LEN(ary) <= RARRAY_EMBED_LEN_MAX) {
        VALUE subst = rb_ary_new2(RARRAY_LEN(ary));
        MEMCPY(ARY_EMBED_PTR(subst), RARRAY_PTR(ary), VALUE, RARRAY_LEN(ary));
        ARY_SET_EMBED_LEN(subst, RARRAY_LEN(ary));
        return subst;
    }
    else {
        return rb_ary_increment_share(ary_make_shared(ary));
    }
}

static VALUE
sort_reentered(VALUE ary)
{
    if (RBASIC(ary)->klass) {
	rb_raise(rb_eRuntimeError, "sort reentered");
    }
    return Qnil;
}

static inline void
rb_ary_modify_check(VALUE ary)
{
    if (OBJ_FROZEN(ary)) rb_error_frozen("array");
    if (!OBJ_UNTRUSTED(ary) && rb_safe_level() >= 4)
	rb_raise(rb_eSecurityError, "Insecure: can't modify array");
}
static void
rb_ary_modify(VALUE ary)
{
    rb_ary_modify_check(ary);
    if (ARY_SHARED_P(ary)) {
        long len = RARRAY_LEN(ary);
        if (len <= RARRAY_EMBED_LEN_MAX) {
            VALUE *ptr = ARY_HEAP_PTR(ary);
            VALUE shared = ARY_SHARED(ary);
            FL_UNSET_SHARED(ary);
            FL_SET_EMBED(ary);
            MEMCPY(ARY_EMBED_PTR(ary), ptr, VALUE, len);
            rb_ary_decrement_share(shared);
            ARY_SET_EMBED_LEN(ary, len);
        }
        else {
            VALUE *ptr = ALLOC_N(VALUE, len);
            MEMCPY(ptr, RARRAY_PTR(ary), VALUE, len);
            rb_ary_unshare(ary);
            ARY_SET_CAPA(ary, len);
            ARY_SET_PTR(ary, ptr);
        }
    }
}

static int
sort_1(const void *ap, const void *bp, void *dummy)
{
    struct ary_sort_data *data = dummy;
    VALUE retval = sort_reentered(data->ary);
    VALUE a = *(const VALUE *)ap, b = *(const VALUE *)bp;
    int n;

    retval = rb_yield_values(2, a, b);
    n = rb_cmpint(retval, a, b);
    sort_reentered(data->ary);
    return n;
}

static int
sort_2(const void *ap, const void *bp, void *dummy)
{
    struct ary_sort_data *data = dummy;
    VALUE retval = sort_reentered(data->ary);
    VALUE a = *(const VALUE *)ap, b = *(const VALUE *)bp;
    int n;

    if (FIXNUM_P(a) && FIXNUM_P(b) && SORT_OPTIMIZABLE(data, Fixnum)) {
	if ((long)a > (long)b) return 1;
	if ((long)a < (long)b) return -1;
	return 0;
    }
    if (STRING_P(a) && STRING_P(b) && SORT_OPTIMIZABLE(data, String)) {
	return rb_str_cmp(a, b);
    }

    retval = rb_funcall(a, id_cmp, 1, b);
    n = rb_cmpint(retval, a, b);
    sort_reentered(data->ary);

    return n;
}

static int
sort_3(VALUE a, VALUE b, void *dummy)
{
    struct ary_sort_data *data = dummy;
    VALUE retval = sort_reentered(data->ary);
    int n;

    retval = rb_yield_values(2, a, b);
    n = rb_cmpint(retval, a, b);
    sort_reentered(data->ary);
    return n;
}

static int
sort_4(VALUE a, VALUE b, void *dummy)
{
    struct ary_sort_data *data = dummy;
    VALUE retval = sort_reentered(data->ary);
    int n;

    if (FIXNUM_P(a) && FIXNUM_P(b) && SORT_OPTIMIZABLE(data, Fixnum)) {
	if ((long)a > (long)b) return 1;
	if ((long)a < (long)b) return -1;
	return 0;
    }
    if (STRING_P(a) && STRING_P(b) && SORT_OPTIMIZABLE(data, String)) {
	return rb_str_cmp(a, b);
    }

    retval = rb_funcall(a, id_cmp, 1, b);
    n = rb_cmpint(retval, a, b);
    sort_reentered(data->ary);

    return n;
}

void
set_id_cmp(ID id)
{
    id_cmp = id;
}

VALUE
dynamic_sort(VALUE ary, void(*sort_handler)(void*, const size_t, long, long, long, int(*)(const void*, const void*, void*), void*), long start, long l, long r)
{
    rb_ary_modify(ary);
    assert(!ARY_SHARED_P(ary));
    if (RARRAY_LEN(ary) > 1) {
	VALUE tmp = ary_make_substitution(ary); /* only ary refers tmp */
	struct ary_sort_data data;

	RBASIC(tmp)->klass = 0;
	data.ary = tmp;
	data.opt_methods = 0;
	data.opt_inited = 0;
	sort_handler(RARRAY_PTR(tmp), RARRAY_LEN(tmp), start, l, r, 
		   rb_block_given_p()?sort_3:sort_4, &data);

        if (ARY_EMBED_P(tmp)) {
            assert(ARY_EMBED_P(tmp));
            if (ARY_SHARED_P(ary)) { /* ary might be destructively operated in the given block */
                rb_ary_unshare(ary);
            }
            FL_SET_EMBED(ary);
            MEMCPY(RARRAY_PTR(ary), ARY_EMBED_PTR(tmp), VALUE, ARY_EMBED_LEN(tmp));
            ARY_SET_LEN(ary, ARY_EMBED_LEN(tmp));
        }
        else {
            assert(!ARY_EMBED_P(tmp));
            if (ARY_HEAP_PTR(ary) == ARY_HEAP_PTR(tmp)) {
                assert(!ARY_EMBED_P(ary));
                FL_UNSET_SHARED(ary);
                ARY_SET_CAPA(ary, ARY_CAPA(tmp));
            }
            else {
                assert(!ARY_SHARED_P(tmp));
                if (ARY_EMBED_P(ary)) {
                    FL_UNSET_EMBED(ary);
                }
                else if (ARY_SHARED_P(ary)) {
                    /* ary might be destructively operated in the given block */
                    rb_ary_unshare(ary);
                }
                else {
                    xfree(ARY_HEAP_PTR(ary));
                }
                ARY_SET_PTR(ary, RARRAY_PTR(tmp));
                ARY_SET_HEAP_LEN(ary, RARRAY_LEN(tmp));
                ARY_SET_CAPA(ary, ARY_CAPA(tmp));
            }
            /* tmp was lost ownership for the ptr */
            FL_UNSET(tmp, FL_FREEZE);
            FL_SET_EMBED(tmp);
            ARY_SET_EMBED_LEN(tmp, 0);
            FL_SET(tmp, FL_FREEZE);
	}
        /* tmp will be GC'ed. */
        RBASIC(tmp)->klass = rb_cArray;
    }
    return ary;
}
