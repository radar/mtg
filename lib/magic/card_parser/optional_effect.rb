# frozen_string_literal: true

module Magic
  class CardParser
    # "You may <effect>." plus any "If you do, <effect>." / "When you do, <effect>."
    # sentences after it, and "If you don't, <effect>." for when it is declined. The
    # player is asked first (a MayChoice); see EffectList.
    class OptionalEffect < Data.define(:effect, :if_you_do, :if_you_dont)
      def initialize(effect:, if_you_do: [], if_you_dont: []) = super

      # What runs when the player accepts.
      def effects = [effect, *if_you_do]

      # Everything the optional effect can run, accepted or declined.
      def all_effects = [*effects, *if_you_dont]
    end
  end
end
