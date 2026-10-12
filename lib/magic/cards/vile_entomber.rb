module Magic
  module Cards
    VileEntomber = Creature("Vile Entomber") do
      cost generic: 2, black: 2
      creature_type("Zombie Warlock")
      keywords :deathtouch
      power 2
      toughness 2
    end

    class VileEntomber < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.search_library(actor, find: ->(card) { true }, to: :graveyard)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
