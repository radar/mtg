# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "Creature spells you cast cost {1} less to cast." / "Spells you cast cost
      # {1} less to cast." / "Instant and sorcery spells you cast cost {1} less to
      # cast." / "Noncreature spells ..." A ManaCostAdjustment static ability.
      class CostReduction < Data.define(:types, :amount)
        include Rule

        LINE = /\A(?:(?<types>[\w-]+(?: and [\w-]+)?) )?spells you cast cost \{(?<amount>\d+)\} less to cast\.?\z/i

        def self.parse(line)
          return unless (m = LINE.match(line))

          new(types: m[:types]&.downcase&.split(" and ") || [], amount: m[:amount].to_i)
        end

        def kinds = PERMANENT_KINDS
        def hook = :static_abilities
        def class_base_name = "CostReduction"

        def class_source(name)
          <<~RUBY
            class #{name} < Abilities::Static::ManaCostAdjustment
              def initialize(source:)
                super(source:, adjustment: { generic: -#{amount} }, applies_to: ->(card) { #{condition} })
              end
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
