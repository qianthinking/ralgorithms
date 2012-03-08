require 'benchmark'
module Sorting
  class TestHelper

    def self.sample_data(size=20, shuffle=true)
      data = (1..size).to_a
      shuffle ? data.shuffle : data
    end

    def self.test(filename, benchmark_data_size=100000)
      data = sample_data
      clazz = eval("Sorting::#{File.basename(filename).split("\.")[0].capitalize}")
      puts "#{clazz} - before sort: #{data.inspect}"
      clazz.sort! data
      puts "#{clazz} - after  sort: #{data.inspect}"

      benchmark_data = sample_data benchmark_data_size, false
      result = Benchmark.measure do
        clazz.sort! benchmark_data
        #10.times {clazz.sort! benchmark_data.dup} #notice, you should dup sample data for multiple test
      end
      puts "cost of sorting #{benchmark_data.size} ordered number"
      puts result

      benchmark_data = sample_data benchmark_data_size
      result = Benchmark.measure do
        clazz.sort! benchmark_data
        #10.times {clazz.sort! benchmark_data.dup} #notice, you should dup sample data for multiple test
      end
      puts "cost of sorting #{benchmark_data.size} random numbers"
      puts result
    end

  end
end
