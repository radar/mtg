module Magic
  module Events
    class PermanentWillDie
      attr_reader :permanent

      def initialize(permanent)
        @permanent = permanent
      end

      def inspect
        "#<Events::PermanentWillDie permanent: #{permanent.name}, controller: #{permanent.controller.name}>"
      end
    end
  end
end
