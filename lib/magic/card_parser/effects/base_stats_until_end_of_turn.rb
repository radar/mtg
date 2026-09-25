# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Choose up to one other target creature. Until end of turn, that creature has base power
      # and toughness 4/4 and gains all creature types." An optional target (up to one, so it can
      # be skipped and never auto-resolves), spanning two sentences.
      class BaseStatsUntilEndOfTurn < Data.define(:other, :power, :toughness, :all_types)
        include Effect

        LINE = %r{\A(?:Choose )?up to one (?<other>other |another )?target creature\. Until end of turn, that creature has base power and toughness (?<power>\d+)/(?<toughness>\d+)(?<all_types> and gains all creature types)?\.?\z}i

        def self.parse(text)
          return unless (m = LINE.match(text))

          new(other: !m[:other].nil?, power: m[:power].to_i, toughness: m[:toughness].to_i, all_types: !m[:all_types].nil?)
        end

        def optional_target? = true

        def target_choices = other ? "(battlefield.creatures - [#{THIS}])" : "battlefield.creatures"

        def resolve_call
          lines = ["target.modify_base_power(#{power})", "target.modify_base_toughness(#{toughness})"]
          lines << "target.add_types(*Magic::Types::Creatures.values)" if all_types
          lines.join("\n")
        end
      end
    end
  end
end
