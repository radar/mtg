# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Create a 1/1 white Human Warrior creature token."
      # "Create two 1/1 colorless Thopter artifact creature tokens with flying."
      # "Target player creates a 1/1 green and white Kithkin creature token."
      # "Create a tapped 1/1 black Rat creature token for each creature card in your graveyard."
      # "Create a number of 1/1 white Rabbit creature tokens equal to the number of other creatures you control named ~."
      # "Create four 3/3 blue Serpent creature tokens named Koma's Coil."
      # "Create Scion of the Deep, a legendary 8/8 blue Octopus creature token."
      # "Create X 1/1 red Goblin creature tokens. They gain haste until end of turn."
      # "Create two 1/1 black Rat creature tokens with "This token can't block.""
      class CreateToken < Data.define(:amount, :power, :toughness, :colors, :subtypes, :artifact, :keywords, :changeling, :who, :tapped, :legendary, :token_name, :haste_until_eot, :cant_block)
        include Effect

        def initialize(changeling: false, who: nil, tapped: false, legendary: false, token_name: nil, haste_until_eot: false, cant_block: false, **fields) = super

        COLORS = %w[white blue black red green].freeze
        LINE = %r{\A(?:(?<who>Target player|Target opponent) creates|[Cc]reate) (?:(?<given_name>[A-Z][\w' ]*?), an?|(?<amount>a number of|\w+)) (?<tapped>tapped )?(?<legendary>legendary )?(?<power>\d+)/(?<toughness>\d+) (?<colors>colorless|[a-z]+(?: and [a-z]+)?) (?<subtypes>(?:[A-Z][\w-]* )+)(?<artifact>artifact )?creature tokens?(?: named (?<name>[^.]+?))?(?: with (?<keywords>[\w ,]+?))?(?: with "(?<ability>This token can't block\.)")?(?<tail> for each [^.]+| equal to [^.]+)?(?<haste>\. They gain haste until end of turn)?\.?\z}

        def self.parse(text)
          return unless (m = LINE.match(text))

          colors = m[:colors] == "colorless" ? [] : m[:colors].split(" and ")
          return unless (colors - COLORS).empty?

          words = m[:keywords].to_s.split(/,? and |, /)
          changeling = !words.delete("changeling").nil?
          keywords = words.any? ? Rules::Keywords.parse(words.join(", ")) : Rules::Keywords.new(keywords: [])
          return unless keywords

          amount = amount_of(m) or return
          new(amount:, power: m[:power].to_i, toughness: m[:toughness].to_i,
              colors: colors.map(&:to_sym), subtypes: m[:subtypes].strip, artifact: !m[:artifact].nil?,
              keywords: keywords.keywords, changeling: changeling, who: m[:who]&.downcase,
              tapped: !m[:tapped].nil?, legendary: !m[:legendary].nil?, token_name: m[:given_name] || m[:name],
              haste_until_eot: !m[:haste].nil?, cant_block: !m[:ability].nil?)
        end

        # "two" / "X" / "a number of ... equal to <count>" / "a ... for each <count>" -> an Integer or Ruby.
        def self.amount_of(m)
          tail = m[:tail].to_s.strip
          return Number.parse(m[:amount] || "a") if tail.empty?

          count = Count.parse(tail.sub(/\A(?:for each|equal to) /, ""), this: Effect::THIS) or return
          if tail.start_with?("for each")
            n = Number.parse(m[:amount] || "a")
            n == 1 ? count : "#{n} * #{count}"
          elsif m[:amount] == "a number of"
            count
          end
        end

        def target_choices = { "target player" => "game.players", "target opponent" => "game.opponents(controller)" }[who]

        def token_const = "#{CardGenerator.const_name(token_name || subtypes)}Token"

        def resolve_call
          args = ["token_class: #{token_const}"]
          args << "amount: #{amount}" unless amount == 1
          args << "controller: target" if who
          args << "enters_tapped: true" if tapped
          call = "trigger_effect(:create_token, #{args.join(', ')})"
          return call unless haste_until_eot

          "Array(#{call}).each { |token| trigger_effect(:grant_keyword, target: token, keyword: :haste) }"
        end

        def definitions
          type_macro = if artifact then "artifact_creature_type"
                       elsif legendary then "legendary_creature_type"
                       else "creature_type"
                       end
          lines = ["#{type_macro} #{subtypes.inspect}", "power #{power}", "toughness #{toughness}"]
          lines << "colors #{colors.map(&:inspect).join(', ')}" if colors.any?
          all_keywords = changeling ? [*keywords, :changeling] : keywords
          lines << "keywords #{all_keywords.map(&:inspect).join(', ')}" if all_keywords.any?
          lines << "def can_block?(_) = false" if cant_block
          "#{token_const} = Token.create #{(token_name || subtypes).inspect} do\n#{lines.map { "  #{_1}\n" }.join}end\n"
        end
      end
    end
  end
end
