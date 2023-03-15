module Magic
  module Cards
    JungleHollow = Card("Jungle Hollow") do
      type "Land"
    end

    class JungleHollow < Card
      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          controller.gain_life(1)
        end
      end

      def etb_triggers = [ETB]

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
