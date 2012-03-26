#include "ruby/ruby.h"

VALUE sortingModule;
VALUE sortingClass;

void
insert_sort_impl(VALUE* base, const size_t len, long start, long l, long r, 
        register int (*cmp)(const void*, const void*, void*), void *d)
{
    VALUE obj;
    VALUE previous;
    register size_t i, j;
    if (l == -1) l = 0;
    if (r == -1) r = len - 1;
    if (start == -1) start = l + 1;
    for(i = start; i <=r; i++) {
        obj = base[i];
        j = i;
        while (j > l) {
            previous = base[j-1];
            if((*cmp)(obj, previous, d) < 0) {
                base[j] = previous;
                j--;
            } else break;
        }
        base[j] = obj;
    }

}

void
binary_insert_sort_impl(VALUE* ary, const size_t len, long start, long l, long r, 
        register int (*cmp)(const void*, const void*, void*), void *d)
{
    char *base = (char *)ary;
    size_t size = sizeof(VALUE);
    VALUE obj;
    VALUE previous;
    register size_t i, j;
    long low, high, mid, found, length;
    char *dest;
    char *src;
    if (l == -1) l = 0;
    if (r == -1) r = len - 1;
    if (start == -1) start = l + 1;
    for(i = start; i <=r; i++) {
        obj = ary[i];
        low = l;
        high = i - 1;
        found = -1;
        while (low <= high) {
            mid = low + (high-low)/2;
            if ((*cmp)(obj, ary[mid], d) > 0) {
                low = mid + 1;
            } else {
                found = mid;
                high = mid - 1;
            }
        }
        if(found != -1) {
            length = i - found;
            if (length == 1) {
                ary[i] = ary[found];
            } else {
                dest = base + (found+1)*size;
                src = base + found*size;
                memmove(dest, src, size*length);
            }
            ary[found] = obj;
        }
    }

}

void
insert_sort_bang(int argc, VALUE *argv, VALUE dummy)
{
    VALUE ary = Qnil;
    VALUE rb_start = Qnil;
    VALUE rb_l = Qnil;
    VALUE rb_r = Qnil;
    long start = -1, l = -1, r = -1;
    rb_scan_args(argc, argv, "13", &ary, &rb_l, &rb_r, &rb_start);
    if (!NIL_P(rb_start)) start = NUM2LONG(rb_start);
    if (!NIL_P(rb_l)) l = NUM2LONG(rb_l);
    if (!NIL_P(rb_r)) r = NUM2LONG(rb_r);
    dynamic_sort(ary, insert_sort_impl, start, l, r);
}

void
binary_insert_sort_bang(int argc, VALUE *argv, VALUE dummy)
{
    VALUE ary = Qnil;
    VALUE rb_start = Qnil;
    VALUE rb_l = Qnil;
    VALUE rb_r = Qnil;
    long start = -1, l = -1, r = -1;
    rb_scan_args(argc, argv, "13", &ary, &rb_l, &rb_r, &rb_start);
    if (!NIL_P(rb_start)) start = NUM2LONG(rb_start);
    if (!NIL_P(rb_l)) l = NUM2LONG(rb_l);
    if (!NIL_P(rb_r)) r = NUM2LONG(rb_r);
    dynamic_sort(ary, binary_insert_sort_impl, start, l, r);
}

void Init_sorting_ext(void) {
    sortingModule = rb_define_module("Sorting");
    sortingClass = rb_define_class_under(sortingModule, "InsertionSort", rb_cObject);
    rb_define_singleton_method(sortingClass, "sort!", insert_sort_bang, -1);
    rb_define_singleton_method(sortingClass, "binary_sort!", binary_insert_sort_bang, -1);
    rb_define_const(sortingClass, "IS_EXT", Qtrue);
    set_id_cmp(rb_intern("<=>"));
}
