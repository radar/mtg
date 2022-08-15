module Magic
  module Events
    class PermanentTapped
      attr_reader :permanent

      def initialize(permanent:)
        @permanent = permanent
      end

      def inspect
        "#<Events::PermanentTapped permanent: #{permanent}, controller: #{permanent.controller}>"
      end
    end
  end
end
