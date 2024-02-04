module Magic
  module Events
    class CreatureDied
      attr_reader :permanent

      def initialize(permanent)
        @permanent = permanent
      end

      def inspect
        "#<Events::CreatureDied permanent: #{permanent.name}, controller: #{permanent.controller.name}>"
      end
    end
  end
end
