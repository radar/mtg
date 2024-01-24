module Magic
  module Cards
    DefiantStrike = Instant("Defiant Strike") do
      cost white: 1
    end

    class DefiantStrike < Instant
      def target_choices
        battlefield.creatures
      end

      def single_target?
        true
      end

      def resolve!(target:)
        if target.zone == battlefield
          target.modify_power_toughness!(source: self, power: 1, toughness: 0)
          controller.draw!
        end

        super
      end
    end
  end
end
