module Magic
  module Cards
    DoomBlade = Instant("Doom Blade") do
      cost generic: 1, black: 1

      def single_target?
        true
      end

      def target_choices
        battlefield.creatures.reject { |creature| creature.colors.include?(:black) }
      end

      def resolve!(target:)
        trigger_effect(:destroy_target, target: target)
      end
    end
  end
end
