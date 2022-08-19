module Magic
  class ActivatedAbility
    attr_reader :source, :costs, :requirements

    def initialize(source:, costs: [], requirements: [])
      @source = source
      @costs = costs
      @requirements = requirements
    end


    def battlefield
      source.game.battlefield
    end
  end
end
