module Magic
  module Targetable
    # Shroud, hexproof and protection filter for a spell or ability's chosen target. Objects that
    # aren't Targetable (cards in a graveyard, spells on the stack) are never restricted here.
    def self.targetable_by?(target, source:, controller:)
      !target.respond_to?(:can_be_targeted_by?) || target.can_be_targeted_by?(source, controller:)
    end

    def player?
      self.is_a?(Player)
    end

    def creature?
      self.is_a?(Permanent) && super
    end
  end
end
