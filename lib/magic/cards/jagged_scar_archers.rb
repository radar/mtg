module Magic
  module Cards
    JaggedScarArchers = Creature("Jagged-Scar Archers") do
      cost generic: 1, green: 2
      creature_type "Elf Archer"
    end

    class JaggedScarArchers < Creature
      class DynamicPowerAndToughness < Abilities::Static::PowerAndToughnessModification
        def applicable_targets = [source]

        def power_modification
          source.controller.permanents.by_any_type("Elf").count
        end

        alias_method :toughness_modification, :power_modification
      end

      class DamageAbility < Magic::ActivatedAbility
        costs "{T}"

        def target_choices
          game.battlefield.creatures.with_keyword(:flying)
        end

        def resolve!(target:)
          deal_damage(source.power, to: target)
        end
      end

      def static_abilities = [DynamicPowerAndToughness]

      def activated_abilities = [DamageAbility]
    end
  end
end
