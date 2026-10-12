module Magic
  module Events
    # `permanent` became the target of a spell or ability `controller` controls (`source`): announced when a
    # spell is cast or an ability activated with it as a target, and when a triggered ability's target is
    # chosen (Choice::Targeted). Valiant and "whenever a creature you control becomes the target" watch this.
    class BecameTarget
      attr_reader :permanent, :controller, :source

      def initialize(permanent:, controller:, source:)
        @permanent = permanent
        @controller = controller
        @source = source
      end

      def player = controller

      def inspect
        "#<Events::BecameTarget permanent: #{permanent.name}, controller: #{controller.name}>"
      end
    end
  end
end
