module Magic
  module Cards
    ClockworkPercussionist = Creature("Clockwork Percussionist") do
      cost red: 1
      artifact_creature_type "Monkey Toy"
      power 1
      toughness 1
      keywords :haste
    end

    class ClockworkPercussionist < Creature
      # "When this creature dies, exile the top card of your library. You may play it until the end of your next turn."
      class DiesTrigger < TriggeredAbility::Death
        def call
          top = controller.library.first or return

          exile_target(top)
          game.play_permissions.grant_until_end_of_next_turn(card: top, player: controller)
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
