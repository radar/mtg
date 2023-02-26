module Magic
  module Cards
    ValorousSteed = Creature("Valorous Steed") do
      creature_type("Unicorn")
      cost white: 1, generic: 4
      power 3
      toughness 3

      keywords :vigilance

      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          Permanent.resolve(game: game, owner: controller, card: Tokens::Knight.new)
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
