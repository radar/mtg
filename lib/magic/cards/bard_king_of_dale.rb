module Magic
  module Cards
    BardKingOfDale = Creature("Bard, King of Dale") do
      cost "{4}{W}{U}"
      legendary_creature_type "Human Noble Archer"
      keywords :reach, :vigilance
      power 3
      toughness 5
    end

    class BardKingOfDale < Creature
      # "If you would draw a card except the first one you draw in each of your draw steps, draw two cards instead."
      # The turn's own draw is an effect whose source is the player, so it is the one that is left alone.
      class DrawReplacement < ReplacementEffect
        def applies?(effect)
          effect.is_a?(Effects::DrawCards) && effect.player == receiver.controller && !effect.source.is_a?(Magic::Player)
        end

        def call(effect)
          Effects::DrawCards.new(source: effect.source, player: effect.player, number_to_draw: effect.number_to_draw * 2)
        end
      end

      # "If one or more tokens would be created under your control, twice that many of those tokens are created instead."
      def replacement_effects
        {
          Effects::DrawCards => DrawReplacement,
          Effects::CreateToken => ReplacementEffect::TokenDoubler
        }
      end
    end
  end
end
