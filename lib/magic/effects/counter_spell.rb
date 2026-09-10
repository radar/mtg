module Magic
  module Effects
    class CounterSpell < TargetedEffect
      def resolve!
        game.stack.counter!(target) if target.card.can_be_countered?
      end
    end
  end
end
