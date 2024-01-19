module Magic
  module Effects
    class CounterSpell < TargetedEffect
      def resolve(target = targets.first)
        game.stack.counter!(target)
      end
    end
  end
end
