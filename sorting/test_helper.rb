require 'benchmark'
module Sorting
  class TestHelper

    def self.get_sample_data(size=10, shuffle=true)
      data = (1..size).to_a
      shuffle ? data.shuffle : data
    end

    def self.test(filename, benchmark_data_size=100000)
      data = get_sample_data
      clazz = eval("Sorting::#{File.basename(filename).split("\.")[0].capitalize}")
      puts "#{clazz} - before sort: #{data.inspect}"
      clazz.sort! data
      puts "#{clazz} - after  sort: #{data.inspect}"

      sample_data = get_sample_data benchmark_data_size, false
      benchmark_data = sample_data.dup
      result = Benchmark.measure do
        clazz.sort! benchmark_data
        #10.times {clazz.sort! benchmark_data.dup} #notice, you should dup sample data for multiple test
      end
      diff = diff(benchmark_data, sample_data.sort)
      raise "sort wrong for #{sample_data.inspect}, diff: #{diff.inspect}" unless diff.empty?
      puts "cost of sorting #{sample_data.size} ordered number"
      puts result

      sample_data = get_sample_data benchmark_data_size
      benchmark_data = sample_data.dup
      result = Benchmark.measure do
        clazz.sort! benchmark_data
        #10.times {clazz.sort! benchmark_data.dup} #notice, you should dup sample data for multiple test
      end
      diff = diff(benchmark_data, sample_data.sort)
      raise "sort wrong for #{sample_data.inspect}, diff: #{diff.inspect}" unless diff.empty?
      puts "cost of sorting #{sample_data.size} random numbers"
      puts result
    end

    def self.diff(a, b)
      diff = {}
      a.each_with_index do |x, i|
        y = b[i]
        diff[i] = [x, y] if x != y
      end
      diff
    end

  end
end
