module Magic
  module Events
    # A copy of a spell was put onto the stack (Magecraft: "whenever you cast or copy an instant or sorcery spell").
    # Shaped like SpellCast so `TriggeredAbility::SpellCast` triggers can listen to both.
    class SpellCopied
      attr_reader :spell, :player

      def initialize(spell:, player:)
        @spell = spell
        @player = player
      end

      def type?(type)
        spell.type?(type)
      end
    end
  end
end
