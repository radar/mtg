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
        destroy(target)
      end
    end
  end
end
