module Magic
  module Cards
    Mortify = Instant("Mortify") do
      cost generic: 1, white: 1, black: 1
      type "Instant"
    end

    class Mortify < Instant
      def resolve!
        game.add_effect(
          Effects::Destroy.new(
            choices: battlefield.cards.select { |c| c.creature? || c.enchantment? },
          )
        )
        super
      end
    end
  end
end
