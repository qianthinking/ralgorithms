module Sorting
  class Selection

    def self.sort(data)
      max_i = data.size - 1
      (0...max_i).each do |i|
        min_index = i
        ((i+1)..max_i).each do |j|
          min_index = j if data[j] < data[min_index]
        end
        data[i], data[min_index] = data[min_index], data[i]
      end
      data
    end

  end
end

if __FILE__ == $0
  require 'test_helper'
  Sorting::TestHelper.test __FILE__
end
