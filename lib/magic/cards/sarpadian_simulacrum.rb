module Magic
  module Cards
    SarpadianSimulacrum = Creature("Sarpadian Simulacrum") do
      cost red: 1
      artifact_creature_type "Goblin"
      power 1
      toughness 1
      keywords :haste
    end

    class SarpadianSimulacrum < Creature
      # "{3}{R}, Sacrifice this creature: It deals 4 damage to target creature."
      class SacrificeAbility < Magic::ActivatedAbility
        costs "{3}{R}, Sacrifice {this}"

        def single_target? = true

        def target_choices = game.battlefield.creatures

        def resolve!(target:)
          deal_damage 4, to: target
        end
      end

      def activated_abilities = [SacrificeAbility]
    end
  end
end
