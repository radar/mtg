module Magic
  class ReplacementEffect
    attr_reader :receiver

    def initialize(receiver:)
      @receiver = receiver
    end

    def applies?
      raise NotImplemented
    end

    def call
      raise NotImplemented
    end
  end
end
