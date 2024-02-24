module Magic
  module Events
    class SpellCountered
      attr_reader :spell, :player
      def initialize(spell:, player:)
        @spell = spell
        @player = player
      end
    end
  end
end
