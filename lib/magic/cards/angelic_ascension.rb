module Magic
  module Cards
    AngelicAscension = Instant("Angelic Ascension") do
      cost generic: 1, white: 1
    end

    class AngelicAscension
      AngelToken = Token.create "Angel" do
        type "Creature —- Angel"
        power 4
        toughness 4
        colors :white
        keywords :flying
      end

      def single_target?
        true
      end

      def target_choices
        battlefield.cards.by_any_type(T::Creature, T::Planeswalker)
      end

      def resolve!(target:)
        target.exile!

        controller = target.controller

        controller.create_token(token_class: AngelToken)
      end
    end
  end
end
