module Magic
  module Cards
    DiversionSpecialist = Creature("Diversion Specialist") do
      cost generic: 3, red: 1
      creature_type "Human Warrior"
      power 4
      toughness 3
      keywords :menace
    end

    class DiversionSpecialist < Creature
      # "{1}, Sacrifice another creature or enchantment: Exile the top card of your library. You may play it this turn."
      class ExileTopAbility < Magic::ActivatedAbility
        costs "{1}, Sacrifice another creature or enchantment"

        def resolve!
          card = controller.library.first or return

          exile_target(card)
          game.play_permissions.grant_until_end_of_turn(card: card, player: controller)
        end
      end

      def activated_abilities = [ExileTopAbility]
    end
  end
end
