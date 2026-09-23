# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # Until end of turn: "~ gets +1/+0", "Target creature gets +2/+2 and gains
      # trample", "[Other] creatures you control gain flying and haste".
      class Pump < Data.define(:who, :targets, :power, :toughness, :keywords)
        include Effect

        WHO = /(?:(?<self>~)|(?<each>(?:other )?creatures you control)|#{PermanentTarget::PATTERN})/i
        KEYWORDS = /[\w ,]+?/
        LINE = %r{\A#{WHO} (?:gets? (?<power>[+-]\d+)/(?<toughness>[+-]\d+)(?: and gains? (?<with>#{KEYWORDS}))?|gains? (?<only>#{KEYWORDS})) until end of turn\.?\z}i

        def self.parse(text)
          return unless (m = LINE.match(text))
          return if m[:kind] && m[:kind].downcase != "creature"

          keywords = []
          if (phrase = m[:with] || m[:only])
            keywords = Rules::Keywords.phrase(phrase) or return
          end
          who = m[:self] ? :self : m[:each]&.downcase || :target
          new(who:, targets: m[:kind] && PermanentTarget.choices(m), power: m[:power]&.to_i, toughness: m[:toughness]&.to_i, keywords:)
        end

        def target_choices = who == :target ? targets : nil

        def resolve_call
          case who
          when :self then calls(THIS)
          when :target then calls("target")
          when "creatures you control" then each("battlefield.controlled_by(controller).creatures")
          else each("(battlefield.controlled_by(controller).creatures - [#{THIS}])")
          end
        end

        private

        def each(collection)
          lines = calls("creature").lines
          return "#{collection}.each { |creature| #{lines.first.chomp} }" if lines.one?

          "#{collection}.each do |creature|\n#{lines.map { "  #{_1}" }.join.chomp}\nend"
        end

        def calls(target)
          lines = []
          lines << "trigger_effect(:modify_power_toughness, target: #{target}, power: #{power}, toughness: #{toughness})" if power
          keywords.each { lines << "trigger_effect(:grant_keyword, target: #{target}, keyword: #{_1.inspect})" }
          lines.join("\n")
        end
      end
    end
  end
end
