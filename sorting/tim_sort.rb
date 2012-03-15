# http://svn.python.org/projects/python/trunk/Objects/listsort.txt
# http://svn.python.org/projects/python/trunk/Objects/listobject.c
# http://cr.openjdk.java.net/~martin/webrevs/openjdk7/timsort/src/share/classes/java/util/TimSort.java.html
require File.join(File.dirname(File.realpath(__FILE__)), "insertion_sort")
require File.join(File.dirname(File.realpath(__FILE__)), "helper")
module Sorting
  class TimSort
    extend Helper
    TEST_DATA_SIZE=nil

    def self.sort!(data, l=0, r=data.size-1)
      nil
    end

  end
end

if __FILE__ == $0
  require File.join(File.dirname(File.realpath(__FILE__)), "test_helper")
  Sorting::TestHelper.test __FILE__
end
