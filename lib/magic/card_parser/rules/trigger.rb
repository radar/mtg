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
      #   Whenever ~ enters or attacks, create a 1/1 white Soldier creature token.
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
        # "When" and "Whenever" are interchangeable here.
        WHEN = "When(?:ever)?"

        # "When ~ enters or attacks" (see merge).
        ENTERS_OR_ATTACKS = "EntersOrAttacksTrigger"

        KINDS = [
          Kind.new(/#{WHEN} ~ enters(?: the battlefield)?/, "EntersTrigger", "TriggeredAbility::EnterTheBattlefield",
                   :etb_triggers, nil, nil, PERMANENT_KINDS),
          Kind.new(/#{WHEN} ~ enters(?: the battlefield)? or attacks/, ENTERS_OR_ATTACKS, nil, nil, nil, nil, %i[creature]),
          Kind.new(/#{WHEN} ~ dies/, "DiesTrigger", "TriggeredAbility::Death", :death_triggers, nil, nil, %i[creature]),
          Kind.new(/#{WHEN} ~ leaves the battlefield/, "LeavesTrigger", "TriggeredAbility::LeaveTheBattlefield",
                   :ltb_triggers, nil, nil, PERMANENT_KINDS),
          Kind.new(/#{WHEN} (?<who>#{CREATURE_DIES.keys.join('|')}) dies/, "CreatureDiesTrigger", "TriggeredAbility",
                   :event_handlers, "Events::CreatureDied", ->(m) { CREATURE_DIES.fetch(m[:who]) }, PERMANENT_KINDS),
          Kind.new(/#{WHEN} (?<who>a|another) creature is exiled from the battlefield/, "CreatureExiledTrigger", "TriggeredAbility",
                   :event_handlers, "Events::LeftTheBattlefield",
                   ->(m) { "event.permanent.creature? && event.to.exile?#{' && event.permanent != actor' if m[:who] == 'another'}" },
                   PERMANENT_KINDS),
          Kind.new(/#{WHEN} another creature #{ENTERS_UNDER_YOUR_CONTROL}/, "CreatureEntersTrigger",
                   "TriggeredAbility::EnterTheBattlefield", :event_handlers, "Events::EnteredTheBattlefield",
                   "another_creature? && under_your_control?", PERMANENT_KINDS),
          Kind.new(/#{WHEN} a land #{ENTERS_UNDER_YOUR_CONTROL}/, "LandfallTrigger", "TriggeredAbility::Landfall",
                   :event_handlers, "Events::Landfall", "you?", PERMANENT_KINDS),
          Kind.new(/At the beginning of your upkeep/, "UpkeepTrigger", "TriggeredAbility::BeginningOfYourUpkeep",
                   :event_handlers, "Events::BeginningOfUpkeep", nil, PERMANENT_KINDS),
          Kind.new(/At the beginning of combat on your turn/, "BeginningOfCombatTrigger", "TriggeredAbility",
                   :event_handlers, "Events::BeginningOfCombat", "event.active_player == controller", PERMANENT_KINDS),
          Kind.new(/At the beginning of your end step/, "EndStepTrigger", "TriggeredAbility::BeginningOfEndStep",
                   :event_handlers, "Events::BeginningOfEndStep", "controllers_end_step?", PERMANENT_KINDS),
          Kind.new(/At the beginning of each end step/, "EachEndStepTrigger", "TriggeredAbility::BeginningOfEndStep",
                   :event_handlers, "Events::BeginningOfEndStep", nil, PERMANENT_KINDS),
          Kind.new(/#{WHEN} you gain life/, "LifeGainTrigger", "TriggeredAbility", :event_handlers, "Events::LifeGain", "you?",
                   PERMANENT_KINDS),
          Kind.new(/#{WHEN} you draw a card/, "CardDrawTrigger", "TriggeredAbility", :event_handlers, "Events::CardDraw", "you?",
                   PERMANENT_KINDS),
          Kind.new(/#{WHEN} (?<who>you sacrifice|a player sacrifices) (?:an?|(?<another>another)) (?<type>[\w-]+)/, "SacrificeTrigger",
                   "TriggeredAbility", :event_handlers, "Events::PermanentSacrificed",
                   lambda { |m|
                     checks = []
                     checks << "event.permanent.controller == controller" if m[:who] == "you sacrifice"
                     checks << "event.permanent != actor" if m[:another]
                     type = m[:type].downcase == "permanent" ? nil : m[:type][0].upcase + m[:type][1..]
                     checks << "event.permanent.type?(#{type.inspect})" if type
                     checks.empty? ? nil : checks.join(" && ")
                   },
                   PERMANENT_KINDS),
          Kind.new(/#{WHEN} ~ attacks/, "AttacksTrigger", "TriggeredAbility", :event_handlers,
                   "Events::FinalAttackersDeclared", "event.attacks.any? { _1.attacker == actor }", %i[creature]),
          Kind.new(/#{WHEN} you attack/, "YouAttackTrigger", "TriggeredAbility", :event_handlers,
                   "Events::FinalAttackersDeclared", "event.active_player == controller && event.attacks.any?", PERMANENT_KINDS),
          Kind.new(/#{WHEN} ~ deals combat damage to (?:a player|an opponent)/, "CombatDamageTrigger", "TriggeredAbility",
                   :event_handlers, "Events::CombatDamageDealt", "event.source == actor && event.target.is_a?(Magic::Player)",
                   %i[creature]),
          Kind.new(%r{#{WHEN} the last (?<counter>[\w+/-]+) counter is removed from ~}, "LastCounterRemovedTrigger",
                   "TriggeredAbility", :event_handlers, "Events::CounterRemoved",
                   lambda { |m|
                     counter = "Counters::#{Magic::Counters[m[:counter].downcase].name.split('::').last}"
                     "event.permanent == actor && Counters[event.counter_type] == #{counter} && actor.counters.of_type(#{counter}).none?"
                   },
                   PERMANENT_KINDS),
          Kind.new(/#{WHEN} you cast an? (?<types>[\w-]+(?: or [\w-]+)?) spell/, "SpellCastTrigger", "TriggeredAbility::SpellCast",
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
        KICKED = /\Aif (?:it|~) was kicked, /

        def self.parse(line)
          text = line.sub(ABILITY_WORD, "")
          KINDS.each do |kind|
            next unless (m = /\A#{kind.pattern}, (?<effects>.+)\z/.match(text))

            effects = m[:effects]
            condition = kind.condition.respond_to?(:call) ? kind.condition.call(m) : kind.condition
            # "When ~ enters, if it was kicked, ..." (kicker).
            if kind.name == "EntersTrigger" && (kicked = KICKED.match(effects))
              effects = kicked.post_match
              condition = [condition, "actor.kicked?"].compact.join(" && ")
            end

            effect_list = EffectList.parse(effects) or return
            return new(kind:, condition:, effect_list:)
          end
          nil
        rescue RuntimeError => e
          raise unless e.message.start_with?("Unknown counter type")
        end

        # "When ~ enters or attacks" is two triggers with the same effects.
        def self.merge(rules)
          rules.flat_map do |rule|
            next [rule] unless rule.kind.name == ENTERS_OR_ATTACKS

            [rule.with(kind: kind_named("EntersTrigger")), rule.with(kind: kind_named("AttacksTrigger"), condition: kind_named("AttacksTrigger").condition)]
          end
        end

        def self.kind_named(name) = KINDS.find { _1.name == name }

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
