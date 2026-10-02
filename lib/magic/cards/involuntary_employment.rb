module Magic
  module Cards
    InvoluntaryEmployment = Sorcery("Involuntary Employment") do
      cost generic: 3, red: 1
    end

    class InvoluntaryEmployment < Sorcery
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        target.gain_control_until_eot!(controller)
        target.untap!
        trigger_effect(:grant_keyword, target: target, keyword: :haste)
        trigger_effect(:create_token, token_class: Tokens::Treasure)
      end
    end
  end
end
