module Magic
  module Cards
    UncoverTheMoonLetters = Enchantment("Uncover the Moon-Letters") do
      cost generic: 3, blue: 1
    end

    class UncoverTheMoonLetters < Enchantment
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && !spell.type?("Creature")
        end

        class MayChoice < Magic::Choice::May
          def initialize(amount:, **args)
            super(**args)
            @amount = amount
          end

          # "You may draw X cards, where X is the amount of mana spent to cast that spell. If you do, discard two cards."
          def resolve!
            trigger_effect(:draw_cards, number_to_draw: @amount) if @amount.positive?
            2.times { game.choices.add(Magic::Choice::Discard.new(actor: actor, player: controller)) }
          end
        end

        def call
          mana_spent = event.mana_cost.mana_value
          game.choices.add(MayChoice.new(actor: actor, amount: mana_spent))
        end
      end

      def event_handlers = super.merge({ Events::SpellCast => SpellCastTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
