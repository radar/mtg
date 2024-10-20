module Magic
  module Cards
    PhyrexianArena = Card("Phyrexian Arena") do
      cost generic: 1, black: 2
      type "Enchantment"
    end

    class PhyrexianArena < Card
      class BeginningOfUpkeepTrigger < TriggeredAbility
        def should_perform?
          you?
        end

        def call
          actor.trigger_effect(:draw_cards, source: actor)
          actor.trigger_effect(:lose_life, target: controller, life: 1)
        end
      end

      def event_handlers
        {
          Events::BeginningOfUpkeep => BeginningOfUpkeepTrigger
        }
      end
    end
  end
end
