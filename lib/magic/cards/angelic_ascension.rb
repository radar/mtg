module Magic
  module Cards
    AngelicAscension = Instant("Angelic Ascension") do
      cost generic: 1, white: 1
    end

    class AngelicAscension

      def single_target?
        true
      end

      def target_choices
        battlefield.cards.by_any_type(T::Creature, T::Planeswalker)
      end

      def resolve!(target:)
        target.exile!

        controller = target.controller

        Permanent.resolve(game: game, owner: controller, card: Tokens::Angel.new(owner: controller))
      end
    end
  end
end
