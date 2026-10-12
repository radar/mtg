module Magic
  module Cards
    MaskedBlackguard = Creature("Masked Blackguard") do
      cost generic: 1, black: 1
      creature_type("Human Rogue")
      keywords :flash
      power 2
      toughness 1
    end

    class MaskedBlackguard < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{2}{B}"

        def resolve!
          trigger_effect(:modify_power_toughness, target: source, power: 1, toughness: 1)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
