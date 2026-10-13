module Magic
  module Cards
    class LorescaleCoatl < Creature
      card_name "Lorescale Coatl"
      cost "{1}{G}{U}"
      creature_type "Snake"
      power 2
      toughness 2

      class CardDrawTrigger < TriggeredAbility
        def should_perform?
          you?
        end

        def call
          add_counter "+1/+1"
        end
      end

      def event_handlers
        {
          Events::CardDraw => CardDrawTrigger
        }
      end
    end
  end
end
