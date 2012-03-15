require File.join(File.dirname(File.realpath(__FILE__)), "helper")
module Sorting
  class InsertionSort
    extend Helper
    TEST_DATA_SIZE=1000
    BINARY_SEARCH_THRESHOLD=80
    BINARY_SEARCH_TEST_DISTANCE=[5, BINARY_SEARCH_THRESHOLD].min

    def self.sort!(data, l=0, r=data.size-1, start=l+1)
      (start..r).each do |i|
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

    def self.binary_sort!(data, l=0, r=data.size-1, start=l+1)
      (start..r).each do |i|
        value = data[i]
        if (distance = i - l) > BINARY_SEARCH_THRESHOLD  && value < data[i-BINARY_SEARCH_TEST_DISTANCE]
          low = l
          high = i-1
          found = nil
          while low <= high
            mid = low +  (high-low)/2
            if data[mid] < value
              low = mid + 1
            else
              found = mid
              high = mid - 1
            end
          end
          if found
            length = i-found
            data[found+1, length] = data[found,length]
            data[found] = value
          end
        else
          j = i
          while j > l && value < (previous = data[j-1])
            data[j] = previous
            j -= 1
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
