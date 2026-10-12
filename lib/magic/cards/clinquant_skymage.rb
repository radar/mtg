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
          add_counter("+1/+1", to: actor)
        end
      end

      def event_handlers = { Events::CardDraw => CardDrawTrigger }
    end
  end
end
