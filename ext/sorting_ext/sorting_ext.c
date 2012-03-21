#include "ruby/ruby.h"

VALUE sortingModule;
VALUE sortingClass;

void
insert_sort_impl(VALUE* base, const size_t nel, const size_t size,
	   int (*cmp)(const void*, const void*, void*), void *d)
{
    VALUE obj;
    VALUE previous;
    unsigned int i, j;
    for(i = 1; i <nel; i++) {
        obj = base[i];
        j = i;
        while (j > 0)
        {
            previous = base[j-1];
            int r = (*cmp)(obj, previous, d);
            if(r < 0)
            {
                base[j] = previous;
                j--;
            } else break;
        }
        base[j] = obj;
    }

}

VALUE
insert_sort_bang(VALUE dummy, VALUE ary)
{
    return dynamic_sort(ary, insert_sort_impl);
}

void Init_sorting_ext(void) {
    sortingModule = rb_define_module("Sorting");
    sortingClass = rb_define_class_under(sortingModule, "Insertion", rb_cObject);
    rb_define_singleton_method(sortingClass, "sort!", insert_sort_bang, 1);
    set_id_cmp(rb_intern("<=>"));
}
