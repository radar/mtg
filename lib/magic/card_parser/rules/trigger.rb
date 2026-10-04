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
      #   Whenever ~ becomes tapped, draw a card, then discard a card.
      class Trigger < Data.define(:kind, :condition, :effect_list)
        include Rule

        # hook: where the trigger class is listed (an event handler, or a
        # lifecycle list); condition: Ruby for should_perform?, or nil to keep
        # the base class's (a String, or a Proc taking the match).
        Kind = Data.define(:pattern, :name, :base, :hook, :event, :condition, :kinds)

        # Whose creature dying triggers "Whenever <who> dies" -> should_perform?
        CREATURE_DIES = {
          "another creature you control" => "you? && event.permanent != actor",
          "another nontoken creature you control" => "you? && event.permanent != actor && !event.permanent.token?",
          "a nontoken creature you control" => "you? && !event.permanent.token?",
          "another nontoken creature" => "event.permanent != actor && !event.permanent.token?",
          "a creature you control" => "you?",
          "a creature an opponent controls" => "opponent?",
          "another creature" => "event.permanent != actor",
          "a creature" => nil
        }.freeze
        # Whose life gain triggers "Whenever <who> gain(s) life" -> should_perform?
        LIFE_GAINERS = { "you" => "you?", "an opponent" => "opponent?", "a player" => nil }.freeze
        ENTERS_UNDER_YOUR_CONTROL = "(?:you control enters|enters(?: the battlefield)? under your control)"
        # "When" and "Whenever" are interchangeable here.
        WHEN = "When(?:ever)?"
        # A creature type ("Goblin"), and "Elf or Faerie".
        TYPE = "(?<type>#{PermanentTarget::CREATURE_TYPES})"
        TYPES = "#{TYPE}(?: or (?<type2>#{PermanentTarget::CREATURE_TYPES}))?"
        # Ruby for "is a <type>" from the match: "event.permanent.type?(\"Elf\") || ...".
        TYPE_CHECK = lambda do |m|
          [m[:type], m[:type2]].compact.map { "event.permanent.type?(#{_1.inspect})" }.join(" || ").then { m[:type2] ? "(#{_1})" : _1 }
        end

        COLORS = %w[white blue black red green].freeze
        # "an opponent casts a [<colour> [or <colour>]] [<type> [or <type>]] spell" -> should_perform? (Mindsparker).
        OPPONENT_SPELL = lambda do |m|
          checks = ["opponent?"]
          colors = [m[:color], m[:color2]].compact.map { "spell.colors.include?(:#{_1})" }
          checks << (colors.one? ? colors.first : "(#{colors.join(' || ')})") if colors.any?
          types = [m[:type], m[:type2]].compact.map { "spell.type?(#{_1.capitalize.inspect})" }
          checks << (types.one? ? types.first : "(#{types.join(' || ')})") if types.any?
          checks.join(" && ")
        end

        # "When ~ enters or attacks" (see merge).
        ENTERS_OR_ATTACKS = "EntersOrAttacksTrigger"
        # "When ~ enters or dies" (see merge).
        ENTERS_OR_DIES = "EntersOrDiesTrigger"
        # "Whenever ~ enters or transforms into ~" (a double-faced card; see merge).
        ENTERS_OR_TRANSFORMS = "EntersOrTransformsTrigger"

        KINDS = [
          Kind.new(/#{WHEN} ~ enters(?: the battlefield)?/, "EntersTrigger", "TriggeredAbility::EnterTheBattlefield",
                   :etb_triggers, nil, nil, PERMANENT_KINDS),
          Kind.new(/#{WHEN} ~ enters(?: the battlefield)? or attacks/, ENTERS_OR_ATTACKS, nil, nil, nil, nil, %i[creature]),
          Kind.new(/#{WHEN} ~ enters(?: the battlefield)? or dies/, ENTERS_OR_DIES, nil, nil, nil, nil, %i[creature]),
          Kind.new(/#{WHEN} ~ enters(?: the battlefield)? or transforms into ~/, ENTERS_OR_TRANSFORMS, nil, nil, nil, nil, %i[creature planeswalker]),
          Kind.new(/#{WHEN} ~ transforms into ~/, "TransformedTrigger", "TriggeredAbility", :event_handlers,
                   "Events::PermanentTransformed", "event.permanent == actor", %i[creature planeswalker]),
          Kind.new(/#{WHEN} ~ dies/, "DiesTrigger", "TriggeredAbility::Death", :death_triggers, nil, nil, %i[creature]),
          Kind.new(/#{WHEN} ~ leaves the battlefield/, "LeavesTrigger", "TriggeredAbility::LeaveTheBattlefield",
                   :ltb_triggers, nil, nil, PERMANENT_KINDS),
          Kind.new(/#{WHEN} (?<who>#{CREATURE_DIES.keys.join('|')}) dies/, "CreatureDiesTrigger", "TriggeredAbility",
                   :event_handlers, "Events::CreatureDied", ->(m) { CREATURE_DIES.fetch(m[:who]) }, PERMANENT_KINDS),
          Kind.new(/#{WHEN} a nontoken, non-(?<type>#{PermanentTarget::CREATURE_TYPES}) creature you control dies/, "NontokenNonTribalDiesTrigger",
                   "TriggeredAbility", :event_handlers, "Events::CreatureDied",
                   ->(m) { "you? && !event.permanent.token? && !event.permanent.type?(#{m[:type].inspect})" }, PERMANENT_KINDS),
          Kind.new(/#{WHEN} (?<who>a|another) creature is exiled from the battlefield/, "CreatureExiledTrigger", "TriggeredAbility",
                   :event_handlers, "Events::LeftTheBattlefield",
                   ->(m) { "event.permanent.creature? && event.to.exile?#{' && event.permanent != actor' if m[:who] == 'another'}" },
                   PERMANENT_KINDS),
          Kind.new(/#{WHEN} another #{TYPES} you control dies/, "TribalDiesTrigger", "TriggeredAbility",
                   :event_handlers, "Events::CreatureDied", ->(m) { "you? && event.permanent != actor && #{TYPE_CHECK.(m)}" },
                   PERMANENT_KINDS),
          Kind.new(/#{WHEN} an? #{TYPES} creature you control dies/, "TribalCreatureDiesTrigger", "TriggeredAbility",
                   :event_handlers, "Events::CreatureDied", ->(m) { "you? && #{TYPE_CHECK.(m)}" }, PERMANENT_KINDS),
          Kind.new(/#{WHEN} (?<itself>~ or )?another (?<nontoken>nontoken )?#{TYPES} you control enters/, "TribalEntersTrigger",
                   "TriggeredAbility::EnterTheBattlefield", :event_handlers, "Events::EnteredTheBattlefield",
                   lambda { |m|
                     typed = "#{'!event.permanent.token? && ' if m[:nontoken]}#{TYPE_CHECK.(m)}"
                     next "under_your_control? && event.permanent != actor && #{typed}" unless m[:itself]

                     "under_your_control? && (event.permanent == actor || #{m[:nontoken] ? "(#{typed})" : typed})"
                   },
                   PERMANENT_KINDS),
          Kind.new(/#{WHEN} an? #{TYPES} you control enters/, "TribalEntersTrigger",
                   "TriggeredAbility::EnterTheBattlefield", :event_handlers, "Events::EnteredTheBattlefield",
                   ->(m) { "under_your_control? && #{TYPE_CHECK.(m)}" }, PERMANENT_KINDS),
          Kind.new(/#{WHEN} ~ becomes tapped/, "BecomesTappedTrigger", "TriggeredAbility", :event_handlers,
                   "Events::PermanentTapped", "event.permanent == actor", PERMANENT_KINDS),
          Kind.new(/#{WHEN} another creature #{ENTERS_UNDER_YOUR_CONTROL}/, "CreatureEntersTrigger",
                   "TriggeredAbility::EnterTheBattlefield", :event_handlers, "Events::EnteredTheBattlefield",
                   "another_creature? && under_your_control?", PERMANENT_KINDS),
          Kind.new(/#{WHEN} another nontoken creature #{ENTERS_UNDER_YOUR_CONTROL}/, "NontokenCreatureEntersTrigger",
                   "TriggeredAbility::EnterTheBattlefield", :event_handlers, "Events::EnteredTheBattlefield",
                   "another_creature? && under_your_control? && !event.permanent.token?", PERMANENT_KINDS),
          Kind.new(/#{WHEN} another non-(?<type>#{PermanentTarget::CREATURE_TYPES}) creature #{ENTERS_UNDER_YOUR_CONTROL}/, "NonTribalCreatureEntersTrigger",
                   "TriggeredAbility::EnterTheBattlefield", :event_handlers, "Events::EnteredTheBattlefield",
                   ->(m) { "another_creature? && under_your_control? && !event.permanent.type?(#{m[:type].inspect})" }, PERMANENT_KINDS),
          Kind.new(/#{WHEN} a creature an opponent controls enters/, "OpponentCreatureEntersTrigger",
                   "TriggeredAbility::EnterTheBattlefield", :event_handlers, "Events::EnteredTheBattlefield",
                   "creature? && event.permanent.controller != controller", PERMANENT_KINDS),
          Kind.new(/#{WHEN} a Gate you control enters/, "GateEntersTrigger", "TriggeredAbility::EnterTheBattlefield",
                   :event_handlers, "Events::EnteredTheBattlefield", 'under_your_control? && event.permanent.type?("Gate")',
                   PERMANENT_KINDS),
          Kind.new(/#{WHEN} a land #{ENTERS_UNDER_YOUR_CONTROL}/, "LandfallTrigger", "TriggeredAbility::Landfall",
                   :event_handlers, "Events::Landfall", "you?", PERMANENT_KINDS),
          Kind.new(/#{WHEN} you gain life for the first time during each of your turns/, "FirstLifeGainTrigger", "TriggeredAbility",
                   :event_handlers, "Events::LifeGain",
                   "you? && controllers_turn? && game.current_turn.events.count { |e| e.is_a?(Events::LifeGain) && e.player == controller } == 1",
                   PERMANENT_KINDS),
          Kind.new(/#{WHEN} (?<who>you|an opponent|a player) gains? life/, "LifeGainTrigger", "TriggeredAbility",
                   :event_handlers, "Events::LifeGain", ->(m) { LIFE_GAINERS.fetch(m[:who]) }, PERMANENT_KINDS),
          Kind.new(/At the beginning of your upkeep/, "UpkeepTrigger", "TriggeredAbility::BeginningOfYourUpkeep",
                   :event_handlers, "Events::BeginningOfUpkeep", nil, PERMANENT_KINDS),
          Kind.new(/At the beginning of your first main phase/, "MainPhaseTrigger", "TriggeredAbility",
                   :event_handlers, "Events::FirstMainPhase", "event.active_player == controller", PERMANENT_KINDS),
          Kind.new(/At the beginning of combat on your turn/, "BeginningOfCombatTrigger", "TriggeredAbility",
                   :event_handlers, "Events::BeginningOfCombat", "event.active_player == controller", PERMANENT_KINDS),
          Kind.new(/At the beginning of your end step, if another creature entered the battlefield under your control this turn/,
                   "EndStepIfCreatureEnteredTrigger", "TriggeredAbility::BeginningOfEndStep",
                   :event_handlers, "Events::BeginningOfEndStep",
                   "controllers_end_step? && game.current_turn.events.any? { |e| e.is_a?(Events::EnteredTheBattlefield) && e.permanent.creature? && e.permanent != actor && e.permanent.controller == controller }",
                   PERMANENT_KINDS),
          Kind.new(/At the beginning of your end step/, "EndStepTrigger", "TriggeredAbility::BeginningOfEndStep",
                   :event_handlers, "Events::BeginningOfEndStep", "controllers_end_step?", PERMANENT_KINDS),
          Kind.new(/At the beginning of each end step, if you put a counter on a creature this turn/,
                   "EachEndStepIfCounterPutTrigger", "TriggeredAbility::BeginningOfEndStep",
                   :event_handlers, "Events::BeginningOfEndStep",
                   "game.current_turn.events.any? { |e| e.is_a?(Events::CounterAddedToPermanent) && e.permanent.creature? && e.source&.controller == controller }",
                   PERMANENT_KINDS),
          Kind.new(/At the beginning of each end step/, "EachEndStepTrigger", "TriggeredAbility::BeginningOfEndStep",
                   :event_handlers, "Events::BeginningOfEndStep", nil, PERMANENT_KINDS),
          Kind.new(/#{WHEN} you gain life/, "LifeGainTrigger", "TriggeredAbility", :event_handlers, "Events::LifeGain", "you?",
                   PERMANENT_KINDS),
          Kind.new(/#{WHEN} (?<who>you|an opponent) draws? a card/, "CardDrawTrigger", "TriggeredAbility", :event_handlers,
                   "Events::CardDraw", ->(m) { m[:who] == "you" ? "you?" : "opponent?" }, PERMANENT_KINDS),
          Kind.new(/#{WHEN} you draw your second card each turn/, "SecondCardDrawTrigger", "TriggeredAbility", :event_handlers,
                   "Events::CardDraw",
                   "you? && game.current_turn.events.count { |e| e.is_a?(Events::CardDraw) && e.player == event.player } == 2",
                   PERMANENT_KINDS),
          Kind.new(/At the beginning of each player's draw step/, "DrawStepTrigger", "TriggeredAbility", :event_handlers,
                   "Events::DrawStep", nil, PERMANENT_KINDS),
          Kind.new(/#{WHEN} an? (?:(?<color>#{COLORS.join('|')}) )?creature you control attacks/, "CreatureAttacksTrigger", "TriggeredAbility",
                   :event_handlers, "Events::CreatureAttacked",
                   lambda { |m|
                     ["event.attacker.controller == controller", *("event.attacker.colors.include?(:#{m[:color]})" if m[:color])].join(" && ")
                   },
                   PERMANENT_KINDS),
          Kind.new(/#{WHEN} one or more creatures you control attack/, "CreaturesAttackTrigger", "TriggeredAbility", :event_handlers,
                   "Events::FinalAttackersDeclared", "event.active_player == controller && event.attacks.any?", PERMANENT_KINDS),
          Kind.new(%r{#{WHEN} you put one or more (?<counter>[\w+/-]+) counters on ~}, "CountersPutOnThisTrigger", "TriggeredAbility",
                   :event_handlers, "Events::CounterAddedToPermanent",
                   lambda { |m|
                     counter = "Counters::#{Magic::Counters[m[:counter].downcase].name.split('::').last}"
                     "event.permanent == actor && Counters[event.counter_type] == #{counter} && (event.source.nil? || event.source.controller == controller)"
                   },
                   PERMANENT_KINDS),
          Kind.new(/#{WHEN} a source you control deals noncombat damage to an opponent/, "NoncombatDamageToOpponentTrigger",
                   "TriggeredAbility", :event_handlers, "Events::DamageDealt",
                   "!event.combat? && event.target.is_a?(Magic::Player) && event.target != controller && " \
                   "event.source.respond_to?(:controller) && event.source.controller == controller",
                   PERMANENT_KINDS),
          Kind.new(/#{WHEN} a creature you control with (?<keyword>deathtouch|lifelink|flying|trample) deals combat damage to a player/,
                   "KeywordCreatureCombatDamageTrigger", "TriggeredAbility", :event_handlers, "Events::CombatDamageDealt",
                   lambda { |m|
                     "event.source.is_a?(Magic::Permanent) && event.source.creature? && event.source.controller == controller && " \
                       "event.source.#{m[:keyword]}? && event.target.is_a?(Magic::Player)"
                   },
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
          Kind.new(/#{WHEN} ~ becomes tapped/, "BecomesTappedTrigger", "TriggeredAbility", :event_handlers,
                   "Events::PermanentTapped", "event.permanent == actor", PERMANENT_KINDS),
          Kind.new(/#{WHEN} ~ attacks/, "AttacksTrigger", "TriggeredAbility", :event_handlers,
                   "Events::FinalAttackersDeclared", "event.attacks.any? { _1.attacker == actor }", %i[creature]),
          # "Mobilize N" is rewritten to this by `parse`; it fires like an attack trigger.
          Kind.new(/#{WHEN} ~ mobilizes/, "MobilizeTrigger", "TriggeredAbility", :event_handlers,
                   "Events::FinalAttackersDeclared", "event.attacks.any? { _1.attacker == actor }", %i[creature]),
          Kind.new(/#{WHEN} you cast your second spell each turn/, "FlurryTrigger", "TriggeredAbility::SpellCast",
                   :event_handlers, "Events::SpellCast", "you? && second_spell_this_turn?", PERMANENT_KINDS),
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
                   PERMANENT_KINDS),
          Kind.new(/#{WHEN} an opponent casts an? (?:(?<color>#{COLORS.join('|')})(?: or (?<color2>#{COLORS.join('|')}))? )?(?:(?<type>instant|sorcery|creature|artifact|enchantment|planeswalker)(?: or (?<type2>instant|sorcery|creature|artifact|enchantment|planeswalker))? )?spell/,
                   "OpponentSpellCastTrigger", "TriggeredAbility::SpellCast", :event_handlers, "Events::SpellCast", OPPONENT_SPELL, PERMANENT_KINDS),
          Kind.new(/#{WHEN} you cast a spell during an opponent's turn/, "OpponentsTurnSpellCastTrigger", "TriggeredAbility::SpellCast",
                   :event_handlers, "Events::SpellCast", "you? && !controllers_turn?", PERMANENT_KINDS)
        ].freeze

        # An italic ability word ("Landfall — ") is flavour; the rest is the trigger.
        ABILITY_WORD = /\A[A-Z][a-z]+(?: [a-z]+)* — /
        # Triggers whose event has `damage`, for "that many".
        DAMAGE_KINDS = %w[CombatDamageTrigger KeywordCreatureCombatDamageTrigger NoncombatDamageToOpponentTrigger].freeze
        PERMANENT_EVENTS =%w[Events::CounterAddedToPermanent Events::CreatureDied Events::EnteredTheBattlefield].freeze
        ONCE_EACH_TURN =/ This ability triggers only once each turn\.?\z/
        KICKED = /\Aif (?:it|~) was kicked, /
        INTERVENING_IF = /\Aif (?<condition>[^,]+), (?<rest>.+)\z/

        # "Mobilize N" / "Mobilize X, where X is <count>" is a keyword for this attack trigger.
        MOBILIZE = /\AMobilize (?<amount>\w+)(?<where>, where X is [^.]+)?\.?\z/

        def self.parse(line)
          text = line.sub(ABILITY_WORD, "")
          if (m = MOBILIZE.match(text))
            text = "Whenever ~ mobilizes, create #{m[:amount]} tapped and attacking 1/1 red Warrior creature tokens#{m[:where]}. " \
                   "Sacrifice them at the beginning of the next end step."
          end
          KINDS.each do |kind|
            next unless (m = /\A#{kind.pattern}, (?<effects>.+)\z/.match(text))

            effects = m[:effects]
            # "Whenever another nontoken creature you control enters, it endures X": "it" is the creature that entered.
            effects = effects.gsub(/\bit endures\b/, "that creature endures") if kind.name == "NontokenCreatureEntersTrigger"
            # "Whenever ~ deals combat damage to a player, put a +1/+1 counter on it": "it" is ~ (no target).
            effects = effects.gsub(/\bon it\b/, "on ~") if %w[CombatDamageTrigger AttacksTrigger].include?(kind.name) && !effects.include?("target")
            # "... target artifact or enchantment that player controls": the player damaged is the opponent (two-player games only).
            effects = effects.gsub("that player controls", "an opponent controls") if kind.name == "CombatDamageTrigger"
            # "... put a +1/+1 counter on that creature": the creature that entered (`event.permanent`).
            effects = effects.gsub(/\bon that creature\b/, "on the entering creature") if %w[CreatureEntersTrigger NontokenCreatureEntersTrigger].include?(kind.name)
            condition =kind.condition.respond_to?(:call) ? kind.condition.call(m) : kind.condition
            # "When ~ enters, if it was kicked, ..." (kicker).
            if kind.name == "EntersTrigger" && (kicked = KICKED.match(effects))
              effects = kicked.post_match
              condition = [condition, "actor.kicked?"].compact.join(" && ")
            end

            # "At the beginning of your upkeep, if you have 5 or less life, ..." (rule 603.4,
            # checked when it triggers only; it should also be rechecked on resolution).
            if (intervening = INTERVENING_IF.match(effects)) && (ruby = Condition.parse(intervening[:condition]))
              effects = intervening[:rest]
              condition = [condition || "super", "(#{ruby.gsub(/\bsource\b/, 'actor')})"].join(" && ")
            end

            # "... This ability triggers only once each turn."
            if effects.sub!(ONCE_EACH_TURN, "")
              # OncePerTurn keys on `event.permanent`, so only events that carry one.
              return unless kind.base == "TriggeredAbility" && PERMANENT_EVENTS.include?(kind.event)

              kind = kind.with(base: "TriggeredAbility::OncePerTurn")
            end

            # "put that many incubation counters on it" / "you draw that many cards": the damage dealt.
            if DAMAGE_KINDS.include?(kind.name) && effects.match?(/\bthat many\b/)
              effect_list = Number.with_x("event.damage") { EffectList.parse(effects.gsub(/\bthat many\b/, "X")) } or return
              return new(kind:, condition:, effect_list:)
            end

            effect_list = EffectList.parse(effects) or return
            return new(kind:, condition:, effect_list:)
          end
          nil
        rescue RuntimeError => e
          raise unless e.message.start_with?("Unknown counter type")
        end

        # "When ~ enters or attacks" / "enters or dies" are two triggers with the same effects.
        SPLIT_KINDS = { ENTERS_OR_ATTACKS => "AttacksTrigger", ENTERS_OR_DIES => "DiesTrigger", ENTERS_OR_TRANSFORMS => "TransformedTrigger" }.freeze

        def self.merge(rules)
          rules.flat_map do |rule|
            second = SPLIT_KINDS[rule.kind.name]
            next [rule] unless second

            [rule.with(kind: kind_named("EntersTrigger")), rule.with(kind: kind_named(second), condition: kind_named(second).condition)]
          end
        end

        def self.kind_named(name) = KINDS.find { _1.name == name }

        def kinds = kind.kinds
        def hook = kind.hook
        def class_base_name = kind.name
        def handled_event = kind.event

        # An effect that moves the card out of the graveyard (ReturnThisFromGraveyard) makes this a graveyard trigger.
        def works_from_graveyard?
          effect_list.effects.flat_map { _1.respond_to?(:all_effects) ? _1.all_effects : [_1] }
                     .any? { _1.respond_to?(:works_from_graveyard?) && _1.works_from_graveyard? }
        end

        def class_source(name)
          body = []
          if works_from_graveyard?
            # A trigger that moves its own card out of the graveyard fires only from there (Card#receive_event).
            body << "def self.works_from_graveyard? = true\n"
            body << "def should_perform?\n  actor.zone&.graveyard?#{" && (#{condition})" if condition}\nend\n"
          elsif condition
            body << "def should_perform?\n  #{condition}\nend\n"
          end
          body << effect_list.trigger_source
          "class #{name} < #{kind.base}\n#{body.join("\n").gsub(/^(?=.)/, '  ')}end\n"
        end
      end
    end
  end
end
