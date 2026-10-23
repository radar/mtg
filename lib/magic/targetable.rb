module Magic
  module Targetable
    # Shroud, hexproof and protection filter for a spell or ability's chosen target. Objects that
    # aren't Targetable (cards in a graveyard, spells on the stack) are never restricted here. `spell:` says whether the
    # source is a spell being cast (true) or an ability (false); left out, the source's own kind and zone decide.
    def self.targetable_by?(target, source:, controller:, spell: nil)
      !target.respond_to?(:can_be_targeted_by?) || target.can_be_targeted_by?(source, controller:, spell:)
    end

    def player?
      self.is_a?(Player)
    end

    def creature?
      self.is_a?(Permanent) && super
    end
  end
end
