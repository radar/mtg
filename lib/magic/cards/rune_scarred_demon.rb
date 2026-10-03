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
          game.choices.add(Magic::Choice::SearchLibrary.new(actor: actor, to_zone: :hand, enters_tapped: false, upto: 1, filter: ->(card) { true }))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
