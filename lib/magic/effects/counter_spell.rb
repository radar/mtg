module Magic
  module Effects
    class CounterSpell < TargetedEffect
      def resolve(target)
        target.counter!
      end
    end
  end
end
