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
      CLAUSE = /,? then |,? and (?=you )/i
      MAY = /\Ayou may /i
      IF_YOU_DO = /\AIf you do, /i

      # Where effects are rendered: `this` is Ruby for the card or permanent the
      # effects belong to (and the actor of any Choice they add); a spell has its
      # target in scope, so targets aren't choice points there.
      Context = Data.define(:this, :targets_in_scope)
      INSIDE_CHOICE = Context.new(this: "actor", targets_in_scope: false)

      # `text` as one effect (some span two sentences), else every sentence (or,
      # failing that, every clause of it) as an effect; nil unless all of them parse.
      def self.parse(text)
        effect = Effect.parse(text) and return new(effects: [effect])

        effects = []
        clauses = text.split(SENTENCE).flat_map do |sentence|
          parse_sentence(sentence.sub(IF_YOU_DO, "").sub(MAY, "")) ? [sentence] : sentence.split(CLAUSE)
        end
        clauses.each do |sentence|
          if IF_YOU_DO.match?(sentence)
            return unless effects.last.is_a?(OptionalEffect) && (effect = parse_sentence(sentence.sub(IF_YOU_DO, "")))

            effects[-1] = effects.last.with(if_you_do: effects.last.if_you_do + [effect])
          elsif MAY.match?(sentence)
            effect = parse_sentence(sentence.sub(MAY, "")) or return
            effects << OptionalEffect.new(effect:, if_you_do: [])
          else
            effect = parse_sentence(sentence) or return
            effects << effect
          end
        end
        new(effects:) if effects.any?
      end

      # One sentence, capitalised; after "you may", also with its implied "You"
      # ("you may gain 3 life").
      def self.parse_sentence(sentence)
        Effect.parse(sentence[0].upcase + sentence[1..]) || Effect.parse("You #{sentence}")
      end

      def +(other) = self.class.new(effects: effects + other.effects)

      # Class body for an instant or sorcery (`this` = "self"), a mode ("card") or
      # an activated ability ("source"): target_choices and resolve!(target:) when
      # targeted; with several targets, multi_target? with one list of choices per
      # target and resolve!(targets:), each effect using its own targets[i]. Targets
      # are chosen on casting, so they must come before any choice point.
      def spell_source(this: "self")
        targeted = leaves(effects).select(&:target_choices)
        choices, statements = render(effects, Context.new(this:, targets_in_scope: true))
        sections = definitions + choices
        if targeted.size > 1
          lists = targeted.map { "  #{expand(_1.target_choices, this)},\n" }.join
          sections << "def multi_target? = true\n"
          sections << "def target_choices\n  [\n#{lists.gsub(/^/, '  ')}  ]\nend\n"
          sections << method("resolve!(targets:)", statements)
        else
          sections << "def target_choices\n  #{expand(targeted.first.target_choices, this)}\nend\n" if targeted.any?
          sections << method("resolve!#{'(target:)' if targeted.any?}", statements)
        end
        sections.join("\n")
      end

      # Class body for a triggered or chapter ability, whose `entry` method runs
      # the effects. A targeted ability with no legal target does nothing.
      def trigger_source(entry: "call")
        targeted = leaves(effects).select(&:target_choices)
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

      # Effects with optional ones opened up.
      def leaves(list) = list.flat_map { _1.is_a?(OptionalEffect) ? _1.effects : [_1] }

      def definitions = leaves(effects).filter_map(&:definitions).uniq

      def choice_point?(effect, context)
        effect.is_a?(OptionalEffect) || effect.choice_base || (!context.targets_in_scope && effect.target_choices)
      end

      # [choice classes, statements] for `list` in `context`.
      def render(list, context)
        index = list.index { choice_point?(_1, context) } or return [[], calls(list, context)]

        point, rest = list[index], list[(index + 1)..]
        if context.targets_in_scope && leaves([point, *rest]).any?(&:target_choices)
          raise UnsupportedCard, "targeted effects after a choice are not supported in spells and activated abilities"
        end

        klass, adds = case point
                      in OptionalEffect then may_choice(point, rest, context)
                      in _ if point.choice_base then effect_choice(point, rest, context)
                      else target_choice(point, rest, context)
                      end
        [Array(klass), calls(list[...index], context) + adds]
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

        methods = if after.empty?
                    [method("resolve!", accepted)]
                  else
                    [method("resolve!", accepted + ["finish"]), "def decline! = finish\n", method("finish", after)]
                  end
        [class_source("MayChoice", "Magic::Choice::May", accepted_classes + rest_classes + methods),
         ["game.choices.add(MayChoice.new(actor: #{context.this}))"]]
      end

      # A scry: its own Choice class, subclassed when effects follow it.
      def effect_choice(point, rest, context)
        args = ["actor: #{context.this}", *point.choice_args].join(", ")
        return [nil, ["game.choices.add(#{point.choice_base}.new(#{args}))"]] if rest.empty?

        classes, after = render(rest, INSIDE_CHOICE)
        [class_source(point.choice_class_name, point.choice_base, classes + [method("resolve!(**args)", ["super(**args)", *after])]),
         ["game.choices.add(#{point.choice_class_name}.new(#{args}))"]]
      end

      # A target chosen on resolution (triggered abilities).
      # A target chosen on resolution (triggered abilities). A second target's
      # choice nests inside the first's, as TargetChoice2.
      def target_choice(point, rest, context)
        index = leaves(effects).select(&:target_choices).index { _1.equal?(point) }
        name = index.to_i.zero? ? "TargetChoice" : "TargetChoice#{index + 1}"
        classes, after = render(rest, INSIDE_CHOICE)
        body = [method("choices", [expand(point.target_choices, "actor")]), "def choice_amount = 1\n", *classes,
                method("resolve!(target:)", [expand(point.resolve_call, "actor"), *after])]
        [class_source(name, "Magic::Choice::Targeted", body),
         ["choice = #{name}.new(actor: #{context.this})", "game.add_choice(choice) if choice.choices.any?"]]
      end

      # With several targets in scope (a multi-target spell), each targeted effect
      # uses its own targets[i] in place of `target`.
      def calls(list, context)
        targeted = leaves(effects).select(&:target_choices)
        list.map do |effect|
          call = expand(effect.resolve_call, context.this)
          index = targeted.index { _1.equal?(effect) }
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
