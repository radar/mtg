module Magic
  class Game
    class EventLog < SimpleDelegator
      def initialize(events = [])
        super(events)
      end

      def <<(event)
        __getobj__ << event
        self
      end

      def select(&block)
        self.class.new(__getobj__.select(&block))
      end

      def for_player(player)
        select { |event| event.respond_to?(:player) && event.player == player }
      end

      def landfall
        select { |event| event.is_a?(Events::Landfall) }
      end
    end
  end
end
