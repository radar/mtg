module Magic
  module Cards
    SureStrike = Instant("Sure Strike") do
      cost generic: 1, red: 1

      def single_target?
        true
      end

      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        target.modify_power(3)
        target.grant_first_strike!
      end
    end
  end
end
