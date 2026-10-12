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
          add_counter("+1/+1", to: actor)
        end
      end

      def event_handlers = { Events::SpellCast => OpponentsTurnSpellCastTrigger }
    end
  end
end
