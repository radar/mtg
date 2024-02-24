module Magic
  module Effects
    class CounterAbility < TargetedEffect
      def resolve!
        game.stack.counter!(target)
      end
    end
  end
end
