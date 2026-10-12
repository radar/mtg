module Magic
  module Cards
    class LongRiversPull < Instant
      card_name "Long River's Pull"
      cost blue: 2
      gift :card

      # Counter target creature spell. If the gift was promised, instead counter target spell.
      def target_choices
        spells = game.stack.spells.reject { _1.card == self }
        gift_promised? ? spells : spells.select { _1.card.creature? }
      end

      def resolve!(target:)
        trigger_effect(:counter_spell, target: target)
      end
    end
  end
end
