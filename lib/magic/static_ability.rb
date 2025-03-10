module Magic
  class StaticAbility
    extend Forwardable

    def self.applicable_targets(&block)
      define_method(:applicable_targets, block)
    end

    def self.conditions(&block)
      define_method(:conditions_met?, &block)
    end

    def self.applies_to_target
      define_method(:applicable_targets) { [source.attached_to] }
    end

    def_delegators :@source, :controller, :owner, :game

    def initialize(source:)
      @source = source
    end

    def battlefield
      game.battlefield
    end

    def your
      source.controller
    end

    def applies_to?(_permanent)
      true
    end

    def conditions_met?
      true
    end
  end
end
