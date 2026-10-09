module Magic
  module Cards
    DesolationProwler = Creature("Desolation Prowler") do
      cost generic: 1, black: 1
      creature_type("Wolf")
      power 2
      toughness 2
    end

    class DesolationProwler < Creature
      # "Pay 2 life: This creature gets +2/+2 until end of turn. Activate only once each turn."
      class PumpAbility < Magic::ActivatedAbility
        costs "Pay 2 life"
        once_each_turn

        def resolve!
          trigger_effect(:modify_power_toughness, target: source, power: 2, toughness: 2)
        end
      end

      def activated_abilities = [PumpAbility]
    end
  end
end
