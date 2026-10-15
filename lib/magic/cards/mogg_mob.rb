module Magic
  module Cards
    MoggMob = Creature("Mogg Mob") do
      cost red: 3
      creature_type "Goblin"
      power 3
      toughness 3
    end

    class MoggMob < Creature
      # "It deals 3 damage divided as you choose among one, two, or three targets." The division is answered when the
      # ability resolves, like the other divided-damage cards; the damage is dealt by the sacrificed Mob.
      class DivideDamageChoice < Magic::Choice
        def choices = game.any_target

        # Mandatory: skipping puts all 3 on the first legal target.
        def decline!
          resolve!(distribution: { choices.first => 3 })
        end

        def resolve!(distribution:)
          unless distribution.values.sum == 3 && distribution.values.all?(&:positive?)
            raise ArgumentError, "Mogg Mob must divide exactly 3 damage, at least 1 to each target"
          end
          raise ArgumentError, "at most three targets" if distribution.size > 3
          raise ArgumentError, "illegal target" unless distribution.keys.all? { choices.include?(_1) }

          distribution.each do |target, damage|
            deal_damage(damage, to: target)
          end
        end
      end

      # "Sacrifice this creature: It deals 3 damage divided as you choose among one, two, or three targets."
      class SacrificeAbility < Magic::ActivatedAbility
        costs "Sacrifice {this}"

        def resolve!
          game.choices.add(DivideDamageChoice.new(actor: source))
        end
      end

      def activated_abilities = [SacrificeAbility]
    end
  end
end
