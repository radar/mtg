module Magic
  module Events
    class CreatureDied
      attr_reader :permanent, :controller

      def initialize(permanent)
        @permanent = permanent
        @controller = permanent.controller
      end

      def player = controller

      def inspect
        "#<Events::CreatureDied permanent: #{permanent.name}, controller: #{controller.name}>"
      end
    end
  end
end
