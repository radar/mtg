module Magic
  module Events
    class PermanentLeavingZone
      attr_reader :permanent, :from, :to

      def initialize(permanent, from:, to:)
        @permanent = permanent
        @from = from
        @to = to
      end

      def death?
        (@from && @from.battlefield?) && @to.graveyard?
      end

      def inspect
        "#<Events::PermanentLeavingZone permanent: #{permanent.name}, from: #{from}, to: #{to}>"
      end
    end
  end
end
