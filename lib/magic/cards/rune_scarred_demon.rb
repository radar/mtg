module Magic
  module Cards
    RuneScarredDemon = Creature("Rune-Scarred Demon") do
      cost generic: 5, black: 2
      creature_type("Demon")
      keywords :flying
      power 6
      toughness 6
    end

    class RuneScarredDemon < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.search_library(actor, find: ->(card) { true }, to: :hand)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
