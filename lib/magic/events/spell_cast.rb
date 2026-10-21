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

      # The mana the spell was paid with, as `{ color => amount }`; `{}` for a cost that isn't a mana cost.
      def mana_spent
        mana_cost.is_a?(Costs::Mana) ? mana_cost.mana_spent : {}
      end

      def flashback?
        @flashback
      end

      def type?(type)
        spell.type?(type)
      end
    end
  end
end
