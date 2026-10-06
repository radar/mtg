module Magic
  module Cards
    FinishingBlow = Instant("Finishing Blow") do
      cost generic: 4, black: 1
    end

    class FinishingBlow < Instant
      def target_choices = battlefield.by_any_type(T::Creature, T::Planeswalker)

      # "Destroy target creature or planeswalker."
      def resolve!(target:)
        trigger_effect(:destroy_target, target:)
      end
    end
  end
end
