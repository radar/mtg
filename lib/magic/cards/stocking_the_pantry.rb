module Magic
  module Cards
    class StockingThePantry < Enchantment
      card_name "Stocking the Pantry"
      cost green: 1

      # Whenever you put one or more +1/+1 counters on a creature you control, put a supply counter on this
      # enchantment.
      class CounterTrigger < TriggeredAbility
        def should_perform?
          event.counter_type.to_s == "+1/+1" && event.target.is_a?(Permanent) && event.target.creature? && event.target.controller == controller
        end

        def call
          add_counter("supply")
        end
      end

      def event_handlers = super.merge(Events::CounterAddedToPermanent => CounterTrigger)

      # {2}, Remove a supply counter from this enchantment: Draw a card.
      class DrawAbility < Magic::ActivatedAbility
        costs "{2}, Remove 1 supply counter from {this}"

        def resolve!
          draw_card
        end
      end

      def activated_abilities = [DrawAbility]
    end
  end
end
