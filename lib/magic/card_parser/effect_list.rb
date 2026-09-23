# frozen_string_literal: true

module Magic
  class CardParser
    # The effects of one spell or ability, in order, rendered as Ruby. Effects
    # after a choice point (a scry, or a target in a triggered ability) run
    # once that choice resolves, in a Choice subclass generated alongside.
    class EffectList < Data.define(:effects)
      SENTENCE = /(?<=\.)\s+|,? then /i

      # Every sentence of `text` as an effect, or nil unless all of them parse.
      def self.parse(text)
        effects = text.split(SENTENCE).map { |sentence| Effect.parse(sentence[0].upcase + sentence[1..]) }
        new(effects:) if effects.any? && effects.all?
      end

      def initialize(effects:)
        raise UnsupportedCard, "only one targeted effect per ability is supported" if effects.count(&:target_choices) > 1

        super
      end

      def +(other) = self.class.new(effects: effects + other.effects)

      # Class body for an instant or sorcery: target_choices and resolve!(target:)
      # for a targeted spell, a choice class for a scry.
      def spell_source
        now, choice, later = split(&:choice_base)
        raise UnsupportedCard, "targeted effects after a choice are not supported" if later.any?(&:target_choices)

        targeted = effects.find(&:target_choices)
        sections = definitions
        sections << choice_class(choice, later) if choice
        sections << "def target_choices\n  #{targeted.target_choices}\nend\n" if targeted
        sections << method("resolve!#{'(target:)' if targeted}", statements(now) + [add_choice(choice, "self")].compact)
        sections.join("\n")
      end

      # Class body for a triggered ability. Targets are chosen with a Choice.
      def trigger_source
        now, choice, later = split { _1.choice_base || _1.target_choices }
        sections = definitions
        sections << choice_class(choice, later) if choice
        sections << method("call", statements(now) + [add_choice(choice, "actor")].compact)
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

      def definitions = effects.flat_map(&:definitions).uniq

      def statements(effects) = effects.map(&:resolve_call)

      def choice_class(choice, later)
        if choice.choice_base
          body = method("resolve!(**args)", ["super(**args)", *statements(later)])
          "class #{choice.choice_class_name} < #{choice.choice_base}\n#{indent(body)}\nend\n"
        else
          body = [method("choices", [choice.target_choices]), method("resolve!(target:)", statements([choice, *later]))].join("\n")
          "class TargetChoice < Magic::Choice::Targeted\n#{indent(body)}\nend\n"
        end
      end

      def add_choice(choice, actor)
        return unless choice

        name = choice.choice_base ? choice.choice_class_name : "TargetChoice"
        args = ["actor: #{actor}", *(choice.choice_args if choice.choice_base)].join(", ")
        "game.choices.add(#{name}.new(#{args}))"
      end

      def method(signature, lines)
        "def #{signature}\n#{lines.map { "  #{_1}\n" }.join}end\n"
      end

      def indent(source) = source.gsub(/^(?=.)/, "  ").chomp
    end
  end
end
