module Magic
  module Cards
    class SkywaySniper < Creature
      card_name "Skyway Sniper"
      cost green: 1
      creature_type "Elf Archer"
      power 1
      toughness 2
      keywords :reach

      class ActivatedAbility < ActivatedAbility
        costs "{2}{G}"

        def target_choices
          game.battlefield.creatures.with_keyword(:flying)
        end

        def resolve!(target:)
          deal_damage(1, to: target)
        end
      end

      def activated_abilities
        [ActivatedAbility]
      end
    end
  end
end

# Skyway Sniper {G}
# Creature — Elf Archer
# Reach (This creature can block creatures with flying.)
# {2}{G}: Skyway Sniper deals 1 damage to target creature with flying.
# 1/2
