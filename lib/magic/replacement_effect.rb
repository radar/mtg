module Magic
  class ReplacementEffect
    class InvalidApplicabilityResult < StandardError; end
    class InvalidReplacementResult < StandardError; end

    attr_reader :receiver

    def initialize(receiver:)
      @receiver = receiver
    end

    def applies?(_effect)
      raise NotImplementedError, "#{self.class} must implement #applies?(effect)"
    end

    def applies_with_context?(context)
      result = applies?(context.effect)
      unless result == true || result == false
        raise InvalidApplicabilityResult, "#{self.class}#applies? must return true or false"
      end

      result
    end

    def call(_effect)
      raise NotImplementedError, "#{self.class} must implement #call(effect)"
    end

    def call_with_context(context)
      replacement_effect = call(context.effect)
      unless replacement_effect.respond_to?(:resolve!)
        raise InvalidReplacementResult, "#{self.class}#call must return an effect-like object responding to #resolve!"
      end

      replacement_effect
    end
  end
end
