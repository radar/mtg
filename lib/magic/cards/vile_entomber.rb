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
          game.choices.add(Magic::Choice::SearchLibrary.new(actor: actor, to_zone: :graveyard, enters_tapped: false, upto: 1, filter: ->(card) { true }))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
