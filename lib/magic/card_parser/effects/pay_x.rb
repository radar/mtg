# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "you may pay {X}. When you do, put X +1/+1 counters on ~.": like PayMana, the "may" is the choice
      # itself (`Choice::PayX`, `game.resolve_choice!(x: 2)`). EffectList reads the "X" of the effects
      # that follow as the choice's `x` (see `EffectList::PAY_X`).
      class PayX < Data.define
        include Effect

        LINE = /\APay \{X\}\.?\z/i

        def self.parse(text) = (new if LINE.match?(text))

        def may_choice? = true
        def choice_base = "Magic::Choice::PayX"
        def choice_class_name = "PayXChoice"
        def choice_guard = "#{choice_base}.new(actor: #{Effect::THIS}).can_pay?"
      end
    end
  end
end
