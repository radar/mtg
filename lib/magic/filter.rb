module Magic
  class Filter < SimpleDelegator
    def self.[](*filters)
      new(filters)
    end
  end
end
