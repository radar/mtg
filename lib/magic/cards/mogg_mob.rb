module Magic
  module Cards
    MoggMob = Creature("Mogg Mob") do
      cost red: 3
      creature_type "Goblin"
      power 3
      toughness 3
    end

    class MoggMob < Creature
      # "Sacrifice this creature: It deals 3 damage divided as you choose among one, two, or three targets." Targets and
      # the division are chosen on activation: `a.targeting(p2, bears, distribution: { p2 => 1, bears => 2 })`; one
      # target takes all 3. The damage is dealt by the sacrificed Mob. See `Actions::DividedTargeting`.
      class SacrificeAbility < Magic::ActivatedAbility
        costs "Sacrifice {this}"

        def target_choices = game.any_target - [source]

        def divided_amount = 3

        def max_divided_targets = 3

        # A target that left the battlefield is skipped; the rest still take their damage.
        def resolve!(distribution:)
          distribution.each do |target, damage|
            next if target.is_a?(Permanent) && target.zone.nil?

            deal_damage(damage, to: target)
          end
        end
      end

      def activated_abilities = [SacrificeAbility]
    end
  end
end
