module Magic
  module Events
    class PermanentSacrificed
      attr_reader :permanent

      def initialize(permanent:)
        @permanent = permanent
      end
    end
  end
end