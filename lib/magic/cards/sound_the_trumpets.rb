module Magic
  module Cards
    class SoundTheTrumpets < Instant
      card_name "Sound the Trumpets"
      cost generic: 1, blue: 2

      def single_target?
        true
      end

      def target_choices
        game.stack.spells
      end

      def resolve!(target:)
        small = target.card.mana_value <= 2
        trigger_effect(:counter_spell, target: target)
        Magic::Recruit.call(player: controller) if small
      end
    end
  end
end
