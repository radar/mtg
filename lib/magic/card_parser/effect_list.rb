# frozen_string_literal: true

module Magic
  class CardParser
    # The effects of one spell or ability, in order, rendered as Ruby.
    #
    # Rendering walks the effects up to the first *choice point* — a "you may"
    # (OptionalEffect), a choice effect (scry), or, in a triggered ability, a
    # targeted effect — and puts everything from there on into a generated
    # Choice subclass that runs once the player has chosen. The effects after
    # the choice point are rendered the same way inside that class, so choices
    # nest (a MayChoice holding a TargetChoice).
    class EffectList < Data.define(:effects)
      SENTENCE = /(?<=\.)\s+/
      # Clauses of one sentence, when the sentence isn't one effect as a whole
      # ("exile it, then return it" is one effect; "draw a card, then discard a card" two).
      CLAUSE = /,? then |,? and (?=you |lose |gain |draw |put |~ endures )/i
      MAY = /\Ayou may /i
      IF_YOU_DO = /\A(?:If|When) you do, /i
      IF_YOU_DONT = /\AIf you don't, /i
      # "If a Dragon was beheld, ..." is the same check: Rules::BeholdCost's optional cost is the card's kicker_cost.
      KICKED = /\AIf (?:(?:this spell|~) was kicked|an? [A-Z][\w-]* was beheld), /i
      # What follows "If this spell was kicked, ": "<effects> instead." or "instead <effects>."
      INSTEAD = /\A(?:instead,? (?<before>.+?)|(?<after>.+?),? instead)\.?\z/i
      # "it deals 4 damage instead": the same recipients as the damage it replaces.
      SAME_RECIPIENTS = /\A(?:~|it) deals (?<amount>\d+|\w+) damage\z/i

      # Where effects are rendered: `this` is Ruby for the card or permanent the
      # effects belong to (and the actor of any Choice they add); a spell has its
      # target in scope, so targets aren't choice points there.
      Context = Data.define(:this, :targets_in_scope)
      INSIDE_CHOICE = Context.new(this: "actor", targets_in_scope: false)

      # ", where X is <count>" after an amount of X, or "draw cards / gain life equal to <count>".
      WHERE_X = /,? where X is (?<what>[^.]+)(?=\.|\z)/
      EQUAL_TO = /\b(?<verb>draw|gain|mill) (?<noun>cards|life) equal to (?<what>[^.]+?)(?=\.|,|\z)/i

      # "draw a card for each <count>" / "you gain 1 life for each <count>": N times the count.
      FOR_EACH = /\b(?<verb>draw|gain) (?<n>an?|\d+|\w+) (?<noun>cards?|life) for each (?<what>[^.]+?)(?=\.|,|\z)/i

      # "gain 2 life for each Gate you control" (also lose): the amount is N times the count.
      LIFE_FOR_EACH = /\b(?<verb>gain|lose|gains|loses) (?<amount>\d+|\w+) life for each (?<what>[^.]+?)(?=\.|,|\z)/i

      # "Each opponent discards a card and loses 2 life": the second verb has the first's subject, so it becomes
      # a sentence of its own with that subject spelled out.
      DISCARD_AND_LOSE = /(?<who>Each opponent|Target opponent|Target player) (?<discard>discards? (?:a|\w+) cards?) and (?<lose>loses? \w+ life)/i

      PAY_X = /\byou may pay \{X\}\./i

      # `text` as one effect (some span two sentences), else every sentence (or,
      # failing that, every clause of it) as an effect; nil unless all of them parse.
      def self.parse(text)
        if (m = FOR_EACH.match(text)) && (count = Count.parse(m[:what], this: Effect::THIS))
          times = Number.parse(m[:n])
          rewritten = text.sub(FOR_EACH) { "#{m[:verb]} X #{m[:noun] == 'life' ? 'life' : 'cards'}" }
          return Number.with_x(times == 1 ? count : "#{times} * #{count}") { parse(rewritten) }
        end

        text = text.gsub(DISCARD_AND_LOSE) { "#{$~[:who]} #{$~[:discard]}. #{$~[:who]} #{$~[:lose]}" }
        # "you may pay {X}. When you do, put X counters ...": the X is what the Choice::PayX remembers as `x`.
        return Number.with_x("x") { parse(text) } if PAY_X.match?(text) && !Number.x_bound?

        if (m = WHERE_X.match(text)) && (count = Count.parse(m[:what], this: Effect::THIS))
          return Number.with_x(count) { parse(text.sub(WHERE_X, "")) }
        elsif (m = EQUAL_TO.match(text)) && (count = Count.parse(m[:what], this: Effect::THIS))
          rewritten = text.sub(EQUAL_TO) { m[:noun] == "cards" ? "#{m[:verb]} X cards" : "#{m[:verb]} X life" }
          return Number.with_x(count) { parse(rewritten) }
        elsif (m = LIFE_FOR_EACH.match(text)) && !Number.x_bound? && (count = Count.parse(m[:what], this: Effect::THIS))
          rewritten = text.sub(LIFE_FOR_EACH) { "#{m[:verb]} X life" }
          return Number.with_x("#{Number.parse(m[:amount])} * #{count}") { parse(rewritten) }
        end

        effect = Effect.parse(text) and return (new(effects: [effect]) unless effect.earlier_target?)

        effects = []
        clauses = text.split(SENTENCE).flat_map do |sentence|
          next [sentence] if KICKED.match?(sentence)
          next [sentence] if parse_sentence(sentence.sub(IF_YOU_DO, "").sub(IF_YOU_DONT, "").sub(MAY, ""))

          # Every clause of an "If you do, ..." sentence stays conditional.
          first, *rest = sentence.split(CLAUSE)
          prefix = sentence[IF_YOU_DO] || sentence[IF_YOU_DONT]
          [first, *rest.map { "#{prefix}#{_1}" }]
        end
        clauses.each do |sentence|
          if KICKED.match?(sentence)
            rest = sentence.sub(KICKED, "")
            if (instead = INSTEAD.match(rest))
              effect = kicked_instead(instead[:before] || instead[:after], effects.last) or return
              effects[-1] = effect
            else
              effect = kicked(rest) or return
              effects << effect
            end
          elsif IF_YOU_DONT.match?(sentence)
            return unless effects.last.is_a?(OptionalEffect) && (effect = parse_sentence(sentence.sub(IF_YOU_DONT, "")))

            effects[-1] = effects.last.with(if_you_dont: effects.last.if_you_dont + [effect])
          elsif IF_YOU_DO.match?(sentence) && effects.last.respond_to?(:may_choice?) && effects.last.may_choice?
            # "you may pay {M}. If you do, ...": the pay choice is the "may"; what follows runs once it's paid.
            effects << (parse_sentence(sentence.sub(IF_YOU_DO, "")) or return)
          elsif IF_YOU_DO.match?(sentence)
            return unless effects.last.is_a?(OptionalEffect) && (effect = parse_sentence(sentence.sub(IF_YOU_DO, "")))

            effects[-1] = effects.last.with(if_you_do: effects.last.if_you_do + [effect])
          elsif MAY.match?(sentence)
            effect = parse_sentence(sentence.sub(MAY, "")) or return
            effects << (effect.respond_to?(:may_choice?) && effect.may_choice? ? effect : OptionalEffect.new(effect:, if_you_do: []))
          else
            effect = parse_sentence(sentence) or return
            effects << effect
          end
        end
        new(effects:) if effects.any? && earlier_targets?(effects)
      end

      # "Untap it." needs an earlier effect with a target for "it" to refer to.
      def self.earlier_targets?(effects)
        leaves = new(effects:).send(:leaves, effects)
        leaves.each_with_index.all? { |effect, i| !effect.earlier_target? || leaves[...i].any?(&:target_choices) }
      end

      # The rest of an "If this spell was kicked, ..." sentence. Targets are chosen as
      # the spell is cast, before anyone knows whether it was kicked, so kicked effects
      # can't target.
      def self.kicked(text)
        list = parse(text) or return
        raise UnsupportedCard, "targeted effects after \"if this spell was kicked\" are not supported" if list.targeted?

        KickedEffect.new(effects: list.effects)
      end

      # "If this spell was kicked, <effects> instead": the effect just before `replaced` runs
      # only when the spell wasn't kicked. Like kicked effects, the replacement can't target,
      # but "it"/"that creature" refers to the replaced effect's target, and a bare "it deals
      # N damage" has that effect's recipients.
      def self.kicked_instead(text, replaced)
        return unless replaced && !replaced.is_a?(KickedEffect) && !replaced.is_a?(OptionalEffect)

        if (m = SAME_RECIPIENTS.match(text)) && replaced.is_a?(Effects::DealDamage)
          return KickedEffect.new(effects: [replaced.with(amount: Number.parse(m[:amount]))], otherwise: [replaced])
        end

        effects = text.split(SENTENCE).flat_map { |sentence| sentence.split(CLAUSE) }.map { parse_sentence(_1) or return }
        if effects.any? { _1.target_choices || _1.is_a?(OptionalEffect) || _1.choice_base }
          raise UnsupportedCard, "targeted effects after \"if this spell was kicked\" are not supported"
        end

        KickedEffect.new(effects:, otherwise: [replaced])
      end

      # One sentence, capitalised; after "you may", also with its implied "You"
      # ("you may gain 3 life").
      def self.parse_sentence(sentence)
        ConditionalEffect.parse(sentence) || Effect.parse(sentence[0].upcase + sentence[1..]) || Effect.parse("You #{sentence}")
      end

      def +(other) = self.class.new(effects: effects + other.effects)

      def targeted? = leaves(effects).any?(&:target_choices)

      # Class body for an instant or sorcery (`this` = "self"), a mode ("card") or
      # an activated ability ("source"): target_choices and resolve!(target:) when
      # targeted; with several targets, multi_target? with one list of choices per
      # target and resolve!(targets:), each effect using its own targets[i]. Targets
      # are chosen on casting, so they must come before any choice point.
      def spell_source(this: "self")
        raise UnsupportedCard, "\"if this spell was kicked\" only works on instants and sorceries" if this == "source" && kicked?
        optional = leaves(effects).select(&:optional_target?)
        # Abilities (a planeswalker's, an activated one's) may leave "up to one target" unchosen; a spell can't.
        raise UnsupportedCard, "\"up to one target\" is only supported in triggered and activated abilities" if optional.any? && this != "source"
        raise UnsupportedCard, "\"up to one target\" needs to be the only target" if optional.any? && leaves(effects).count(&:target_choices) > 1

        targeted = leaves(effects).select(&:target_choices)
        # One effect that itself takes several targets ("N damage to any target and M damage to any other target").
        single_multi = targeted.one? && targeted.first.respond_to?(:multi_target?) && targeted.first.multi_target?
        raise UnsupportedCard, "multiple targets are only supported in instants and sorceries" if single_multi && this != "self"
        choices, statements = render(effects, Context.new(this:, targets_in_scope: true))
        sections = definitions + choices
        if single_multi
          sections << "def multi_target? = true\n"
          sections << "def distinct_targets? = true\n" if targeted.first.distinct_targets?
          sections << "def target_choices\n  #{expand(targeted.first.target_choices, this)}\nend\n"
          sections << method("resolve!(targets:)", statements)
        elsif targeted.size > 1
          lists = targeted.map { "  #{expand(_1.target_choices, this)},\n" }.join
          sections << "def multi_target? = true\n"
          sections << "def target_choices\n  [\n#{lists.gsub(/^/, '  ')}  ]\nend\n"
          sections << method("resolve!(targets:)", statements)
        else
          sections << "def target_choices\n  #{expand(targeted.first.target_choices, this)}\nend\n" if targeted.any?
          if optional.any?
            sections << method("resolve!(target: nil)", ["return unless target", *statements])
          else
            sections << method("resolve!#{'(target:)' if targeted.any?}", statements)
          end
        end
        sections.join("\n")
      end

      # Class body for a triggered or chapter ability, whose `entry` method runs
      # the effects. A targeted ability with no legal target does nothing, unless its
      # targets are all "up to one".
      def trigger_source(entry: "call")
        raise UnsupportedCard, "\"if this spell was kicked\" only works on instants and sorceries" if kicked?
        raise UnsupportedCard, "multiple targets are only supported in instants and sorceries" if leaves(effects).any? { _1.respond_to?(:multi_target?) && _1.multi_target? }
        targeted = leaves(effects).select(&:target_choices).reject(&:optional_target?)
        choices, statements = render(effects, INSIDE_CHOICE)
        unless targeted.empty? || (targeted.one? && effects.first.equal?(targeted.first))
          checks = targeted.map do |effect|
            targets = expand(effect.target_choices, "actor")
            targets = "(#{targets})" unless targets.match?(/\A\(.*\)\z/) || targets.match?(/\A[\w.()]+\z/)
            "#{targets}.none?"
          end
          statements.unshift("return if #{checks.join(' || ')}")
        end
        (definitions + choices + [method(entry, statements)]).join("\n")
      end

      private

      # Effects with optional and kicked ones opened up.
      def leaves(list)
        list.flat_map do |effect|
          case effect
          when OptionalEffect then effect.all_effects
          when KickedEffect then leaves(effect.otherwise) + leaves(effect.effects).reject { effect.otherwise.any? && _1.target_choices }
          else [effect]
          end
        end
      end

      def kicked? = effects.any?(KickedEffect)

      def definitions = leaves(effects).filter_map(&:definitions).uniq

      def choice_point?(effect, context)
        effect.is_a?(OptionalEffect) || effect.choice_base || (!context.targets_in_scope && effect.target_choices)
      end

      # [choice classes, statements] for `list` in `context`.
      def render(list, context)
        index = list.index { choice_point?(_1, context) } or return statements(list, context)

        point, rest = list[index], list[(index + 1)..]
        if context.targets_in_scope && leaves([point, *rest]).any?(&:target_choices)
          raise UnsupportedCard, "targeted effects after a choice are not supported in spells and activated abilities"
        end

        klass, adds = case point
                      in OptionalEffect then may_choice(point, rest, context)
                      in _ if point.choice_base then effect_choice(point, rest, context)
                      else target_choice(point, rest, context)
                      end
        before_classes, before = statements(list[...index], context)
        [before_classes + Array(klass), before + adds]
      end

      # [choice classes, statements] for effects that aren't choice points; a kicked
      # effect's statements are wrapped in a check that the kicker was paid.
      def statements(list, context)
        list.each_with_index.each_with_object([[], []]) do |(effect, index), (classes, lines)|
          next lines.concat(calls([effect], context)) unless effect.is_a?(KickedEffect)

          # Anything after a choice would run before that choice resolved.
          if leaves(effect.effects + effect.otherwise).any? { choice_point?(_1, context) } && index < list.size - 1
            raise UnsupportedCard, "effects after a choice in \"if this spell was kicked\" are not supported"
          end

          inner_classes, inner = render(effect.effects, context)

          classes.concat(inner_classes)
          kicker = context.this == "self" ? "kicker_cost" : "#{context.this}.kicker_cost"
          body = ->(statements) { statements.join("\n").lines.map { "  #{_1.chomp}\n" }.join }
          if effect.otherwise.empty?
            lines << "if #{kicker}.paid?\n#{body.(inner)}end"
          else
            other_classes, other = render(effect.otherwise, context)
            raise UnsupportedCard, "choices in both branches of \"if this spell was kicked, ... instead\" are not supported" if inner_classes.any? && other_classes.any?

            classes.concat(other_classes)
            lines << "if #{kicker}.paid?\n#{body.(inner)}else\n#{body.(other)}end"
          end
        end
      end

      # Asks first; accepted runs the optional effects, and the effects after
      # them run either way.
      def may_choice(point, rest, context)
        accepted_classes, accepted = render(point.effects, INSIDE_CHOICE)
        rest_classes, after = render(rest, INSIDE_CHOICE)
        # They would run before that choice resolved.
        if after.any? && point.effects.any? { choice_point?(_1, INSIDE_CHOICE) }
          raise UnsupportedCard, "effects after an optional effect that makes a choice are not supported"
        end

        declined_classes, declined = render(point.if_you_dont, INSIDE_CHOICE)
        methods = if after.empty? && declined.empty?
                    [method("resolve!", accepted)]
                  elsif after.empty?
                    [method("resolve!", accepted), method("decline!", declined)]
                  elsif declined.empty?
                    [method("resolve!", accepted + ["finish"]), "def decline! = finish\n", method("finish", after)]
                  else
                    [method("resolve!", accepted + ["finish"]), method("decline!", declined + ["finish"]), method("finish", after)]
                  end
        [class_source("MayChoice", "Magic::Choice::May", accepted_classes + declined_classes + rest_classes + methods),
         ["game.choices.add(MayChoice.new(actor: #{context.this}))"]]
      end

      # A scry: its own Choice class, subclassed when effects follow it.
      def effect_choice(point, rest, context)
        args = expand(["actor: #{context.this}", *point.choice_args].join(", "), context.this)
        # An effect whose choice can be impossible (blight with no creature) has a choice_guard.
        guard = point.respond_to?(:choice_guard) ? " if #{expand(point.choice_guard, context.this)}" : ""
        return [nil, ["game.choices.add(#{point.choice_base}.new(#{args}))#{guard}"]] if rest.empty?

        classes, after = render(rest, INSIDE_CHOICE)
        [class_source(point.choice_class_name, point.choice_base, classes + [method("resolve!(**args)", ["super(**args)", *after])]),
         ["game.choices.add(#{point.choice_class_name}.new(#{args}))#{guard}"]]
      end

      # A target chosen on resolution (triggered abilities).
      # A target chosen on resolution (triggered abilities). A second target's
      # choice nests inside the first's, as TargetChoice2.
      def target_choice(point, rest, context)
        index = leaves(effects).select(&:target_choices).index { _1.equal?(point) }
        name = index.to_i.zero? ? "TargetChoice" : "TargetChoice#{index + 1}"
        classes, after = render(rest, INSIDE_CHOICE)
        return optional_target_choice(name, point, classes, after, context) if point.optional_target?

        body = [method("choices", [expand(point.target_choices, "actor")]), "def choice_amount = 1\n", *classes,
                method("resolve!(target:)", [expand(point.resolve_call, "actor"), *after])]
        [class_source(name, "Magic::Choice::Targeted", body),
         ["choice = #{name}.new(actor: #{context.this})", "game.add_choice(choice) if choice.choices.any?"]]
      end

      # "up to one target": choosing none (skip_choice! -> decline!), or having
      # nothing to choose, still runs the effects after it.
      def optional_target_choice(name, point, classes, after, context)
        # "each of up to two target creatures": several targets, resolved with `targets:`.
        maximum = point.respond_to?(:max_targets) ? point.max_targets : 1
        resolve = maximum > 1 ? "resolve!(targets:)" : "resolve!(target:)"
        body = [method("choices", [expand(point.target_choices, "actor")]), "def choice_amount = 0..#{maximum}\n", *classes]
        if after.empty?
          body << method(resolve, [expand(point.resolve_call, "actor")])
          adds = ["choice = #{name}.new(actor: #{context.this})", "game.add_choice(choice) if choice.choices.any?"]
        else
          body << method(resolve, [expand(point.resolve_call, "actor"), "finish"])
          body << "def decline! = finish\n"
          body << method("finish", after)
          adds = ["choice = #{name}.new(actor: #{context.this})", "choice.choices.any? ? game.add_choice(choice) : choice.finish"]
        end
        [class_source(name, "Magic::Choice::Targeted", body), adds]
      end

      # With several targets in scope (a multi-target spell), each targeted effect
      # uses its own targets[i] in place of `target`, and an effect on an earlier
      # target ("untap it") that of the last targeted effect before it.
      def calls(list, context)
        all = leaves(effects)
        targeted = all.select(&:target_choices)
        list.map do |effect|
          call = expand(effect.resolve_call, context.this)
          index = targeted.index { _1.equal?(effect) }
          if effect.earlier_target?
            before = all[...all.index { _1.equal?(effect) }].select(&:target_choices)
            index = targeted.index { _1.equal?(before.last) }
          end
          context.targets_in_scope && targeted.size > 1 && index ? call.gsub(/\btarget\b(?!:)/, "targets[#{index}]") : call
        end
      end

      # Effects refer to the card or permanent they belong to as Effect::THIS.
      def expand(ruby, this) = ruby.gsub(Effect::THIS, this)

      def class_source(name, base, sections)
        "class #{name} < #{base}\n#{indent(sections.join("\n"))}\nend\n"
      end

      # Statements may span several lines (a do...end block).
      def method(signature, lines)
        "def #{signature}\n#{lines.join("\n").lines.map { "  #{_1.chomp}\n" }.join}end\n"
      end

      def indent(source) = source.gsub(/^(?=.)/, "  ").chomp
    end
  end
end
