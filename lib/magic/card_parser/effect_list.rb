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
      IF_YOU_DO = /\A(?:If|When) you do, /i
      IF_YOU_DONT = /\AIf you don't, /i

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
          parse_sentence(sentence.sub(IF_YOU_DO, "").sub(IF_YOU_DONT, "").sub(MAY, "")) ? [sentence] : sentence.split(CLAUSE)
        end
        clauses.each do |sentence|
          if IF_YOU_DONT.match?(sentence)
            return unless effects.last.is_a?(OptionalEffect) && (effect = parse_sentence(sentence.sub(IF_YOU_DONT, "")))

            effects[-1] = effects.last.with(if_you_dont: effects.last.if_you_dont + [effect])
          elsif IF_YOU_DO.match?(sentence)
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

      def initialize(effects:)
        raise UnsupportedCard, "only one targeted effect per ability is supported" if leaves(effects).count(&:target_choices) > 1

        super
      end

      def +(other) = self.class.new(effects: effects + other.effects)

      # Class body for an instant or sorcery (`this` = "self") or an activated
      # ability (`this` = "source"): target_choices and resolve!(target:) when
      # targeted. The target is chosen on casting, so it must come before any
      # choice point.
      def spell_source(this: "self")
        targeted = leaves(effects).find(&:target_choices)
        choices, statements = render(effects, Context.new(this:, targets_in_scope: true))
        sections = definitions + choices
        sections << "def target_choices\n  #{expand(targeted.target_choices, this)}\nend\n" if targeted
        sections << method("resolve!#{'(target:)' if targeted}", statements)
        sections.join("\n")
      end

      # Class body for a triggered or chapter ability, whose `entry` method runs
      # the effects. A targeted ability with no legal target does nothing.
      def trigger_source(entry: "call")
        targeted = leaves(effects).find(&:target_choices)
        choices, statements = render(effects, INSIDE_CHOICE)
        if targeted && !effects.first.equal?(targeted)
          targets = expand(targeted.target_choices, "actor")
          targets = "(#{targets})" unless targets.match?(/\A\(.*\)\z/) || targets.match?(/\A[\w.()]+\z/)
          statements.unshift("return if #{targets}.none?")
        end
        (definitions + choices + [method(entry, statements)]).join("\n")
      end

      private

      # Effects with optional ones opened up.
      def leaves(list) = list.flat_map { _1.is_a?(OptionalEffect) ? _1.all_effects : [_1] }

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
        args = ["actor: #{context.this}", *point.choice_args].join(", ")
        # An effect whose choice can be impossible (blight with no creature) has a choice_guard.
        guard = point.respond_to?(:choice_guard) ? " if #{point.choice_guard}" : ""
        return [nil, ["game.choices.add(#{point.choice_base}.new(#{args}))#{guard}"]] if rest.empty?

        classes, after = render(rest, INSIDE_CHOICE)
        [class_source(point.choice_class_name, point.choice_base, classes + [method("resolve!(**args)", ["super(**args)", *after])]),
         ["game.choices.add(#{point.choice_class_name}.new(#{args}))#{guard}"]]
      end

      # A target chosen on resolution (triggered abilities).
      def target_choice(point, rest, context)
        classes, after = render(rest, INSIDE_CHOICE)
        body = [method("choices", [expand(point.target_choices, "actor")]), "def choice_amount = 1\n", *classes,
                method("resolve!(target:)", [expand(point.resolve_call, "actor"), *after])]
        [class_source("TargetChoice", "Magic::Choice::Targeted", body),
         ["choice = TargetChoice.new(actor: #{context.this})", "game.add_choice(choice) if choice.choices.any?"]]
      end

      def calls(list, context) = list.map { expand(_1.resolve_call, context.this) }

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
