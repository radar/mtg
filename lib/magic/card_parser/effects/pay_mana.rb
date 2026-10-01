# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "you may pay {1}{W}. If you do, ...": the "may" is the choice itself (Choice::PayMana), and
      # the "If you do" effects run after it is accepted and paid (see EffectList). Only added to the
      # game when the controller can afford it. A bare "Pay {1}" reads the same way (optional).
      class PayMana < Data.define(:mana)
        include Effect

        LINE = /\APay (?<mana>(?:\{[^}]+\})+)\.?\z/i

        def self.parse(text)
          new(mana: ManaCost.parse(LINE.match(text)[:mana]).to_h) if LINE.match?(text)
        end

        def choice_base = "Magic::Choice::PayMana"
        def choice_class_name = "PayManaChoice"
        def choice_args = "mana: #{mana.inspect}"
        def choice_guard = "#{choice_base}.new(actor: #{Effect::THIS}, #{choice_args}).can_pay?"
      end
    end
  end
end
