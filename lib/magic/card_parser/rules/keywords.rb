# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # A line of keywords: "Flying, first strike" => keywords :flying, :first_strike.
      #
      # Keywords with a value become their own DSL call:
      #
      #   Toxic 1 / Hexproof from blue        -> keywords Keywords::Toxic.new(1), ...
      #   Ward {2} / Ward—Pay 3 life          -> ward generic: 2 / ward life: 3
      #   Protection from red and from blue   -> protections [Protection.from_color(:red), ...]
      #   Kicker {1}{G}                       -> kicker_cost generic: 1, green: 1
      #   Flashback {2}{R}                    -> flashback Costs::Mana.new(generic: 2, red: 1)
      #   Cycling {2}                         -> cycling generic: 2
      class Keywords < Data.define(:keywords, :extras)
        include Rule

        KNOWN = %w[deathtouch defender double_strike first_strike flash flying haste hexproof indestructible
                   infect lifelink menace prowess reach shroud skulk trample vigilance].freeze
        COLORS = %w[white blue black red green].freeze
        CARD_TYPES = { "artifacts" => "Artifact", "creatures" => "Creature", "enchantments" => "Enchantment",
                       "instants" => "Instant", "sorceries" => "Sorcery", "planeswalkers" => "Planeswalker",
                       "lands" => "Land" }.freeze
        MANA = /(?:\{[^}]+\})+/

        def initialize(keywords:, extras: []) = super

        def self.parse(line)
          parsed = line.split(",").map { keyword(_1.strip) }
          return if parsed.any?(&:nil?)

          new(keywords: parsed.grep_v(Extra), extras: parsed.grep(Extra))
        end

        # One DSL call for a keyword that has a value (ward, protection, kicker...).
        Extra = Data.define(:dsl_line)

        # A keyword as a Symbol, a Ruby expression (String) for a keyword object, or an Extra.
        def self.keyword(text)
          simple = text.downcase.tr(" ", "_")
          return simple.to_sym if KNOWN.include?(simple)

          case text
          when /\AToxic (?<amount>\d+)\z/i
            "Keywords::Toxic.new(#{$~[:amount]})"
          when /\AHexproof from (?<color>#{COLORS.join('|')})\z/i
            "Keywords::HexproofFrom.new(:#{$~[:color].downcase})"
          when /\AWard (?<cost>\{\d+\})\z/i
            Extra.new("ward generic: #{ManaCost.parse($~[:cost])[:generic]}")
          when /\AWard[—-]Pay (?<life>\d+) life\.?\z/i
            Extra.new("ward life: #{$~[:life]}")
          when /\AProtection from (?<qualities>.+)\z/i
            protections($~[:qualities])
          when /\AKicker (?<cost>#{MANA})\z/i
            Extra.new("kicker_cost #{cost_hash($~[:cost])}")
          when /\AFlashback (?<cost>#{MANA})\z/i
            Extra.new("flashback Costs::Mana.new(#{cost_hash($~[:cost])})")
          when /\ACycling (?<cost>#{MANA})\z/i
            Extra.new("cycling #{cost_hash($~[:cost])}")
          end
        end

        # "red", "red and from blue", "multicolored", "creatures" -> a protections call, or nil.
        def self.protections(text)
          protections = text.split(/\s+and from\s+/i).map do |quality|
            quality = quality.downcase
            if COLORS.include?(quality)
              "Protection.from_color(:#{quality})"
            elsif quality == "multicolored"
              "Protection.new(condition: -> (card) { card.multi_colored? })"
            elsif (type = CARD_TYPES[quality])
              "Protection.new(condition: -> (card) { card.type?(#{type.inspect}) })"
            end
          end
          Extra.new("protections [#{protections.join(', ')}]") if protections.none?(&:nil?)
        end

        def self.cost_hash(cost) = ManaCost.parse(cost).map { |color, amount| "#{color}: #{amount}" }.join(", ")

        # "flying", "flying and first strike", "flying, trample, and haste" =>
        # [:flying, ...], or nil unless every word is a known keyword.
        def self.phrase(text)
          words = text.split(/,\s*(?:and\s+)?|\s+and\s+/).map { _1.strip.downcase.tr(" ", "_") }
          words.map(&:to_sym) if words.any? && words.all? { KNOWN.include?(_1) }
        end

        def self.merge(rules)
          return [] if rules.empty?

          extras = rules.flat_map(&:extras)
          %w[ward protections kicker_cost flashback cycling].each do |call|
            raise UnsupportedCard, "more than one #{call}" if extras.count { _1.dsl_line.start_with?("#{call} ") } > 1
          end
          [new(keywords: rules.flat_map(&:keywords), extras:)]
        end

        def dsl_lines
          lines = keywords.empty? ? [] : ["keywords #{keywords.map { _1.is_a?(Symbol) ? _1.inspect : _1 }.join(', ')}"]
          lines + extras.map(&:dsl_line)
        end
      end
    end
  end
end
