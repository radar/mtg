# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Create a 1/1 white Human Warrior creature token."
      # "Create two 1/1 colorless Thopter artifact creature tokens with flying."
      # "Target player creates a 1/1 green and white Kithkin creature token."
      class CreateToken < Data.define(:amount, :power, :toughness, :colors, :subtypes, :artifact, :keywords, :changeling, :who)
        include Effect

        def initialize(changeling: false, who: nil, **fields) = super

        COLORS = %w[white blue black red green].freeze
        LINE = %r{\A(?:(?<who>Target player|Target opponent) creates|Create) (?<amount>\w+) (?<power>\d+)/(?<toughness>\d+) (?<colors>colorless|[a-z]+(?: and [a-z]+)?) (?<subtypes>(?:[A-Z][\w-]* )+)(?<artifact>artifact )?creature tokens?(?: with (?<keywords>[\w ,]+?))?\.?\z}

        def self.parse(text)
          return unless (m = LINE.match(text))

          colors = m[:colors] == "colorless" ? [] : m[:colors].split(" and ")
          return unless (colors - COLORS).empty?

          words = m[:keywords].to_s.split(/,? and |, /)
          changeling = !words.delete("changeling").nil?
          keywords = words.any? ? Rules::Keywords.parse(words.join(", ")) : Rules::Keywords.new(keywords: [])
          return unless keywords

          new(amount: Number.parse(m[:amount]), power: m[:power].to_i, toughness: m[:toughness].to_i,
              colors: colors.map(&:to_sym), subtypes: m[:subtypes].strip, artifact: !m[:artifact].nil?,
              keywords: keywords.keywords, changeling: changeling, who: m[:who]&.downcase)
        end

        def target_choices = { "target player" => "game.players", "target opponent" => "game.opponents(controller)" }[who]

        def token_const = "#{CardGenerator.const_name(subtypes)}Token"

        def resolve_call
          amount_arg = amount == 1 ? "" : ", amount: #{amount}"
          controller_arg = who ? ", controller: target" : ""
          "trigger_effect(:create_token, token_class: #{token_const}#{amount_arg}#{controller_arg})"
        end

        def definitions
          lines = ["#{artifact ? 'artifact_creature_type' : 'creature_type'} #{subtypes.inspect}", "power #{power}", "toughness #{toughness}"]
          lines << "colors #{colors.map(&:inspect).join(', ')}" if colors.any?
          all_keywords = changeling ? [*keywords, :changeling] : keywords
          lines << "keywords #{all_keywords.map(&:inspect).join(', ')}" if all_keywords.any?
          "#{token_const} = Token.create #{subtypes.inspect} do\n#{lines.map { "  #{_1}\n" }.join}end\n"
        end
      end
    end
  end
end
