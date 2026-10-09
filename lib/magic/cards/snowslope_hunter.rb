module Magic
  module Cards
    SnowslopeHunter = Creature("Snowslope Hunter") do
      cost generic: 2, red: 1
      creature_type("Goblin Ranger")
      power 2
      toughness 3
    end

    class SnowslopeHunter < Creature
      # "Sacrifice another creature or artifact: Exile the top card of your library. You may play it until the end of
      # your next turn. Activate only during your turn and only once each turn."
      class ExileTopAbility < Magic::ActivatedAbility
        once_each_turn

        class SacrificeCost < Costs::Sacrifice
          def pay(payment:)
            raise ArgumentError, "#{payment.name} can't be sacrificed for this cost" unless choices.include?(payment)

            super
          end
        end

        def costs
          [SacrificeCost.new(source, controller.permanents.select { _1 != source && (_1.creature? || _1.artifact?) })]
        end

        def requirements_met?
          game.current_turn.active_player == controller
        end

        def resolve!
          top = controller.library.first or return

          trigger_effect(:exile, target: top)
          game.play_permissions.grant_until_end_of_next_turn(card: top, player: controller)
        end
      end

      def activated_abilities = [ExileTopAbility]
    end
  end
end
