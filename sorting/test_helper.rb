require 'benchmark'
module Sorting
  class TestHelper

    def self.get_sample_data(size=10, shuffle=true)
      data = (1..size).to_a
      shuffle ? data.shuffle : data
    end

    def self.sort(clazz, data)
      if clazz.respond_to? :sort!
        clazz.sort! data
      else
        data = clazz.sort data
      end
      data
    end

    def self.test(filename, benchmark_data_size=nil)
      data = get_sample_data
      clazz = eval("Sorting::#{File.basename(filename).split("_")[0].capitalize}Sort")
      benchmark_data_size ||= clazz::TEST_DATA_SIZE
      return if benchmark_data_size.nil?
      puts "#{clazz} - before sort: #{data.inspect}"
      data = sort(clazz, data)
      puts "#{clazz} - after  sort: #{data.inspect}"

      sample_data = get_sample_data benchmark_data_size, false
      benchmark_data = sample_data.dup
      result = Benchmark.measure do
        benchmark_data = sort(clazz, benchmark_data)
        #10.times {sort(clazz, benchmark_data.dup)} #notice, you should dup sample data for multiple test
      end
      diff = diff(benchmark_data, sample_data.sort)
      raise "sort wrong for #{sample_data.inspect}, diff: #{diff.inspect}" unless diff.empty?
      puts "#{sample_data.size} ordered number cost"
      puts result

      sample_data = get_sample_data benchmark_data_size
      benchmark_data = sample_data.dup
      result = Benchmark.measure do
        benchmark_data = sort(clazz, benchmark_data)
        #10.times {sort(clazz, benchmark_data.dup)} #notice, you should dup sample data for multiple test
      end
      diff = diff(benchmark_data, sample_data.sort)
      raise "sort wrong for #{sample_data.inspect}, diff: #{diff.inspect}" unless diff.empty?
      puts "#{sample_data.size} ordered number cost"
      puts result
    end

    def self.test_original_sort(benchmark_data_size=nil)
      benchmark_data_size ||= 100_000
      sample_data = get_sample_data benchmark_data_size, false
      benchmark_data = sample_data.dup
      result = Benchmark.measure do
        benchmark_data.sort!
      end
      puts "#{sample_data.size} ordered number cost"
      puts result

      sample_data = get_sample_data benchmark_data_size
      benchmark_data = sample_data.dup
      result = Benchmark.measure do
        benchmark_data.sort!
      end
      puts "#{sample_data.size} ordered number cost"
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
if __FILE__ == $0
  Sorting::TestHelper.test_original_sort 100_000
  dir = File.dirname(File.realpath(__FILE__))
  Dir.foreach(dir).grep /sort/ do |file|
    require File.join(dir, file)
    Sorting::TestHelper.test file
    puts "\n"
  end
end
