module Magic
  module Cards
    class DazzlingDenial < Instant
      card_name "Dazzling Denial"
      cost generic: 1, blue: 1

      def target_choices = game.stack.spells.reject { _1.card == self }

      # Counter target spell unless its controller pays {2}. If you control a Bird, counter that spell unless
      # its controller pays {4} instead.
      def resolve!(target:)
        amount = battlefield.controlled_by(controller).creatures.any? { _1.type?("Bird") } ? 4 : 2
        choice = Magic::Choice::CounterUnlessPay.new(actor: self, spell: target, mana: { generic: amount })
        if choice.can_pay?
          game.choices.add(choice)
        else
          counter_spell(target)
        end
      end
    end
  end
end
