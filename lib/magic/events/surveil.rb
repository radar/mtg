module Magic
  module Events
    class Surveil
      attr_reader :player, :graveyard, :top

      def initialize(player:, graveyard:, top:)
        @player = player
        @graveyard = graveyard
        @top = top
      end

      def inspect
        "#<Events::Surveil player: #{player}, graveyard: #{graveyard}, top: #{top}>"
      end
    end
  end
end
