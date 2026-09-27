module Magic
  module Cards
    BoneclubBerserker = Creature("Boneclub Berserker") do
      cost generic: 3, red: 1
      creature_type("Goblin Berserker")
      power 2
      toughness 4
    end

    class BoneclubBerserker < Creature
      class SelfBuff < Abilities::Static::PowerAndToughnessModification
        applicable_targets { [source] }

        def power_modification = 2 * controller.permanents.by_type("Goblin").except(source).count
      end

      def static_abilities = [SelfBuff]
    end
  end
end
