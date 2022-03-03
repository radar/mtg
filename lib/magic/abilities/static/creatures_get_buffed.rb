module Magic
  module Abilities
    module Static
      class CreaturesGetBuffed
        attr_reader :source, :power, :toughness
        def initialize(source:, power:, toughness:, condition:)
          @source = source
          @power = power
          @toughness = toughness
          @applied_to = []
        end
      end
    end
  end
end
