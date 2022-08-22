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
        game.add_effect(Effects::DestroyTarget.new(source: self,  targets: [target], choices: target_choices))

        super()
      end
    end
  end
end
