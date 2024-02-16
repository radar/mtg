module Magic
  module Events
    class LeftTheBattlefield
      attr_reader :permanent, :to

      def initialize(permanent, to:)
        @to = to
        @permanent = permanent
      end

      def inspect
        "#<Events::LeftTheBattlefield permanent: #{permanent.name}, controller: #{permanent.controller.name}, to: #{to}>"
      end
    end
  end
end
