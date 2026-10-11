module Magic
  module Cards
    LeylineOfHope = Enchantment("Leyline of Hope") do
      cost generic: 2, white: 2
      begins_on_battlefield
    end

    class LeylineOfHope < Enchantment
      # "If you would gain life, you gain that much life plus 1 instead."
      class OneMoreLife < ReplacementEffect
        def applies?(effect)
          effect.target == receiver.controller && effect.life.positive?
        end

        def call(effect)
          Effects::GainLife.new(source: effect.source, target: effect.target, life: effect.life + 1)
        end
      end

      # "As long as you have at least 7 life more than your starting life total, creatures you control get +2/+2."
      class HighLifeBonus < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 2
        creatures_you_control

        conditions { source.controller.life >= source.controller.starting_life + 7 }
      end

      def replacement_effects = { Effects::GainLife => OneMoreLife }
      def static_abilities = [HighLifeBonus]
    end
  end
end
