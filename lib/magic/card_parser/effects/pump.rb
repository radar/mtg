# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # Until end of turn: "~ gets +1/+0", "Target creature gets +2/+2 and gains
      # trample", "[Other] creatures you control gain flying and haste", "It gains
      # haste" (an earlier target), "Target creature gets +1/+1 for each Elf you
      # control" (the count, `per`, may also follow "until end of turn"; it's
      # taken once, as the effect resolves), "Creatures target player controls get +1/+1".
      class Pump < Data.define(:who, :reference, :power, :toughness, :per, :keywords, :until_next_turn)
        include Effect

        WHO = /(?:(?<self>~)|(?<each>(?:other )?creatures you control)|(?<player_creatures>creatures target player controls)|(?<opponent_creatures>creatures your opponents control)|#{PermanentTarget::REFERENCE})/i
        KEYWORDS = /[\w ,]+?/
        PER = /[^.]+?/
        LINE = %r{\A#{WHO} (?:gets? (?<power>[+-](?:\d+|X))/(?<toughness>[+-](?:\d+|X))(?: for each (?<per>#{PER}))?(?: and gains? (?<with>#{KEYWORDS}))?|gains? (?<only>#{KEYWORDS})) (?<duration>until end of turn|until your next turn)(?: for each (?<per_after>#{PER}))?\.?\z}i

        def initialize(who:, reference:, power:, toughness:, per:, keywords:, until_next_turn: false) = super

        def self.parse(text)
          # "Until end of turn, creatures you control get +1/+1 and gain haste." (duration first)
          text = "#{$~[:rest]} until end of turn" if /\AUntil end of turn, (?<rest>.+?)\.?\z/i.match(text)
          return unless (m = LINE.match(text))

          until_next_turn = m[:duration].downcase == "until your next turn"
          # "Until your next turn" is only supported for a plain power/toughness change.
          return if until_next_turn && (m[:with] || m[:only] || m[:per] || m[:per_after] || !m[:power])
          return if m[:kind] && !PermanentTarget.creature?(m)
          return if [m[:power], m[:toughness]].any? { _1&.end_with?("X") } && !Number.x_bound?

          keywords = []
          if (phrase = m[:with] || m[:only])
            keywords = Rules::Keywords.phrase(phrase) or return
          end
          if (phrase = m[:per] || m[:per_after])
            return unless m[:power] && (per = Count.parse(phrase, this: THIS))
          end
          who = m[:self] ? :self : m[:each]&.downcase || (:player_creatures if m[:player_creatures]) || (:opponent_creatures if m[:opponent_creatures]) || :target
          reference = PermanentTarget.reference(m) if who == :target
          new(who:, reference:, power: stat(m[:power]), toughness: stat(m[:toughness]), per:,
              keywords:, until_next_turn:)
        end

        # "+2" -> 2, "+X" -> the Ruby for X, "-X" -> its negation.
        def self.stat(text)
          return text&.to_i unless text&.end_with?("X")

          text.start_with?("-") ? "-(#{Number.parse('X')})" : Number.parse("X")
        end

        def target_choices = who == :player_creatures ? "game.players" : reference&.choices
        def earlier_target? = !!reference&.earlier_target?

        def resolve_call
          case who
          when :self then calls(THIS)
          when :target then calls(reference.object)
          when :player_creatures then each("target.creatures")
          when :opponent_creatures then each("battlefield.not_controlled_by(controller).creatures")
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
          return 0 if value.respond_to?(:zero?) && value.zero?

          value == 1 ? per : "#{value} * #{per}"
        end

        def calls(target)
          lines = []
          if power && until_next_turn
            lines << "#{target}.modify_power_toughness_until_turn_of!(controller, #{power}, #{toughness})"
          elsif power
            lines << "trigger_effect(:modify_power_toughness, target: #{target}, power: #{amount(power)}, toughness: #{amount(toughness)})"
          end
          keywords.each { lines << "trigger_effect(:grant_keyword, target: #{target}, keyword: #{_1.inspect})" }
          lines.join("\n")
        end
      end
    end
  end
end
