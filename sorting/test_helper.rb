module Sorting
  class TestHelper

    def self.sample_data(size=20)
      (1..size).to_a.shuffle
    end

    def self.test(filename)
      data = sample_data
      clazz = eval("Sorting::#{filename.split("\.")[0].capitalize}")
      puts "#{clazz} - before sort: #{data.inspect}"
      data = clazz.sort data
      puts "#{clazz} - after  sort: #{data.inspect}"
    end

  end
end
