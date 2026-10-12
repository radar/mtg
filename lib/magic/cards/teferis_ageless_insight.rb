module Magic
  module Cards
    class TeferisAgelessInsight < Enchantment
      card_name "Teferi's Ageless Insight"
      type T::Super::Legendary, T::Enchantment
      cost generic: 2, blue: 2

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

      def replacement_effects = { Effects::DrawCards => DrawReplacement }
    end
  end
end
