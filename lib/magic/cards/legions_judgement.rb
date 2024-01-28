module Magic
  module Cards
    LegionsJudgement = Sorcery("Legion's Judgement") do
      cost white: 1, generic: 2
    end

    class LegionsJudgement < Sorcery
      def target_choices
        battlefield.creatures.with_power { |power| power >= 4 }
      end

      def single_target?
        true
      end

      def resolve!(target:)
        trigger_effect(:destroy_target, target: target)

        super
      end
    end
  end
end
