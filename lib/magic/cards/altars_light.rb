module Magic
  module Cards
    AltarsLight = Instant("Altar's Light") do
      cost generic: 2, white: 2
    end

    class AltarsLight < Instant
      def resolve!
        game.add_effect(
          Effects::Exile.new(
            choices: game.battlefield.cards.select { |c| c.artifact? || c.enchantment? },
          )
        )
        super
      end
    end
  end
end
