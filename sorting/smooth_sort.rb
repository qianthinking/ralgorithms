#http://www.keithschwarz.com/smoothsort/
#http://www.keithschwarz.com/interesting/code/?dir=smoothsort
require File.join(File.dirname(File.realpath(__FILE__)), "helper")
module Sorting
  class SmoothSort
    extend Helper
    TEST_DATA_SIZE=100_000
    LEONARDO_NUMBERS = [
      1, 1, 3, 5, 9, 15, 25, 41, 67, 109, 177, 287, 465, 753, 
      1219, 1973, 3193, 5167, 8361, 13529, 21891, 35421, 57313, 92735,
      150049, 242785, 392835, 635621, 1028457, 1664079, 2692537, 
      4356617, 7049155, 11405773, 18454929, 29860703, 48315633, 78176337,
      126491971, 204668309, 331160281, 535828591, 866988873, 1402817465,
      2269806339, 3672623805
    ]
    LEONARDO_MAPPING = Hash[LEONARDO_NUMBERS.each_with_index.to_a]
    LAST_ZERO = 2**32 - 2

    class HeapHelper
      attr_accessor :bit_trees
      attr_accessor :smallest_heap_size
      def initialize
        @bit_trees = 0
        @smallest_heap_size = 0
      end
    end

    class << self

      def sort!(data)
        max_i = data.size - 1
        helper = HeapHelper.new
        build_leonardo_heap data, max_i, helper
        max_i.downto(1) do |i|
          leonardo_heap_remove(data, i, helper)
        end
        nil
      end

      def build_leonardo_heap(data, last_i, helper)
        (0..last_i).each do |i|
          if helper.bit_trees == 0 #init
            helper.smallest_heap_size = 1
            helper.bit_trees = 1
          elsif helper.bit_trees & 0b11 == 0b11 #The last two trees have adjacent order
            helper.bit_trees >>= 2
            helper.smallest_heap_size += 2
            helper.bit_trees |= 1
          elsif helper.smallest_heap_size == 1
            helper.bit_trees <<= 1
            helper.smallest_heap_size = 0
            helper.bit_trees |= 1
          else
            helper.bit_trees <<= (helper.smallest_heap_size - 1)
            helper.smallest_heap_size = 1
            helper.bit_trees |= 1
          end
          is_last = case helper.smallest_heap_size
                    when 0
                      i == last_i
                    when 1
                      (i == last_i) || (i + 1 == last_i && helper.bit_trees & 0b10 == 0)
                    else
                      last_i - i < LEONARDO_NUMBERS[helper.smallest_heap_size-1] + 1
                    end
          if is_last
            rectify_heaps data, i, helper.dup
          else
            rebalance_single_heap data, i, helper.smallest_heap_size
          end 
        end
      end

      def leonardo_heap_remove(data, i, helper)
        if helper.smallest_heap_size <= 1
          begin
            helper.bit_trees >>= 1
            helper.smallest_heap_size += 1
          end while helper.bit_trees > 0 && helper.bit_trees & 1 == 0
          return
        end
        heap_size = helper.smallest_heap_size
        helper.bit_trees &= LAST_ZERO
        helper.bit_trees <<= 2
        helper.bit_trees |= 0b11
        helper.smallest_heap_size -= 2
        left_child = left_child(i, heap_size)
        right_child = right_child(i)

        all_but_last_helper = helper.dup
        all_but_last_helper.smallest_heap_size += 1
        all_but_last_helper.bit_trees >>= 1
        rectify_heaps data, left_child, all_but_last_helper
        rectify_heaps data, right_child, helper.dup
      end

      def rebalance_single_heap(data, root, size)
        while size > 1
          left_child = left_child root, size
          right_child = right_child root
          larger_child = nil
          child_size = nil
          if data[left_child] > data[right_child]
            larger_child = left_child
            child_size = size - 1
          else
            larger_child = right_child
            child_size = size - 2
          end
          if data[root] < data[larger_child]
            data[root], data[larger_child] = data[larger_child], data[root]
            root = larger_child
            size = child_size
          else
            break
          end
        end
      end

      def rectify_heaps(data, i, helper)
        j = i
        while true
          last_heap_size = helper.smallest_heap_size
          break if j == LEONARDO_NUMBERS[last_heap_size] - 1
          to_compare = j
          if last_heap_size > 1
            larger_child = larger_child(data, j, last_heap_size)
            to_compare = larger_child if data[larger_child] > to_compare
          end
          prior_heap =  j - LEONARDO_NUMBERS[last_heap_size]
          break if data[to_compare] > data[prior_heap]
          data[prior_heap], data[j] = data[j], data[prior_heap] if data[j] < data[prior_heap]
          j = prior_heap
          begin
            helper.bit_trees >>= 1
            helper.smallest_heap_size += 1
          end while helper.bit_trees & 1 == 0
        end
        rebalance_single_heap data, j, last_heap_size
      end

      def left_child(root, size)
        right_child(root) - LEONARDO_NUMBERS[size-2]
      end

      def right_child(root)
        root - 1
      end

      def larger_child(data, root, size)
        left_child = left_child(root, size)
        right_child = right_child(root)
        data[left_child] > data[right_child] ? left_child : right_child
      end

    end

  end
end

if __FILE__ == $0
  require File.join(File.dirname(File.realpath(__FILE__)), "test_helper")
  Sorting::TestHelper.test __FILE__
end
