module Magic
  module Cards
    LegionsJudgement = Sorcery("Legion's Judgement") do
      cost white: 1, generic: 2
    end

    class LegionsJudgement < Sorcery
      def resolve!
        add_effect("DestroyTarget", choices: battlefield.creatures.with_power { |power| power >= 4 })

        super
      end
    end
  end
end
