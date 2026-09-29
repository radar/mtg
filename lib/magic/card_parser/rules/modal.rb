# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # A modal instant or sorcery: a "Choose one —" line and a "• <effects>" line
      # per mode, merged into one rule that generates a Mode class per bullet and
      # `modes Mode1, Mode2, ...` and `choose_modes <count>`. The caster picks modes with
      # `choose_mode`; `Actions::Cast` enforces the count.
      #
      # "When ~ enters, choose one —" plus bullets is the same rule as an enters trigger
      # (`trigger: true`): each bullet becomes a trigger class of its own, and the trigger
      # queues a `ModeChoice` whose `resolve!(mode: index)` runs the chosen one. Only "choose
      # one" works there.
      class Modal < Data.define(:choose, :modes, :trigger)
        include Rule

        HEADER = /\A(?:(?<trigger>When(?:ever)? ~ enters), )?[Cc]hoose (?<choose>one|one or both|one or more|two) [—-]\z/
        BULLET = /\A• (?<text>.+)\z/

        def self.parse(line)
          if (m = HEADER.match(line))
            new(choose: m[:choose], modes: [], trigger: !m[:trigger].nil?)
          elsif (m = BULLET.match(line)) && (effect_list = EffectList.parse(m[:text]))
            new(choose: nil, modes: [effect_list], trigger: false)
          end
        end

        def self.merge(rules)
          headers = rules.select(&:choose)
          raise ParseError, "modal spell needs one \"Choose ... —\" line" unless headers.one?

          modes = rules.flat_map(&:modes)
          raise ParseError, "modal spell needs at least two • modes" if modes.size < 2
          raise UnsupportedCard, "a modal enters trigger only supports \"choose one\"" if headers.first.trigger && headers.first.choose != "one"

          [new(choose: headers.first.choose, modes:, trigger: headers.first.trigger)]
        end

        def kinds = trigger ? PERMANENT_KINDS : %i[instant sorcery]
        def hook = (:etb_triggers if trigger)
        def class_base_name = ("EntersTrigger" if trigger)

        # "one" => 1, "two" => 2, "one or both" => 1..2, "one or more" => 1..<modes>
        def mode_count
          case choose
          when "one" then "1"
          when "two" then "2"
          when "one or both" then "1..2"
          when "one or more" then "1..#{modes.size}"
          end
        end

        def body_source
          return if trigger

          classes = modes.each_with_index.map do |effect_list, index|
            body = effect_list.spell_source(this: "card").gsub(/^(?=.)/, "  ")
            "class Mode#{index + 1} < Mode\n#{body}end\n"
          end
          [*classes, "modes #{(1..modes.size).map { "Mode#{_1}" }.join(', ')}\nchoose_modes #{mode_count}\n"].join("\n")
        end

        def class_source(name)
          return unless trigger

          mode_classes = modes.each_with_index.map do |effect_list, index|
            "class Mode#{index + 1} < TriggeredAbility::EnterTheBattlefield\n#{effect_list.trigger_source.gsub(/^(?=.)/, '  ')}end\n"
          end
          names = (1..modes.size).map { "Mode#{_1}" }.join(", ")
          body = [*mode_classes, <<~RUBY]
            MODES = [#{names}].freeze

            class ModeChoice < Magic::Choice
              def initialize(actor:, trigger:)
                super(actor:)
                @trigger = trigger
              end

              def choices = MODES.each_index.to_a

              def resolve!(mode:)
                MODES.fetch(mode).new(event: @trigger.event, actor:).call
              end
            end

            def call
              game.choices.add(ModeChoice.new(actor:, trigger: self))
            end
          RUBY
          "class #{name} < TriggeredAbility::EnterTheBattlefield\n#{body.join("\n").gsub(/^(?=.)/, '  ')}end\n"
        end
      end
    end
  end
end
