module Magic
  module Cards
    FrostBreath = Instant("Frost Breath") do
      cost generic: 2, blue: 1

      def single_target?
        false
      end

      def target_choices
        battlefield.creatures
      end

      def resolve!(player, targets:)
        targets.each(&:tap!)
        targets.each(&:cannot_untap_next_turn!)
      end
    end
  end
end
