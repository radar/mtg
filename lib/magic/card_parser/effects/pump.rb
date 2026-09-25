# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # Until end of turn: "~ gets +1/+0", "Target creature gets +2/+2 and gains
      # trample", "[Other] creatures you control gain flying and haste", "It gains
      # haste" (an earlier target), "Target creature gets +1/+1 for each Elf you
      # control" (the count, `per`, may also follow "until end of turn"; it's
      # taken once, as the effect resolves).
      class Pump < Data.define(:who, :reference, :power, :toughness, :per, :keywords)
        include Effect

        WHO = /(?:(?<self>~)|(?<each>(?:other )?creatures you control)|#{PermanentTarget::REFERENCE})/i
        KEYWORDS = /[\w ,]+?/
        PER = /[^.]+?/
        LINE = %r{\A#{WHO} (?:gets? (?<power>[+-]\d+)/(?<toughness>[+-]\d+)(?: for each (?<per>#{PER}))?(?: and gains? (?<with>#{KEYWORDS}))?|gains? (?<only>#{KEYWORDS})) until end of turn(?: for each (?<per_after>#{PER}))?\.?\z}i

        def self.parse(text)
          return unless (m = LINE.match(text))
          return if m[:kind] && !PermanentTarget.creature?(m)

          keywords = []
          if (phrase = m[:with] || m[:only])
            keywords = Rules::Keywords.phrase(phrase) or return
          end
          if (phrase = m[:per] || m[:per_after])
            return unless m[:power] && (per = Count.parse(phrase, this: THIS))
          end
          who = m[:self] ? :self : m[:each]&.downcase || :target
          reference = PermanentTarget.reference(m) if who == :target
          new(who:, reference:, power: m[:power]&.to_i, toughness: m[:toughness]&.to_i, per:,
              keywords:)
        end

        def target_choices = reference&.choices
        def earlier_target? = !!reference&.earlier_target?

        def resolve_call
          case who
          when :self then calls(THIS)
          when :target then calls(reference.object)
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

        # A fixed amount, or so many for each of `per`.
        def amount(value)
          return value unless per
          return 0 if value.zero?

          value == 1 ? per : "#{value} * #{per}"
        end

        def calls(target)
          lines = []
          lines << "trigger_effect(:modify_power_toughness, target: #{target}, power: #{amount(power)}, toughness: #{amount(toughness)})" if power
          keywords.each { lines << "trigger_effect(:grant_keyword, target: #{target}, keyword: #{_1.inspect})" }
          lines.join("\n")
        end
      end
    end
  end
end
