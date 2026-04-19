module Magic
  class ReplacementEffect
    attr_reader :receiver

    def initialize(receiver:)
      @receiver = receiver
    end

    def applies?
      raise NotImplemented
    end

    def applies_with_context?(context)
      applies?(context.effect)
    end

    def call
      raise NotImplemented
    end

    def call_with_context(context)
      call(context.effect)
    end
  end
end
