module Magic
  module Cards
    WeaverOfHarmony = Creature("Weaver of Harmony") do
      enchantment_creature_type "Snake Druid"
      cost generic: 1, green: 1
      power 2
      toughness 2
    end

    class WeaverOfHarmony < Creature
      class OtherEnchantmentCreatureBoost < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1

        def applicable_targets
          source.controller.creatures.select(&:enchantment?) - [source]
        end
      end

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{G}, {T}"

        def resolve!
        end
      end

      def static_abilities = [OtherEnchantmentCreatureBoost]
      def activated_abilities = [ActivatedAbility]
    end
  end
end