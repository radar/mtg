module Magic
  module Cards
    SecureTheScene = Sorcery("Secure the Scene") do
      cost white: 1, generic: 4
    end

    class SecureTheScene < Sorcery
      SoldierToken = Token.create("Soldier") do
        creature_type "Soldier"
        power 1
        toughness 1
        colors :white
      end

      def target_choices
        battlefield.creatures
      end

      def single_target?
        true
      end

      def resolve!(target:)
        trigger_effect(:exile, target: target)

        target.controller.create_token(token_class: SoldierToken)
      end
    end
  end
end
