module Magic
  module Cards
    InvertPolarity = Instant("Invert Polarity") do
      cost "{U}{U}{R}"
    end

    class InvertPolarity < Instant
      def single_target? = true

      def target_choices
        game.stack.spells.reject { _1.card == self }
      end

      # "Choose target spell, then flip a coin. If you win the flip, gain control of that spell and you may choose new
      # targets for it. If you lose the flip, counter that spell."
      def resolve!(target:)
        if controller.flip_coin!
          target.gain_control!(controller)
          if target.card.respond_to?(:target_choices) && target.targets.any?
            retarget = DeflectingSwat::RetargetChoice.new(actor: self, target_item: target)
            game.choices.add(DeflectingSwat::MayRetargetChoice.new(actor: self, target_item: target)) if retarget.choices.any?
          end
        else
          counter_spell(target)
        end
      end
    end
  end
end
