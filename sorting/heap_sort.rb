require File.join(File.dirname(File.realpath(__FILE__)), "helper")
module Sorting
  class HeapSort
    extend Helper
    TEST_DATA_SIZE=100_000

    class << self

      # Heap sort
      # Comparison sort
      # Selection
      # Unstable
      # Time complexity: Ω(nlogn), Ө(nlogn), O(nlogn)
      # Space complexity: O(n) total, O(1) auxiliary
      # Strongly random access, poor locality of reference
      def sort!(data, l=0, r=data.size-1)
        build_max_heap data
        r.downto(l).each do |i|
          data[l], data[i] = data[i], data[l]
          rebalance_max_heap data, l, l, i - 1
        end
        nil
      end

      protected

      def build_max_heap(data, l=0, r=data.size-1)
        get_parent(l, r).downto(l).each do |i|
          rebalance_max_heap data, l, i, r
        end
      end

      def rebalance_max_heap(data, start, i, last_i)
        while (child = get_left_child(start, i)) <= last_i
          if child < last_i #has two children
            right_sibling = child + 1
            child = right_sibling if data[right_sibling] > data[child]
          end
          if data[i] > data[child]
            break
          else
            data[i], data[child] = data[child], data[i]
            i = child
          end
        end
      end

      def get_parent(start, i)
        i == start ? start : (i - start) / 2
      end

      def get_left_child(start, i)
        (i-start)*2 + 1
      end

    end

  end
end


if __FILE__ == $0
  require File.join(File.dirname(File.realpath(__FILE__)), "test_helper")
  Sorting::TestHelper.test __FILE__
end
