module Magic
  module Events
    class EnteredTheBattlefield < Base
      attr_reader :permanent, :from

      def initialize(permanent, from:, kicked: false)
        @from = from
        @permanent = permanent
        @kicked = kicked
      end

      def kicked?
        @kicked
      end

      def inspect
        "#<Events::EnteredTheBattlefield permanent: #{permanent.name}, controller: #{permanent.controller.name}, from: #{from}>"
      end

      def player
        permanent.controller
      end
    end
  end
end
