module Magic
  class TargetingRule

    def initialize(source:)
      @source = source
    end

    def controlled_by(player)
      @controller = player
      self
    end

    def creatures
      @creatures = true
      self
    end

    def by_type(*types)
      @types = types
      self
    end

    def except(*exceptions)
      @exceptions = exceptions
      self
    end

    def include?(permanent)
      binding.pry
      return false if @exceptions && @exceptions.include?(permanent)
      return false if @controller && @controller != permanent.controller
      return false if @creatures && !permanent.creature?
      return false if @types && !@types.any? { |type| permanent.types.include?(type) }
      true
    end

  end
end
