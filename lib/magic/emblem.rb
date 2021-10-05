module Magic
  class Emblem
    attr_reader :controller

    def initialize(controller:)
      @controller = controller
    end

    def receive_event(event)
    end
  end
end
