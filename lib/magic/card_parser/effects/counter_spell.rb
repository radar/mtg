# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Counter target spell." / "Counter target creature spell." / "Counter target
      # noncreature spell." / "Counter target instant or sorcery spell." / "Counter target
      # spell with mana value 2." The target is a spell on the stack.
      class CounterSpell < Data.define(:types, :mana_value)
        include Effect

        LINE = /\ACounter target (?:(?<types>[\w-]+(?: or [\w-]+)?) )?spell(?: with mana value (?<mana_value>\d+))?\.?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text))

          new(types: m[:types]&.downcase&.split(" or ") || [], mana_value: m[:mana_value]&.to_i)
        end

        def target_choices
          filters = []
          unless types.empty?
            checks = types.map do |type|
              type.start_with?("non") ? "!_1.card.type?(#{capitalize(type.delete_prefix('non')).inspect})" : "_1.card.type?(#{capitalize(type).inspect})"
            end
            filters << checks.join(" || ")
          end
          filters << "_1.card.mana_value == #{mana_value}" if mana_value
          filters.empty? ? "game.stack.spells" : "game.stack.spells.select { #{filters.join(' && ')} }"
        end

        def resolve_call = "trigger_effect(:counter_spell, target: target)"

        private

        def capitalize(type) = type[0].upcase + type[1..]
      end
    end
  end
end
