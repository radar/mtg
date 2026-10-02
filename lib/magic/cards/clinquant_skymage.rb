module Magic
  module Cards
    ClinquantSkymage = Creature("Clinquant Skymage") do
      cost generic: 3, blue: 1
      creature_type("Bird Wizard")
      keywords :flying
      power 1
      toughness 1
    end

    class ClinquantSkymage < Creature
      class CardDrawTrigger < TriggeredAbility
        def should_perform?
          you?
        end

        def call
          trigger_effect(:add_counter, counter_type: "+1/+1", target: actor, amount: 1)
        end
      end

      def event_handlers = { Events::CardDraw => CardDrawTrigger }
    end
  end
end
