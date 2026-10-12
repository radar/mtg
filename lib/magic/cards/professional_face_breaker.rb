module Magic
  module Cards
    ProfessionalFaceBreaker = Creature("Professional Face-Breaker") do
      cost generic: 2, red: 1
      creature_type "Human Warrior"
      keywords :menace
      power 2
      toughness 3
    end

    class ProfessionalFaceBreaker < Creature
      # "Whenever one or more creatures you control deal combat damage to a player, create a Treasure token." One
      # token per combat damage step however many creatures deal damage in it.
      class TreasureTrigger < TriggeredAbility
        def should_perform?
          event.combat? && event.target.player? && event.source.respond_to?(:controller) &&
            event.source.controller == controller && !already_triggered_this_step?
        end

        def call
          actor.state[:treasure_step] = step_key
          trigger_effect(:create_token, token_class: Tokens::Treasure)
        end

        private

        def step_key = [game.current_turn.number, game.current_turn.step]

        def already_triggered_this_step?
          actor.state[:treasure_step] == step_key
        end
      end

      # "Sacrifice a Treasure: Exile the top card of your library. You may play that card this turn."
      class ExileTopAbility < Magic::ActivatedAbility
        costs "Sacrifice a Treasure"

        def resolve!
          card = controller.library.first
          return unless card

          card.exile!
          game.play_permissions.grant_until_end_of_turn(card: card, player: controller)
        end
      end

      def activated_abilities = [ExileTopAbility]
      def event_handlers = { Events::DamageDealt => TreasureTrigger }
    end
  end
end
