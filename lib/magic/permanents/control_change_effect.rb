module Magic
  module Permanents
    # Layer 2 (613): "gain control of target permanent [until end of turn]."
    # `Permanent#control_change_effects` keeps an ordered list of these so
    # stacked control-change effects on the same permanent revert correctly
    # instead of a single slot being clobbered by the second one.
    class ControlChangeEffect < ContinuousEffect
      layer 2

      attr_reader :controller, :previous_controller

      def initialize(controller:, previous_controller:, **args)
        @controller = controller
        @previous_controller = previous_controller
        super(**args)
      end
    end
  end
end
