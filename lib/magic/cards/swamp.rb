module Magic
  module Cards
    class Swamp < BasicLand
      NAME = "Swamp"
      TYPE_LINE = "Basic Land -- Swamp"

      class ManaAbility < Magic::ManaAbility
        def initialize(source:)
          @costs = [Costs::Tap.new(source)]

          super
        end

        def resolve!
          controller.add_mana(black: 1)
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
