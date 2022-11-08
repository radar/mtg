module Magic
  module Cards
    GolgariGuildgate = Card("Golgari Guildgate") do
      type "Land -- Gate"
    end

    class GolgariGuildgate < Card
      def enters_tapped?
        true
      end

      class ManaAbility < Magic::ManaAbility
        def initialize(source:)
          @costs = [Costs::Tap.new(source)]

          super
        end

        def resolve!
          game.add_effect(
            Effects::AddManaOrAbility.new(
              source: source,
              player: source.controller,
              black: 1,
              green: 1
            )
          )
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
