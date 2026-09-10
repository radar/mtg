module Magic
  module Cards
    SerpentsSoulJar = Artifact("Serpent's Soul-Jar") do
      cost generic: 2, black: 1
    end

    class SerpentsSoulJar < Artifact
      class ElfDiedTrigger < TriggeredAbility
        def should_perform?
          event.to.graveyard? &&
            event.permanent.type?("Elf") &&
            event.permanent.controller == controller
        end

        def call
          card = event.permanent.card
          actor.trigger_effect(:exile, target: card)
          actor.exiled_cards << card
        end
      end

      def event_handlers
        {
          Events::LeftTheBattlefield => ElfDiedTrigger
        }
      end

      class CastPermission < StaticAbility
        def permits_casting_from_exile?(card)
          @source.exile_cast_permission_turn == game.current_turn.number &&
            card.creature? &&
            @source.exiled_cards.include?(card)
        end
      end

      def static_abilities = [CastPermission]

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{T}"

        def resolve!
          controller.lose_life(2)
          source.exile_cast_permission_turn = game.current_turn.number
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
