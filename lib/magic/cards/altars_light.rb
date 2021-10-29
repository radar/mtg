module Magic
  module Cards
    AltarsLight = Instant("Altar's Light") do
      cost generic: 2, white: 2
    end

    class AltarsLight < Instant
      def target_choices
        game.battlefield.cards.select { |c| c.artifact? || c.enchantment? }
      end

      def resolve!(target:)
        Effects::Exile.new.resolve(target: target)
      end
    end
  end
end
