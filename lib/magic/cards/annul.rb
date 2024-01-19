module Magic
  module Cards
    Annul = Instant("Annul") do
      cost blue: 1
    end

    class Annul < Instant
      def single_target?
        true
      end

      def target_choices
        game.stack.select { |c| c.enchantment? || c.artifact? }
      end

      def resolve!(target:)
        Effects::CounterSpell.new(source: self).resolve(target)
        super
      end
    end
  end
end
