module Magic
  module Cards
    BreatheYourLast = Instant("Breathe Your Last") do
      cost generic: 1, black: 2
    end

    class BreatheYourLast < Instant
      def target_choices = battlefield.by_any_type(T::Creature, T::Planeswalker)

      # "Destroy target creature or planeswalker. You gain 1 life for each of its colors."
      def resolve!(target:)
        life = target.colors.size
        destroy(target)
        gain_life(life) if life.positive?
      end
    end
  end
end
