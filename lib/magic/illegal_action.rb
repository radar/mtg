module Magic
  # Raised by Turn#take_action when an action cannot legally be taken right now.
  class IllegalAction < Error
    attr_reader :action, :reason

    def initialize(action, reason)
      @action = action
      @reason = reason
      super("#{action.inspect} is illegal: #{reason}")
    end
  end
end
