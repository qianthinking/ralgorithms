module Sorting
  class Heap

    class << self

      def sort!(data)
        build_max_heap data
        max_i = data.size - 1
        max_i.downto(0).each do |i|
          data[0], data[i] = data[i], data[0]
          maintain_max_heap data, 0, i - 1
        end
      end

      protected

      def build_max_heap(data)
        max_i = data.size - 1
        max_i.parent.downto(0).each do |i|
          maintain_max_heap data, i, max_i
        end
      end

      def maintain_max_heap(data, i, last_i)
        while (child = i.left_child) <= last_i
          if child < last_i #has two children
            child = child.right_sibling if data[child.right_sibling] > data[child]
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

  def parent
    self == 0 ? 0 : (self - 1) / 2
  end

  def left_child
    self*2 + 1
  end

  def right_sibling
    self + 1    
  end

end


if __FILE__ == $0
  require 'test_helper'
  Sorting::TestHelper.test __FILE__
end
