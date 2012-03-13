module Sorting
  module Helper

    def sort(data)
      data = data.dup
      self.sort! data
      data
    end

  end
end
