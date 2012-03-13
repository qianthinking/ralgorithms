require File.join(File.dirname(File.realpath(__FILE__)), "helper")
require File.join(File.dirname(File.realpath(__FILE__)), "insertion_sort")
module Sorting
  class LibrarySort
    extend Helper
    TEST_DATA_SIZE=100_000

    GAP = 8

    def self.sort(data)
      sorting_data = Array.new data.size
      steps = build_steps data
      step_counts = {}
      data.each do |e|
        step = binary_big_search steps, e
        step_counts[step] = (step_counts[step] || 0) + 1
      end
      step_locations = {}
      last_location = 0
      last_step_item_count = 0 
      steps.each do |step|
        last_location += last_step_item_count
        step_locations[step] = last_location
        last_step_item_count = step_counts[step]
      end
      data.each do |e|
        step = binary_big_search steps, e
        sorting_data[step_locations[step]] = e
        step_locations[step] += 1
      end
      InsertionSort.sort! sorting_data
      sorting_data
    end

    def self.build_steps(data)
      min, max = data.minmax
      gap = (GAP * (max - min + 1).to_f/data.size).to_i
      steps = []
      step = min - 1
      while step < max
        step += gap
        steps << step
      end
      steps
    end

    def self.binary_big_search(data, item)
      low = 0
      high = data.size - 1
      found = nil
      while low <= high
        mid = low +  (high-low)/2
        value = data[mid]
        if value < item
          low = mid + 1
        else
          found = value
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
