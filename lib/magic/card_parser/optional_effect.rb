# frozen_string_literal: true

module Magic
  class CardParser
    # "You may <effect>." plus any "If you do, <effect>." sentences after it. The
    # player is asked first (a MayChoice); see EffectList.
    class OptionalEffect < Data.define(:effect, :if_you_do)
      def effects = [effect, *if_you_do]
    end
  end
end
