# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Create a 1/1 white Soldier creature token." / "Create two 1/1 green Elf
      # Warrior creature tokens with haste." Defines the token class alongside.
      class CreateToken < Data.define(:amount, :power, :toughness, :colors, :creature_types, :keywords)
        include Effect

        COLORS = %w[white blue black red green].freeze
        LINE = %r{\ACreate (?<amount>\d+|\w+) (?<power>\d+)/(?<toughness>\d+) (?<colors>colorless|(?:#{COLORS.join('|')})(?: and (?:#{COLORS.join('|')}))?) (?<types>[A-Z][\w ]*?) creature tokens?(?: with (?<keywords>[\w ,]+?))?\.?\z}

        def self.parse(text)
          return unless (m = LINE.match(text))

          keywords = m[:keywords].to_s.split(/,\s*(?:and\s+)?|\s+and\s+/).map { _1.strip.tr(" ", "_").to_sym }
          return unless keywords.all? { Magic::Cards::Keywords.const_defined?(_1.upcase) }

          colors = m[:colors] == "colorless" ? [] : m[:colors].split(" and ").map(&:to_sym)
          new(amount: Number.parse(m[:amount]), power: m[:power].to_i, toughness: m[:toughness].to_i, colors:,
              creature_types: m[:types], keywords:)
        end

        def token_class = "#{CardGenerator.const_name(creature_types)}Token"

        def definitions
          lines = ["creature_type #{creature_types.inspect}", "power #{power}", "toughness #{toughness}"]
          lines << "colors #{colors.map(&:inspect).join(', ')}" if colors.any?
          lines << "keywords #{keywords.map(&:inspect).join(', ')}" if keywords.any?
          ["#{token_class} = Token.create(#{creature_types.inspect}) do\n#{lines.map { "  #{_1}\n" }.join}end\n"]
        end

        def resolve_call
          "trigger_effect(:create_token, token_class: #{token_class}, amount: #{amount})"
        end
      end
    end
  end
end
