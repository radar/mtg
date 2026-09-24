# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Counter target spell." / "Counter target creature spell." / "Counter
      # target noncreature spell." / "Counter target instant or sorcery spell."
      # The target is a spell on the stack.
      class CounterSpell < Data.define(:types)
        include Effect

        LINE = /\ACounter target (?:(?<types>[\w-]+(?: or [\w-]+)?) )?spell\.?\z/i

        def self.parse(text)
          new(types: $~[:types]&.downcase&.split(" or ") || []) if LINE.match(text)
        end

        def target_choices
          return "game.stack.spells" if types.empty?

          checks = types.map do |type|
            type.start_with?("non") ? "!_1.card.type?(#{capitalize(type.delete_prefix('non')).inspect})" : "_1.card.type?(#{capitalize(type).inspect})"
          end
          "game.stack.spells.select { #{checks.join(' || ')} }"
        end

        def resolve_call = "trigger_effect(:counter_spell, target: target)"

        private

        def capitalize(type) = type[0].upcase + type[1..]
      end
    end
  end
end
