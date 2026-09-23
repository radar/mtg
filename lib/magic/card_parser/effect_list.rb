# frozen_string_literal: true

module Magic
  class CardParser
    # The effects of one spell or ability, in order, rendered as Ruby. Effects
    # after a choice point (a scry, or a target in a triggered ability) run
    # once that choice resolves, in a Choice subclass generated alongside.
    class EffectList < Data.define(:effects)
      SENTENCE = /(?<=\.)\s+|,? then |,? and (?=you )/i

      # `text` as one effect (some span two sentences), else every sentence as an
      # effect; nil unless all of them parse.
      def self.parse(text)
        effect = Effect.parse(text) and return new(effects: [effect])

        effects = text.split(SENTENCE).map { |sentence| Effect.parse(sentence[0].upcase + sentence[1..]) }
        new(effects:) if effects.any? && effects.all?
      end

      def initialize(effects:)
        raise UnsupportedCard, "only one targeted effect per ability is supported" if effects.count(&:target_choices) > 1

        super
      end

      def +(other) = self.class.new(effects: effects + other.effects)

      # Class body for an instant, sorcery or activated ability: target_choices
      # and resolve!(target:) when targeted, a choice class for a scry.
      def spell_source
        now, choice, later = split(&:choice_base)
        raise UnsupportedCard, "targeted effects after a choice are not supported" if later.any?(&:target_choices)

        targeted = effects.find(&:target_choices)
        sections = definitions
        sections.concat(choice_class(choice, later)) if choice
        sections << "def target_choices\n  #{targeted.target_choices}\nend\n" if targeted
        sections << method("resolve!#{'(target:)' if targeted}", statements(now) + add_choice(choice, "self", later))
        sections.join("\n")
      end

      # Class body for a triggered or chapter ability, whose `entry` method runs
      # the effects. Targets are chosen with a Choice; with none to choose from,
      # the ability does nothing from the targeted effect on.
      def trigger_source(entry: "call")
        now, choice, later = split { _1.choice_base || _1.target_choices }
        sections = definitions
        sections.concat(choice_class(choice, later)) if choice
        sections << method(entry, statements(now) + add_choice(choice, "actor", later))
        sections.join("\n")
      end

      private

      # [effects before the first choice point, that effect, effects after it]
      def split(&choice_point)
        index = effects.index(&choice_point) or return [effects, nil, []]
        later = effects[(index + 1)..]
        raise UnsupportedCard, "only one choice per ability is supported" if later.any?(&choice_point)

        [effects[...index], effects[index], later]
      end

      def definitions = effects.filter_map(&:definitions).uniq

      def statements(effects) = effects.map(&:resolve_call)

      # The Choice subclass that runs the effects after a choice point; none
      # for a choice effect with nothing after it (its base class will do).
      def choice_class(choice, later)
        if choice.choice_base
          return [] if later.empty?

          body = method("resolve!(**args)", ["super(**args)", *statements(later)])
          ["class #{choice.choice_class_name} < #{choice.choice_base}\n#{indent(body)}\nend\n"]
        else
          body = [method("choices", [choice.target_choices]), "def choice_amount = 1\n",
                  method("resolve!(target:)", statements([choice, *later]))].join("\n")
          ["class TargetChoice < Magic::Choice::Targeted\n#{indent(body)}\nend\n"]
        end
      end

      def add_choice(choice, actor, later)
        return [] unless choice

        if choice.choice_base
          klass = later.empty? ? choice.choice_base : choice.choice_class_name
          return ["game.choices.add(#{klass}.new(#{["actor: #{actor}", *choice.choice_args].join(', ')}))"]
        end

        ["choice = TargetChoice.new(actor: #{actor})", "game.add_choice(choice) if choice.choices.any?"]
      end

      def method(signature, lines)
        "def #{signature}\n#{lines.map { "  #{_1}\n" }.join}end\n"
      end

      def indent(source) = source.gsub(/^(?=.)/, "  ").chomp
    end
  end
end
