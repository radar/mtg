module Magic
  module Cards
    ShadowOfTheSecondSun = Aura("Shadow of the Second Sun") do
      type T::Enchantment, "Aura"
      cost generic: 4, blue: 2
    end

    class ShadowOfTheSecondSun < Aura
      enchant :player

      def target_choices
        game.players
      end

      # "At the beginning of each of enchanted player's postcombat main phases, there is an additional beginning phase
      # after this phase."
      class AdditionalBeginningPhaseTrigger < TriggeredAbility
        def should_perform? = event.active_player == actor.attached_to

        def call
          game.current_turn.queue_additional_beginning_phase!
        end
      end

      def event_handlers
        { Events::SecondMainPhase => AdditionalBeginningPhaseTrigger }
      end
    end
  end
end
