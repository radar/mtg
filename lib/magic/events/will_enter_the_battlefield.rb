module Magic
  module Events
    class WillEnterTheBattlefield
      attr_reader :permanent, :from, :to

      def initialize(permanent, from: nil, to: nil)
        @permanent = permanent
        @from = from
        @to = to
      end

      def inspect
        "#<Events::WillEnterTheBattlefield permanent: #{permanent.name}, controller: #{permanent.controller.name}, from: #{from&.name}, to: #{to&.name}>"
      end
    end
  end
end
