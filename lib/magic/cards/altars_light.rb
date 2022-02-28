module Magic
  module Cards
    AltarsLight = Instant("Altar's Light") do
      cost generic: 2, white: 2
    end

    class AltarsLight < Instant
      def target_choices
        battlefield.cards.select { |c| c.artifact? || c.enchantment? }
      end

      def resolve!(target:)
        Effects::Exile.new(source: self).resolve(target: target)
      end
    end
  end
end
