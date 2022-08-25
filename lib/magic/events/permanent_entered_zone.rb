module Magic
  module Events
    class PermanentEnteredZone
      attr_reader :permanent, :from, :to

      def initialize(permanent, from:, to:)
        @permanent = permanent
        @from = from
        @to = to
      end

      def death?
        @from.battlefield? && @to.graveyard?
      end

      def inspect
        "#<Events::PermanentEnteredZone permanent: #{permanent.name}, from: #{from}, to: #{to}>"
      end
    end
  end
end
