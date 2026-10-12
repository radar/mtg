module Magic
  module Cards
    class ConductElectricity < Instant
      card_name "Conduct Electricity"
      cost generic: 4, red: 1

      def multi_target? = true

      def target_choices
        [battlefield.creatures, battlefield.creatures.select(&:token?)]
      end

      # Conduct Electricity deals 6 damage to target creature and 2 damage to up to one target creature token.
      def resolve!(targets:)
        deal_damage(6, to: targets[0])
        deal_damage(2, to: targets[1]) if targets[1]
      end
    end
  end
end
