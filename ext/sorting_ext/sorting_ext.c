#include "ruby/ruby.h"

#define BINARY_SEARCH_THRESHOLD 300
#define BINARY_SEARCH_TEST_DISTANCE 30

VALUE sortingModule;
VALUE sortingClass;

void
insert_sort_impl(VALUE* base, const size_t len, long start, long l, long r, 
        int (*cmp)(const void*, const void*, void*), void *d)
{
    VALUE obj;
    VALUE previous;
    long i, j;
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
        int (*cmp)(const void*, const void*, void*), void *d)
{
    char *base = (char *)ary;
    size_t size = sizeof(VALUE);
    VALUE obj;
    VALUE previous;
    long i, j, distance, low, high, mid, found, length;
    char *dest;
    char *src;
    if (l == -1) l = 0;
    if (r == -1) r = len - 1;
    if (start == -1) start = l + 1;
    for(i = start; i <=r; i++) {
        obj = ary[i];
        distance = i - l;
        if (distance > BINARY_SEARCH_THRESHOLD
                && (*cmp)(obj, ary[i-BINARY_SEARCH_TEST_DISTANCE], d) < 0) {
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
                //it could be optimized when length small
                dest = base + (found+1)*size;
                src = base + found*size;
                memmove(dest, src, size*length);
                ary[found] = obj;
            }
        } else {
            j = i;
            while (j > l) {
                previous = ary[j-1];
                if((*cmp)(obj, previous, d) < 0) {
                    ary[j] = previous;
                    j--;
                } else break;
            }
            ary[j] = obj;
        }
    }

}

    void
insert_sort_bang(VALUE dummy, VALUE ary)
{
    dynamic_sort(ary, insert_sort_impl);
}

void Init_sorting_ext(void) {
    sortingModule = rb_define_module("Sorting");
    sortingClass = rb_define_class_under(sortingModule, "Insertion", rb_cObject);
    rb_define_singleton_method(sortingClass, "sort!", insert_sort_bang, 1);
    set_id_cmp(rb_intern("<=>"));
}
