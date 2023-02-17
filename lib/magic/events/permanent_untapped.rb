module Magic
  module Events
    class PermanentUntapped
      attr_reader :permanent

      def initialize(permanent:)
        @permanent = permanent
      end

      def inspect
        "#<Events::PermanentUntapped permanent: #{permanent}, controller: #{permanent.controller}>"
      end
    end
  end
end
