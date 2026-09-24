# frozen_string_literal: true

module Magic
  class CardParser
    # "If this spell was kicked, <effects>." on an instant or sorcery: the effects run
    # only when the kicker cost was paid. See EffectList.
    class KickedEffect < Data.define(:effects)
      # Not a choice point itself: its effects are rendered inside an `if`.
      def choice_base = nil
      def target_choices = nil
    end
  end
end
