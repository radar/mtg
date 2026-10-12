module Magic
  module Cards
    RecklessRansacking = Instant("Reckless Ransacking") do
      cost generic: 1, red: 1
    end

    class RecklessRansacking < Instant
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        pump(target, 3, 2)
        create_token(token: Tokens::Treasure)
      end
    end
  end
end
