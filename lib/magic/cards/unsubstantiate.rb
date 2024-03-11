module Magic
  module Cards
    class Unsubstantiate < Instant
      card_name "Unsubstantiate"
      cost "{1}{U}"

      def target_choices
        game.stack.spells + game.battlefield.creatures
      end

      def resolve!(target:)
        if target.is_a?(Actions::Cast)
          card = target.card
          game.stack.remove(target)
        else
          card = target
        end

        game.add_effect(Effects::ReturnToOwnersHand.new(source: self, target: card))
      end
    end
  end
end
