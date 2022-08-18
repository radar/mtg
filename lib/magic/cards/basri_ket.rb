module Magic
  module Cards
    class BasriKet < Planeswalker
      NAME = "Basri Ket"
      TYPE_LINE = "Legendary Planeswalker -- Basri"
      BASE_LOYALTY = 3

      class Emblem < Magic::Emblem
        def receive_event(event)
          case event
          when Events::BeginningOfCombat
            return unless event.active_player == controller
            game = controller.game

            token = Tokens::Soldier.new(game: game, controller: controller)
            token.resolve!

            controller.creatures.each do |creature|
              creature.add_counter(Counters::Plus1Plus1)
            end
          end
        end
      end

      class LoyaltyAbility1 < Magic::LoyaltyAbility
        def loyalty_change = 1

        def resolve!(targets:)
          target = targets.first
          target.add_counter(Counters::Plus1Plus1)
          target.grant_keyword(Keywords::INDESTRUCTIBLE, until_eot: true)
        end
      end

      class LoyaltyAbility2 < Magic::LoyaltyAbility
        def loyalty_change = -2

        def resolve!
          planeswalker.delayed_response(
            turn: game.current_turn,
            event_type: Events::AttackersDeclared,
            response: -> {
              attackers = game.current_turn.attacks.count

              attackers.times do
                token = Tokens::Soldier.new(game: game, controller: controller)
                token.play!
                token.tap!

                game.current_turn.declare_attacker(token)
              end
            }
          )
        end
      end

      class LoyaltyAbility3 < Magic::LoyaltyAbility
        def loyalty_change = -6

        def resolve!
          game.add_emblem(Emblem.new(controller: planeswalker.controller))
        end
      end
    end
  end
end
