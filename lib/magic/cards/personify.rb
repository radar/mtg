module Magic
  module Cards
    Personify = Instant("Personify") do
      cost generic: 1, white: 1
    end

    class Personify < Instant
      ShapeshifterToken = Token.create "Shapeshifter" do
        creature_type "Shapeshifter"
        power 1
        toughness 1
        keywords :changeling
      end

      def target_choices
        battlefield.controlled_by(controller).creatures
      end

      def resolve!(target:)
        card = target.card
        trigger_effect(:exile, target: target)
        Permanent.resolve(game: game, card: card, owner: card.owner, cast: false)
        trigger_effect(:create_token, token_class: ShapeshifterToken)
      end
    end
  end
end
