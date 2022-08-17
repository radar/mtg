module Magic
  module Actions
    class PlayLand < Action
      attr_reader :name, :zone

      def initialize(zone:, name:, **args)
        @zone = zone
        @name = name
        super(**args)
      end

      def inspect
        "#<Actions::PlayLand name: #{name}, player: #{player.inspect}>"
      end

      def perform
        card = @zone.by_name(name).first
        card.resolve!(player)
      end
    end
  end
end
