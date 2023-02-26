module Magic
  module Cards
    SolRing = Card("Sol Ring") do
      type "Artifact"
      cost generic: 1
    end

    class SolRing < Card
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
