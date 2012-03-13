require File.join(File.dirname(File.realpath(__FILE__)), "insertion_sort")
require File.join(File.dirname(File.realpath(__FILE__)), "helper")
module Sorting
  class MergeSort
    extend Helper
    TEST_DATA_SIZE=100_000
    SIZE_FOR_INSERTION=15

    def self.sort(data)
      if data.size < SIZE_FOR_INSERTION
        Sorting::InsertionSort.sort!(data) 
        return data
      end
      mid   = data.size / 2
      left  = data[0...mid]
      right = data[mid...data.size]
      merge(sort(left), sort(right))
    end

    def self.merge(left, right)
      if left.empty? || right.empty?
        return left.empty? ? right : left
      end
      left_size = left.size
      right_size = right.size
      sorted = []
      left_i = right_i = 0
      while true
        if (left_value = left[left_i]) > (right_value = right[right_i])
          value = right_value
          right_i += 1
        else
          value = left_value
          left_i += 1
        end
        sorted << value
        if left_i == left_size
          sorted += right[right_i..-1]
          break
        elsif right_i == right_size
          sorted += left[left_i..-1]
          break
        end
      end
      sorted
    end
    
    #def self.merge(left, right)
    #  sorted = []
    #  until left.empty? or right.empty?
    #    left.first <= right.first ? sorted << left.shift : sorted << right.shift
    #  end
    #  sorted + left + right
    #end


  end
end

if __FILE__ == $0
  require File.join(File.dirname(File.realpath(__FILE__)), "test_helper")
  Sorting::TestHelper.test __FILE__
end
