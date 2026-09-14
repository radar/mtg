module Magic
  module Events
    class SpellCast
      attr_reader :spell, :player, :x_value, :targets, :mana_cost

      def initialize(spell:, player:, mana_cost:, x_value: nil, flashback: false, targets: [])
        @spell = spell
        @player = player
        @mana_cost = mana_cost
        @x_value = x_value
        @flashback = flashback
        @targets = targets
      end

      def flashback?
        @flashback
      end

      def type?(type)
        spell.types.include?(type)
      end
    end
  end
end
