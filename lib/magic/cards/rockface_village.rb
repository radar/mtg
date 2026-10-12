module Magic
  module Cards
    RockfaceVillage = Card("Rockface Village") do
      type T::Land
    end

    class RockfaceVillage < Card
      TRIBES = %w[Lizard Mouse Otter Raccoon].freeze

      class ColorlessMana < Magic::TapManaAbility
        choices :colorless
      end

      # {T}: Add {R}. Spend this mana only to cast a creature spell.
      class CreatureMana < Magic::TapManaAbility
        choices :red

        def mana_restriction = ManaRestriction::CreatureSpells.new
      end

      # {R}, {T}: Target Lizard, Mouse, Otter, or Raccoon you control gets +1/+0 and gains haste until end of
      # turn. Activate only as a sorcery.
      class VillageAbility < Magic::ActivatedAbility
        costs "{R}, {T}"
        activate_only_as_sorcery

        def target_choices
          battlefield.controlled_by(controller).creatures.select { |creature| RockfaceVillage::TRIBES.any? { creature.type?(_1) } }
        end

        def resolve!(target:)
          trigger_effect(:modify_power_toughness, power: 1, toughness: 0, target: target, until_eot: true)
          trigger_effect(:grant_keyword, target: target, keyword: :haste)
        end
      end

      def activated_abilities = [ColorlessMana, CreatureMana, VillageAbility]
    end
  end
end
