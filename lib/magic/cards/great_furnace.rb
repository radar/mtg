module Magic
  module Cards
    class GreatFurnace < Land
      NAME = "Great Furnace"
      TYPE_LINE = "Artifact Land"

      class ManaAbility < Magic::ManaAbility
        def initialize(source:)
          @costs = [Costs::Tap.new(source)]

          super
        end

        def resolve!
          controller.add_mana(red: 1)
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
