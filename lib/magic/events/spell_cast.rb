module Magic
  module Events
    class SpellCast
      attr_reader :spell, :player

      def initialize(spell:, player:)
        @spell = spell
        @player = player
      end
    end
  end
end
