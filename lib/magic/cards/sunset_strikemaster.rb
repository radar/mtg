module Magic
  module Cards
    SunsetStrikemaster = Creature("Sunset Strikemaster") do
      cost generic: 1, red: 1
      creature_type("Human Monk")
      power 3
      toughness 1
    end

    class SunsetStrikemaster < Creature
      class ManaAbility < Magic::TapManaAbility
        def resolve!
          source.controller.add_mana(red: 1)
        end
      end

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{2}{R}, {T}, Sacrifice {this}"

        def target_choices
          battlefield.creatures.select { _1.has_keyword?(Keywords::FLYING) }
        end

        def resolve!(target:)
          trigger_effect(:deal_damage, target: target, damage: 6)
        end
      end

      def activated_abilities = [ManaAbility, ActivatedAbility]
    end
  end
end
