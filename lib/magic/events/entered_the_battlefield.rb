module Magic
  module Events
    class EnteredTheBattlefield
      attr_reader :permanent

      def initialize(permanent)
        @permanent = permanent
      end

      def inspect
        binding.pry unless permanent.controller
        "#<Events::EnteredTheBattlefield permanent: #{permanent.name}, controller: #{permanent.controller.name}>"
      end
    end
  end
end
