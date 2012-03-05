module Sorting
  class Bubble

    def self.sort(data)
      max_i = data.size - 1
      (0...max_i).each do |i|
        swapped = false
        (0...(max_i-i)).each do |j|
          if data[j] > data[j+1]
            data[j], data[j+1] = data[j+1], data[j] 
            swapped = true
          end
        end
        break if !swapped
      end
      data
    end

  end
end

if __FILE__ == $0
  require 'test_helper'
  Sorting::TestHelper.test __FILE__
end

