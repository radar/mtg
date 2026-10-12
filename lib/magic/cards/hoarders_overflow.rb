module Magic
  module Cards
    class HoardersOverflow < Enchantment
      card_name "Hoarder's Overflow"
      cost generic: 1, red: 1

      # When this enchantment enters and whenever you expend 4, put a stash counter on it.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          add_counter("stash")
        end
      end

      def etb_triggers = [EntersTrigger]

      class ExpendTrigger < TriggeredAbility::Expend
        def threshold = 4

        def call
          add_counter("stash")
        end
      end

      def event_handlers = super.merge(ExpendTrigger.handlers)

      # {1}{R}, Sacrifice this enchantment: Discard your hand, then draw cards equal to the number of stash
      # counters on this enchantment.
      class DrawAbility < Magic::ActivatedAbility
        costs "{1}{R}, Sacrifice {this}"

        def resolve!
          stash = source.counters.of_type(Counters["stash"]).count
          [*controller.hand.cards].each(&:discard!)
          trigger_effect(:draw_cards, number_to_draw: stash) if stash.positive?
        end
      end

      def activated_abilities = [DrawAbility]
    end
  end
end
