require File.join(File.dirname(File.realpath(__FILE__)), "heap_sort")
require File.join(File.dirname(File.realpath(__FILE__)), "helper")
module Sorting
  class IntroSort
    extend Helper
    TEST_DATA_SIZE=100_000

    def self.sort!(data)
      introsort(data)
      nil
    end

    def self.introsort(data, l=0, r=data.size-1, depth_limit=2*Math.log((r-l), 2).to_i)
      while (distance = (r - l)) > 0
        if depth_limit == 0
          Sorting::HeapSort.sort! data, l, r
        else
          depth_limit -= 1
          q = partition(data, l, r)
          introsort(data, q+1, r, depth_limit)
          r = q - 1
        end
      end
    end

    def self.partition(data, p, r)
      median_of_3 data, p, r
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

    def self.median_of_3(data, p, r)
      m = p + (r-p)/2
      pivot_candidates_hash = {data[p] => p, data[m] => m, data[r] => r}
      pivot_candidates = pivot_candidates_hash.keys
      pivot = (pivot_candidates - pivot_candidates.minmax)[0] || pivot_candidates.last
      pivot_index = pivot_candidates_hash[pivot]
      data[pivot_index], data[r] = data[r], pivot if pivot_index != r
    end

  end
end

if __FILE__ == $0
  require File.join(File.dirname(File.realpath(__FILE__)), "test_helper")
  Sorting::TestHelper.test __FILE__
end

