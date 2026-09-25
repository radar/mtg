module Magic
  module Events
    class Regenerated
      attr_reader :permanent

      def initialize(permanent:)
        @permanent = permanent
      end
    end
  end
end
