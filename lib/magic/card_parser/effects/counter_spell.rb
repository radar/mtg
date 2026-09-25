# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Counter target spell." / "Counter target creature spell." / "Counter target noncreature
      # spell." / "Counter target spell with mana value 2." Targets are the spells (Actions::Cast)
      # on the stack.
      class CounterSpell < Data.define(:kind, :mana_value)
        include Effect

        LINE = /\ACounter target (?:(?<kind>non\w+|\w+) )?spell(?: with mana value (?<mana_value>\d+))?\.?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text))

          new(kind: m[:kind]&.downcase, mana_value: m[:mana_value]&.to_i)
        end

        def target_choices
          filters = []
          filters << (kind.start_with?("non") ? "!_1.card.type?(#{kind.delete_prefix('non').capitalize.inspect})" : "_1.card.type?(#{kind.capitalize.inspect})") if kind
          filters << "_1.card.mana_value == #{mana_value}" if mana_value
          filters.empty? ? "game.stack.spells" : "game.stack.spells.select { #{filters.join(' && ')} }"
        end

        def resolve_call = "trigger_effect(:counter_spell, target: target)"
      end
    end
  end
end
