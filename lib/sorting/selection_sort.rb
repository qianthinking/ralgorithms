require File.join(File.dirname(File.realpath(__FILE__)), "helper")
module Sorting
  class SelectionSort
    extend Helper
    TEST_DATA_SIZE=1000

    # Selection sort
    # Comparison sort
    # Selection
    # Unstable
    # Time complexity: Ω(n2), Ө(n2), O(n2)
    # Space complexity: O(n) total, O(1) auxiliary
    # Suitable for small arrays (10-20) or write heavy situation
    # Family: Heap sort, Smooth sort
    def self.sort!(data)
      max_i = data.size - 1
      (0...max_i).each do |i|
        min_index = i
        ((i+1)..max_i).each do |j|
          min_index = j if data[j] < data[min_index]
        end
        data[i], data[min_index] = data[min_index], data[i]
      end
      nil
    end

  end
end

if __FILE__ == $0
  require File.join(File.dirname(File.realpath(__FILE__)), "test_helper")
  Sorting::TestHelper.test __FILE__
end
