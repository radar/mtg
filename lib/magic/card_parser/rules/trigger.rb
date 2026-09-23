# frozen_string_literal: true

module Magic
  class CardParser
    module Rules
      # A triggered ability: "<trigger condition>, <effects>". Each kind of
      # trigger is a row in KINDS; the effects are anything EffectList parses.
      #
      #   When ~ enters, draw a card.
      #   Landfall — Whenever a land you control enters, you gain 1 life.
      #   Whenever you cast an instant or sorcery spell, scry 1.
      #   Whenever another creature you control dies, you may draw a card.
      class Trigger < Data.define(:kind, :condition, :effect_list)
        include Rule

        # hook: where the trigger class is listed (an event handler, or a
        # lifecycle list); condition: Ruby for should_perform?, or nil to keep
        # the base class's (a String, or a Proc taking the match).
        Kind = Data.define(:pattern, :name, :base, :hook, :event, :condition, :kinds)

        # Whose creature dying triggers "Whenever <who> dies" -> should_perform?
        CREATURE_DIES = {
          "another creature you control" => "you? && event.permanent != actor",
          "a creature you control" => "you?",
          "a creature an opponent controls" => "opponent?",
          "another creature" => "event.permanent != actor",
          "a creature" => nil
        }.freeze
        ENTERS_UNDER_YOUR_CONTROL = "(?:you control enters|enters(?: the battlefield)? under your control)"
        KINDS = [
          Kind.new(/When ~ enters(?: the battlefield)?/, "EntersTrigger", "TriggeredAbility::EnterTheBattlefield",
                   :etb_triggers, nil, nil, PERMANENT_KINDS),
          Kind.new(/When ~ dies/, "DiesTrigger", "TriggeredAbility::Death", :death_triggers, nil, nil, %i[creature]),
          Kind.new(/When ~ leaves the battlefield/, "LeavesTrigger", "TriggeredAbility::LeaveTheBattlefield",
                   :ltb_triggers, nil, nil, PERMANENT_KINDS),
          Kind.new(/Whenever (?<who>#{CREATURE_DIES.keys.join('|')}) dies/, "CreatureDiesTrigger", "TriggeredAbility",
                   :event_handlers, "Events::CreatureDied", ->(m) { CREATURE_DIES.fetch(m[:who]) }, PERMANENT_KINDS),
          Kind.new(/Whenever another creature #{ENTERS_UNDER_YOUR_CONTROL}/, "CreatureEntersTrigger",
                   "TriggeredAbility::EnterTheBattlefield", :event_handlers, "Events::EnteredTheBattlefield",
                   "another_creature? && under_your_control?", PERMANENT_KINDS),
          Kind.new(/Whenever a land #{ENTERS_UNDER_YOUR_CONTROL}/, "LandfallTrigger", "TriggeredAbility::Landfall",
                   :event_handlers, "Events::Landfall", "you?", PERMANENT_KINDS),
          Kind.new(/At the beginning of your upkeep/, "UpkeepTrigger", "TriggeredAbility::BeginningOfYourUpkeep",
                   :event_handlers, "Events::BeginningOfUpkeep", nil, PERMANENT_KINDS),
          Kind.new(/At the beginning of your end step/, "EndStepTrigger", "TriggeredAbility::BeginningOfEndStep",
                   :event_handlers, "Events::BeginningOfEndStep", "controllers_end_step?", PERMANENT_KINDS),
          Kind.new(/Whenever ~ attacks/, "AttacksTrigger", "TriggeredAbility", :event_handlers,
                   "Events::FinalAttackersDeclared", "event.attacks.any? { _1.attacker == actor }", %i[creature]),
          Kind.new(/Whenever you cast an? (?<types>[\w-]+(?: or [\w-]+)?) spell/, "SpellCastTrigger", "TriggeredAbility::SpellCast",
                   :event_handlers, "Events::SpellCast",
                   lambda { |m|
                     types = m[:types].split(" or ").map do |type|
                       type.start_with?("non") ? "!spell.type?(#{type.delete_prefix('non').capitalize.inspect})" : "spell.type?(#{type.capitalize.inspect})"
                     end
                     "you? && #{types.size == 1 ? types.first : "(#{types.join(' || ')})"}"
                   },
                   PERMANENT_KINDS)
        ].freeze

        # An italic ability word ("Landfall — ") is flavour; the rest is the trigger.
        ABILITY_WORD = /\A[A-Z][a-z]+(?: [a-z]+)* — /

        def self.parse(line)
          text = line.sub(ABILITY_WORD, "")
          KINDS.each do |kind|
            next unless (m = /\A#{kind.pattern}, (?<effects>.+)\z/.match(text))

            effect_list = EffectList.parse(m[:effects]) or return
            condition = kind.condition.respond_to?(:call) ? kind.condition.call(m) : kind.condition
            return new(kind:, condition:, effect_list:)
          end
          nil
        end

        def kinds = kind.kinds
        def hook = kind.hook
        def class_base_name = kind.name
        def handled_event = kind.event

        def class_source(name)
          body = []
          body << "def should_perform?\n  #{condition}\nend\n" if condition
          body << effect_list.trigger_source
          "class #{name} < #{kind.base}\n#{body.join("\n").gsub(/^(?=.)/, '  ')}end\n"
        end
      end
    end
  end
end
