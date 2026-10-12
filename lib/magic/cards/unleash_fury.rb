module Magic
  module Cards
    UnleashFury = Instant("Unleash Fury") do
      cost generic: 1, red: 1
    end

    class UnleashFury < Instant
      def target_choices = battlefield.creatures

      # "Double the power of target creature until end of turn."
      def resolve!(target:)
        pump(target, target.power, 0)
      end
    end
  end
end
