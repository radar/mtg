module Magic
  module Cards
    class GolgariGuildgate < Card
      NAME = "Golgari Guildgate"
      TYPE_LINE = "Land -- Gate"

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
