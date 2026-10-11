module Magic
  module Cards
    LeylineOfTheVoid = Enchantment("Leyline of the Void") do
      cost generic: 2, black: 2
      begins_on_battlefield
    end

    class LeylineOfTheVoid < Enchantment
      # "If a card would be put into an opponent's graveyard from anywhere, exile it instead."
      class ExileInsteadOfOpponentsGraveyard < ReplacementEffect
        def applies?(effect)
          return false unless effect.to.graveyard? && effect.to.owner != receiver.controller

          # A token isn't a card.
          !(effect.target.is_a?(Permanent) && effect.target.token?)
        end

        def call(effect)
          if effect.target.is_a?(Permanent)
            Effects::ExilePermanent.new(source: receiver, target: effect.target)
          else
            Effects::ExileCard.new(source: receiver, target: effect.target)
          end
        end
      end

      def replacement_effects
        { Effects::MoveCardZone => ExileInsteadOfOpponentsGraveyard, Effects::MovePermanentZone => ExileInsteadOfOpponentsGraveyard }
      end
    end
  end
end
