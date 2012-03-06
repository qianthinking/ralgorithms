require 'benchmark'
module Sorting
  class TestHelper

    def self.sample_data(size=20)
      (1..size).to_a.shuffle
    end

    def self.test(filename)
      data = sample_data
      clazz = eval("Sorting::#{File.basename(filename).split("\.")[0].capitalize}")
      puts "#{clazz} - before sort: #{data.inspect}"
      clazz.sort! data
      puts "#{clazz} - after  sort: #{data.inspect}"

      benchmark_data = sample_data 5000
      result = Benchmark.measure do
        clazz.sort! benchmark_data
        #10.times {clazz.sort! benchmark_data.dup}
      end
      puts "cost of sorting 5000 random number"
      puts result
    end

  end
end
