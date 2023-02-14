module Magic
  class Emblem
    attr_reader :owner

    def initialize(owner:)
      @owner = owner
    end

    def receive_event(event)
    end
  end
end
