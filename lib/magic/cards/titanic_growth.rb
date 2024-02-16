module Magic
  module Cards
    class TitanicGrowth < Instant
      card_name "Titanic Growth"
      cost generic: 1, green: 1

      def target_choices
        creatures
      end

      def resolve!(target:)
        trigger_effect(:modify_power_toughness, power: 4, toughness: 4, target: target, until_eot: true)
      end
    end
  end
end
