module Magic
  module Cards
    class SolRing < Card
      NAME = "Sol Ring"
      TYPE_LINE = "Artifact"
      COST = { generic: 1 }

      class ManaAbility < Magic::ManaAbility
        def initialize(source:)
          @costs = [Costs::Tap.new(source)]

          super
        end

        def resolve!
          controller.add_mana(colorless: 2)
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
