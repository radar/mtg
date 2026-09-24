# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "~ becomes a 4/4 artifact creature until end of turn." / "~ becomes a 3/3
      # Elemental creature with haste until end of turn. It's still a land."
      class BecomeCreature < Data.define(:power, :toughness, :types, :keywords)
        include Effect

        CARD_TYPES = { "artifact" => "T::Artifact", "enchantment" => "T::Enchantment", "land" => "T::Land" }.freeze
        LINE = %r{\A~ becomes an? (?<power>\d+)/(?<toughness>\d+) (?<types>(?:[\w-]+ )*?)creature(?: with (?<keywords>[\w ,]+?))? until end of turn\.?(?: It's still an? [\w ]+\.)?\z}i

        def self.parse(text)
          return unless (m = LINE.match(text))

          types = m[:types].split.map do |word|
            next CARD_TYPES[word.downcase] if CARD_TYPES.key?(word.downcase)
            next "T::Creatures[#{word.inspect}]" if Types::Creatures.values.include?(word)
          end
          return if types.any?(&:nil?)

          keywords = m[:keywords] ? Rules::Keywords.phrase(m[:keywords]) : []
          new(power: m[:power].to_i, toughness: m[:toughness].to_i, types:, keywords:) if keywords
        end

        def resolve_call
          lines = ["#{THIS}.become_creature!(power: #{power}, toughness: #{toughness}, types: [#{types.join(', ')}])"]
          keywords.each { lines << "trigger_effect(:grant_keyword, target: #{THIS}, keyword: #{_1.inspect})" }
          lines.join("\n")
        end
      end
    end
  end
end
