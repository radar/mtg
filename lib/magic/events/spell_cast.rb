module Magic
  module Events
    class SpellCast
      attr_reader :spell, :player, :x_value, :targets

      def initialize(spell:, player:, x_value: nil, flashback: false, targets: [])
        @spell = spell
        @player = player
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
