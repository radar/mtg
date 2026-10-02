module Magic
  module Cards
    BrinebornCutthroat = Creature("Brineborn Cutthroat") do
      cost generic: 1, blue: 1
      creature_type("Merfolk Pirate")
      keywords :flash
      power 2
      toughness 1
    end

    class BrinebornCutthroat < Creature
      class OpponentsTurnSpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && !controllers_turn?
        end

        def call
          trigger_effect(:add_counter, counter_type: "+1/+1", target: actor, amount: 1)
        end
      end

      def event_handlers = { Events::SpellCast => OpponentsTurnSpellCastTrigger }
    end
  end
end
