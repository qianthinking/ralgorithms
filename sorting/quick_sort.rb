require File.join(File.dirname(File.realpath(__FILE__)), "insertion_sort")
require File.join(File.dirname(File.realpath(__FILE__)), "helper")
module Sorting
  class QuickSort
    extend Helper
    TEST_DATA_SIZE=100_000

    def self.sort!(data)
      quicksort(data)
      nil
    end

    def self.quicksort(data, p=0, r=data.size-1)
      size = r - p
      if size > 12
        q = partition(data, p, r)
        quicksort(data, p, q-1)
        quicksort(data, q+1, r)
      elsif size > 0
        Sorting::InsertionSort.sort!(data, p, r)
      end
    end

    def self.partition(data, p, r)
      m = p + (r-p)/2
      pivot_candidates_hash = {data[p] => p, data[m] => m, data[r] => r}
      pivot_candidates = pivot_candidates_hash.keys
      pivot = (pivot_candidates - pivot_candidates.minmax)[0] || pivot_candidates.last
      pivot_index = pivot_candidates_hash[pivot]
      data[pivot_index], data[r] = data[r], pivot if pivot_index != r
      pivot = data[r]
      i = p - 1
      p.upto(r-1) do |j|
        if data[j] <= pivot
          i = i+1
          data[i], data[j] = data[j],data[i]
        end        
      end
      data[i+1],data[r] = data[r],data[i+1]
      return i + 1
    end

  end
end

if __FILE__ == $0
  require File.join(File.dirname(File.realpath(__FILE__)), "test_helper")
  Sorting::TestHelper.test __FILE__
end

