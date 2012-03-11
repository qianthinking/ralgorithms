module Sorting
  class Library

    EMPTY = 0
    GAP = 9

    def self.sort!(odata, gap = GAP)
      data = Array.new odata.size*(1+gap)
      odata.each_with_index do |e, i|
        data[i + i*gap] = e
      end
      (1...data.size).each do |i|
        value = data[i]
        next unless value
        j = i
        while j > 0
          previous = data[j-1]
          if previous
            break if value >= previous
            data[j] = previous
          end
          j -= 1
        end
        data[j] = value
      end
      nil
    end

  end
end

if __FILE__ == $0
  require File.join(File.dirname(File.realpath(__FILE__)), "test_helper")
  Sorting::TestHelper.test __FILE__, 1000
end
