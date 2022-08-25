module Magic
  module Cards
    RunedHalo = Enchantment("Runed Halo") do
      cost white: 2
    end

    class RunedHalo < Enchantment
      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          game.add_effect(
            Effects::ChooseACard.new(
              source: permanent,
              resolution: -> (chosen_card) do
                permanent.protections << Protection.new(condition: -> (c) { chosen_card == c.class }, protects_player: true)
              end
            )
          )
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
