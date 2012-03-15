require File.join(File.dirname(File.realpath(__FILE__)), "helper")
module Sorting
  class ShellSort
    extend Helper
    TEST_DATA_SIZE=100_000
    GAP_FACTOR = 2.35
    GAP_REQUIRED_THRESHOLD = 10

    # Shell sort
    # Comparison sort
    # Insertion
    # Unstable
    # Time complexity: depends on gap sequence, best known is O(n(logn)2)
    # Space complexity: O(1)
    # Simple, fast
    # Empirical gap [1750, 701, 301, 132, 57, 23, 10, 4, 1]
    def self.sort!(data)
      #see http://oeis.org/A102549
      gaps = [1, 4, 10, 23, 57, 132, 301, 701, 1750].reverse
      data_size = data.size
      expect_gap = data_size / GAP_REQUIRED_THRESHOLD
      while expect_gap > gaps.first
        gaps.unshift (gaps.first*GAP_FACTOR).to_i
      end
      gaps.each do |gap|
        (gap...data_size).each do |i|
          value = data[i]
          j = i
          while j >= gap && value < (previous = data[j-gap])
            data[j] = previous
            j -= gap
          end
          data[j] = value
        end
      end
      nil
    end

  end
end

if __FILE__ == $0
  require File.join(File.dirname(File.realpath(__FILE__)), "test_helper")
  Sorting::TestHelper.test __FILE__
end
