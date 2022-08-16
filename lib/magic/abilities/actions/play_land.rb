module Magic
  module Actions
    class PlayLand < Action
      attr_reader :name

      def initialize(zone:, name:, **args)
        @zone = zone
        @name = name
        super(**args)
      end

      def perform
        card = @zone.by_name(name).first
        card.resolve!(player)
      end
    end
  end
end
