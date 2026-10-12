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
        trigger_effect(:modify_power_toughness, target: target, power: 3, toughness: 2)
        create_token(token: Tokens::Treasure)
      end
    end
  end
end
