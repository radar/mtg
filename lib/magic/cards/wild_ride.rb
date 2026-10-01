module Magic
  module Cards
    WildRide = Sorcery("Wild Ride") do
      cost red: 1
      harmonize Costs::Mana.new(generic: 4, red: 1)
    end

    class WildRide < Sorcery
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        trigger_effect(:modify_power_toughness, target: target, power: 3, toughness: 0)
        trigger_effect(:grant_keyword, target: target, keyword: :haste)
      end
    end
  end
end
