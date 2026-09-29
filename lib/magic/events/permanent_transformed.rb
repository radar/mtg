module Magic
  module Events
    # A double-faced permanent was turned over; `permanent.face` is the face that's now up.
    class PermanentTransformed
      attr_reader :permanent

      def initialize(permanent:)
        @permanent = permanent
      end

      def inspect
        "#<Events::PermanentTransformed permanent: #{permanent}>"
      end
    end
  end
end
