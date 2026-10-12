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
        trigger_effect(:deal_damage, target: targets[0], damage: 6)
        trigger_effect(:deal_damage, target: targets[1], damage: 2) if targets[1]
      end
    end
  end
end
