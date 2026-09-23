# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # "Enchant creature", "Enchant creature you control", "Enchant land"
      class Enchant < Data.define(:kind, :you_control)
        include Rule

        LINE = /\AEnchant (?<kind>creature|land|artifact) ?(?<yours>you control)?\z/i
        COLLECTIONS = { "Creature" => "creatures", "Land" => "lands", "Artifact" => "artifacts" }.freeze

        def self.parse(line)
          return unless (m = LINE.match(line))

          new(kind: m[:kind].capitalize, you_control: !m[:yours].nil?)
        end

        def body_source
          scope = you_control ? "battlefield.controlled_by(controller)" : "battlefield"
          option = you_control ? ", you_control: true" : ""
          <<~RUBY
            enchant #{kind.inspect}#{option}

            def target_choices
              #{scope}.#{COLLECTIONS.fetch(kind)}
            end
          RUBY
        end
      end
    end
  end
end
