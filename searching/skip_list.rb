module Searching
  class SkipList

    class Node
      attr_accessor :key
      attr_accessor :value
      attr_reader :forward
      def initialize(max_level, key, value)
        self.key = key
        self.value = value
        @forward = Array.new max_level
        @forward.map!{|e| NIL_NODE}
      end
    end

    class NilKey
      def <(*args)
        false
      end
    end

    DEFAULT_MAX_LEVEL = 32
    DEFAULT_PROBABILITY = 0.5
    NIL_NODE = Node.new 0, NilKey.new, nil
    attr_reader :size
    attr_reader :current_level

    def initialize(max_level=DEFAULT_MAX_LEVEL, probability=DEFAULT_PROBABILITY)
      @max_level = max_level - 1
      @probability = probability
      @current_level = 0
      @header = Node.new @max_level, nil, nil
      @size = 0
    end

    def <<(value)
      self[value] = value
    end

    def [](key)
      element = find key
      element.key == key ? element.value : nil
    end

    def []=(key, value)
      update = []
      element = find key, update
      if element.key == key
        element.value = value 
      else
        target_level = random_level
        if target_level > @current_level
          ((@current_level+1)..target_level).each do |level|
            update[level] = @header
          end
          @current_level = target_level
        end
        target_element = Node.new @max_level, key, value
        (0..target_level).each do |level|
          target_element.forward[level] = update[level].forward[level]
          update[level].forward[level] = target_element
        end
        @size += 1
      end
    end

    def delete(key)
      update = []
      element = find key, update
      if element.key == key
        (1..@current_level).each do |level|
          update[level].forward[level] = element.forward[level] if update[level].forward[level] == element
          @current_level -= 1 if @header.forward[level] == NIL_NODE
        end
        @size -= 1
      end
    end

    def to_s
      str = ""
      @current_level.downto(0).each do |level|
        str << "(#{level}): #{to_a(level).inspect}"
      end
      str
    end

    def to_a(level=0)
      element = @header
      result = []
      while (forward = element.forward[level]) != NIL_NODE
        element = forward
        result << [element.key, element.value]
      end
      result
    end

    protected
    def random_level
      [(Math.log(1-rand)/Math.log(@probability)).to_i, @max_level].min
    end

    def find(key, update=nil)
      element = @header
      @current_level.downto(0).each do |level|
        while (forward = element.forward[level]).key < key
          element = forward
        end
        update[level] = element if update
      end
      element.forward[0]
    end

  end
end
if __FILE__ == $0
  COUNT = 100_000
  SEARCH_COUNT = 10000
  s = Searching::SkipList.new
  now = Time.now
  COUNT.times{rand}
  rand_cost = Time.now - now
  now = Time.now
  COUNT.times{s << rand}
  insert_cost = Time.now - now - rand_cost
  puts "SkipList: time cost for inserting #{COUNT} items: #{insert_cost.to_f*1000}ms"
  samples = s.to_a.sample SEARCH_COUNT
  now = Time.now
  samples.each {|x| s[x[0]]}
  search_cost = Time.now - now
  puts "SkipList: time cost for searching #{SEARCH_COUNT} items from #{COUNT} items: #{search_cost.to_f*1000}ms"
  now = Time.now
  samples.each {|x| s.delete x[0]}
  delete_cost = Time.now - now
  puts "SkipList: time cost for deleting #{SEARCH_COUNT} items from #{COUNT} items: #{delete_cost.to_f*1000}ms"
end
