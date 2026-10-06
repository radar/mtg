module Magic
  class StaticAbility
    extend Forwardable

    def self.applicable_targets(&block)
      define_method(:applicable_targets, block)
    end

    def self.layer(number, sublayer: nil)
      define_method(:layer) { number }
      define_method(:sublayer) { sublayer }
    end

    def layer = nil
    def sublayer = nil

    # 613.7: a static ability's effect has the timestamp of when its source
    # entered the battlefield. A graveyard-sourced static ability (e.g. Anger)
    # comes from a Card, which has no timestamp of its own -- falls back to 0
    # ("oldest"), a simplification since only one card in the repo uses that path.
    def timestamp
      # Some abilities (Tyvar Kell's emblem grant) are built without a source.
      respond_to?(:source) && source.respond_to?(:timestamp) ? source.timestamp : 0
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

    def creatures
      battlefield.creatures
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
