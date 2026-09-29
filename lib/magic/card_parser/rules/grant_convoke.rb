# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "Creature spells you cast have convoke." (also "Spells you cast have convoke."): a static
      # ability answering `grants_convoke?(card, player)`, which `Actions::Cast#convoke` accepts.
      class GrantConvoke < Data.define(:types)
        include Rule

        LINE = /\A(?:(?<types>[\w-]+(?: and [\w-]+)?) )?spells you cast have convoke\.?\z/i

        def self.parse(line)
          new(types: $~[:types]&.downcase&.split(" and ") || []) if LINE.match(line)
        end

        def kinds = PERMANENT_KINDS
        def hook = :static_abilities
        def class_base_name = "GrantConvoke"

        def class_source(name)
          <<~RUBY
            class #{name} < StaticAbility
              def grants_convoke?(card, player) = player == controller && (#{condition})
            end
          RUBY
        end

        private

        def condition
          return "true" if types.empty?

          types.map do |type|
            name = type.delete_prefix("non").then { _1[0].upcase + _1[1..] }
            type.start_with?("non") ? "!card.type?(#{name.inspect})" : "card.type?(#{name.inspect})"
          end.join(" || ")
        end
      end
    end
  end
end
