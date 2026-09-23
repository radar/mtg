# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Create a 1/1 white Human Warrior creature token."
      # "Create two 1/1 colorless Thopter artifact creature tokens with flying."
      class CreateToken < Data.define(:amount, :power, :toughness, :colors, :subtypes, :artifact, :keywords)
        include Effect

        COLORS = %w[white blue black red green].freeze
        LINE = %r{\ACreate (?<amount>\w+) (?<power>\d+)/(?<toughness>\d+) (?<colors>colorless|[a-z]+(?: and [a-z]+)?) (?<subtypes>(?:[A-Z][\w-]* )+)(?<artifact>artifact )?creature tokens?(?: with (?<keywords>[\w ,]+?))?\.?\z}

        def self.parse(text)
          return unless (m = LINE.match(text))

          colors = m[:colors] == "colorless" ? [] : m[:colors].split(" and ")
          return unless (colors - COLORS).empty?

          keywords = m[:keywords] ? Rules::Keywords.parse(m[:keywords].sub(/,? and /, ", ")) : Rules::Keywords.new(keywords: [])
          return unless keywords

          new(amount: Number.parse(m[:amount]), power: m[:power].to_i, toughness: m[:toughness].to_i,
              colors: colors.map(&:to_sym), subtypes: m[:subtypes].strip, artifact: !m[:artifact].nil?,
              keywords: keywords.keywords)
        end

        def token_const = "#{CardGenerator.const_name(subtypes)}Token"

        def resolve_call
          amount_arg = amount == 1 ? "" : ", amount: #{amount}"
          "trigger_effect(:create_token, token_class: #{token_const}#{amount_arg})"
        end

        def definitions
          lines = ["#{artifact ? 'artifact_creature_type' : 'creature_type'} #{subtypes.inspect}", "power #{power}", "toughness #{toughness}"]
          lines << "colors #{colors.map(&:inspect).join(', ')}" if colors.any?
          lines << "keywords #{keywords.map(&:inspect).join(', ')}" if keywords.any?
          "#{token_const} = Token.create #{subtypes.inspect} do\n#{lines.map { "  #{_1}\n" }.join}end\n"
        end
      end
    end
  end
end
