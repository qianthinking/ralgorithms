require File.join(File.dirname(File.realpath(__FILE__)), "helper")
module Sorting
  class Heap
    extend Helper

    class << self

      def sort!(data)
        build_max_heap data
        max_i = data.size - 1
        max_i.downto(0).each do |i|
          data[0], data[i] = data[i], data[0]
          rebalance_max_heap data, 0, i - 1
        end
        nil
      end

      protected

      def build_max_heap(data)
        max_i = data.size - 1
        max_i.heap_parent.downto(0).each do |i|
          rebalance_max_heap data, i, max_i
        end
      end

      def rebalance_max_heap(data, i, last_i)
        while (child = i.heap_left_child) <= last_i
          if child < last_i #has two children
            child = child.heap_right_sibling if data[child.heap_right_sibling] > data[child]
          end
          if data[i] > data[child]
            break
          else
            data[i], data[child] = data[child], data[i]
            i = child
          end
        end
      end

    end

  end
end

#used for clean code, you need consider the side effect to your project
class Fixnum

  def heap_parent
    self == 0 ? 0 : (self - 1) / 2
  end

  def heap_left_child
    self*2 + 1
  end

  def heap_right_sibling
    self + 1    
  end

end


if __FILE__ == $0
  require File.join(File.dirname(File.realpath(__FILE__)), "test_helper")
  Sorting::TestHelper.test __FILE__, 100_000
end
