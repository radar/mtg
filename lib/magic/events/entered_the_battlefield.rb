module Magic
  module Events
    class EnteredTheBattlefield < Base
      attr_reader :permanent, :from

      def initialize(permanent, from:)
        @from = from
        @permanent = permanent
      end

      def inspect
        "#<Events::EnteredTheBattlefield permanent: #{permanent.name}, controller: #{permanent.controller.name}, from: #{from}>"
      end
    end
  end
end
