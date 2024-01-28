module Magic
  module Effects
    class CounterSpell < TargetedEffect
      def resolve!
        game.stack.counter!(target)
      end
    end
  end
end
