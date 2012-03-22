#include "ruby/ruby.h"

VALUE sortingModule;
VALUE sortingClass;

void
insert_sort_impl(VALUE* base, const size_t len, long start, long l, long r, 
	   int (*cmp)(const void*, const void*, void*), void *d)
{
    VALUE obj;
    VALUE previous;
    unsigned int i, j;
    if (l == -1) l = 0;
    if (r == -1) r = len - 1;
    if (start == -1) start = l + 1;
    for(i = start; i <=r; i++) {
        obj = base[i];
        j = i;
        while (j > l)
        {
            previous = base[j-1];
            if((*cmp)(obj, previous, d) < 0)
            {
                base[j] = previous;
                j--;
            } else break;
        }
        base[j] = obj;
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
