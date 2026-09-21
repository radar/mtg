module Magic
  class IllegalAction < StandardError
    attr_reader :action, :reason

    def initialize(action, reason)
      @action = action
      @reason = reason
      super("#{action.inspect} is illegal: #{reason}")
    end
  end
end
