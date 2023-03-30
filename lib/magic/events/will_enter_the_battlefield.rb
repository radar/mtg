module Magic
  module Events
    class WillEnterTheBattlefield
      attr_reader :permanent

      def initialize(permanent)
        @permanent = permanent
      end

      def inspect
        "#<Events::WillEnterTheBattlefield permanent: #{permanent.name}, controller: #{permanent.controller.name}>"
      end
    end
  end
end
