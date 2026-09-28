module Magic
  module Cards
    CribSwap = Instant("Crib Swap") do
      cost generic: 2, white: 1
      type T::Kindred, T::Instant, T::Creatures["Shapeshifter"]
      keywords :changeling
    end

    class CribSwap < Instant
      ShapeshifterToken = Token.create "Shapeshifter" do
        creature_type "Shapeshifter"
        power 1
        toughness 1
        keywords :changeling
      end

      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        trigger_effect(:exile, target: target)
        trigger_effect(:create_token, token_class: ShapeshifterToken, controller: target.controller)
      end
    end
  end
end
