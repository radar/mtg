module Magic
  module Cards
    ValorousSteed = Creature("Valorous Steed") do
      creature_type("Unicorn")
      cost white: 1, generic: 4
      power 3
      toughness 3
      keywords :vigilance

      KnightToken = Token.create("Knight") do
        creature_type "Knight"
        power 2
        toughness 2
        colors :white
        keywords :vigilance
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          actor.trigger_effect(:create_token, token_class: KnightToken)
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
