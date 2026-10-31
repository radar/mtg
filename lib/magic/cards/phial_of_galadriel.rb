module Magic
  module Cards
    PhialOfGaladriel = Artifact("Phial of Galadriel") do
      legendary_artifact
      cost generic: 3
    end

    class PhialOfGaladriel < Artifact
      # "If you would draw a card while you have no cards in hand, draw two cards instead." The first card of the draw
      # becomes two; any further cards are drawn with a card in hand.
      class DrawTwoInstead < ReplacementEffect
        def applies?(effect)
          effect.player == receiver.controller && effect.number_to_draw.positive? && receiver.controller.hand.none?
        end

        def call(effect)
          Effects::DrawCards.new(source: effect.source, player: effect.player, number_to_draw: effect.number_to_draw + 1)
        end
      end

      # "If you would gain life while you have 5 or less life, you gain twice that much life instead."
      class DoubleLifeGain < ReplacementEffect
        def applies?(effect)
          effect.target == receiver.controller && effect.life.positive? && receiver.controller.life <= 5
        end

        def call(effect)
          Effects::GainLife.new(source: effect.source, target: effect.target, life: effect.life * 2)
        end
      end

      # "{T}: Add one mana of any color."
      class ManaAbility < Magic::TapManaAbility
        choices :all
      end

      def replacement_effects = { Effects::DrawCards => DrawTwoInstead, Effects::GainLife => DoubleLifeGain }

      def activated_abilities = [ManaAbility]
    end
  end
end
