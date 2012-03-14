require File.join(File.dirname(File.realpath(__FILE__)), "helper")
module Sorting
  class InsertionSort
    extend Helper
    TEST_DATA_SIZE=1000
    BINARY_SEARCH_THRESHOLD=100

    def self.sort!(data, l=0, r=data.size-1)
      ((l+1)..r).each do |i|
        value = data[i]
        j = i
        while j > l && value < (previous = data[j-1])
          data[j] = previous
          j -= 1
        end
        data[j] = value
      end
      nil
    end

    def self.sort2!(data, l=0, r=data.size-1)
      ((l+1)..r).each do |i|
        value = data[i]
        j = i
        if i-l > BINARY_SEARCH_THRESHOLD
          found = binary_search_first_bigger_index data, l, i-1, value
          if found
            while j > found
              previous = data[j-1]
              data[j] = previous
              j -= 1
            end
          end
        else
          while j > l && value < (previous = data[j-1])
            data[j] = previous
            j -= 1
          end
        end
        data[j] = value
      end
      nil
    end

    def self.binary_search_first_bigger_index(data, low, high, item)
      found = nil
      while low <= high
        mid = low +  (high-low)/2
        value = data[mid]
        if value < item
          low = mid + 1
        else
          found = mid
          high = mid - 1
        end
      end
      found
    end

  end
end

if __FILE__ == $0
  require File.join(File.dirname(File.realpath(__FILE__)), "test_helper")
  Sorting::TestHelper.test __FILE__
end
