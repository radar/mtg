module Magic
  class Zone
    extend Forwardable

    def_delegator :@cards, :include?
    def library?
      false
    end

    def graveyard?
      false
    end

    def hand?
      false
    end

    def battlefield?
      false
    end
  end
end
