module Magic
  module Cards
    BellowingCrier = Creature("Bellowing Crier") do
      cost generic: 1, blue: 1
      creature_type("Frog Advisor")
      power 2
      toughness 1
    end

    class BellowingCrier < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:draw_card)
          game.choices.add(Magic::Choice::Discard.new(actor: actor, player: controller))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
