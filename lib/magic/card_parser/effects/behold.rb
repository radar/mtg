# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "you may behold a Dragon. If you do, ...": choose a Dragon you control or reveal one from your
      # hand. Like PayMana the "may" is the choice itself (Choice::Behold) and the "If you do" effects
      # run once it is accepted; it is only added when there is a Dragon to behold. (Beholding as an
      # additional cost to cast a spell is Rules::BeholdCost.)
      class Behold < Data.define(:type)
        include Effect

        LINE = /\ABehold an? (?<type>[A-Z][\w-]*)\.?\z/

        def self.parse(text)
          return unless (m = LINE.match(text)) && Types::Creatures.values.include?(m[:type])

          new(type: m[:type])
        end

        def may_choice? = true
        def choice_base = "Magic::Choice::Behold"
        def choice_class_name = "BeholdChoice"
        def choice_args = "type: #{type.inspect}"
        def choice_guard = "#{choice_base}.new(actor: #{Effect::THIS}, #{choice_args}).candidates.any?"
      end
    end
  end
end
