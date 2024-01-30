module Magic
  module Cards
    class BasriKet < Planeswalker
      NAME = "Basri Ket"
      TYPE_LINE = "#{T::Legendary} #{T::Planeswalker} -- Basri"
      BASE_LOYALTY = 3

      class Emblem < Magic::Emblem
        def receive_event(event)
          case event
          when Events::BeginningOfCombat
            return unless event.active_player == owner
            game = owner.game

            owner.create_token(token_class: SoldierToken)

            owner.creatures.each do |creature|
              creature.add_counter(Counters::Plus1Plus1)
            end
          end
        end
      end

      SoldierToken = Token.create("Soldier") do
        creature_type "Soldier"
        power 1
        toughness 1
        colors :white
      end

      class LoyaltyAbility1 < Magic::LoyaltyAbility
        def loyalty_change = 1

        def single_target?
          true
        end

        def resolve!(target:)
          target.add_counter(Counters::Plus1Plus1)
          target.grant_keyword(Keywords::INDESTRUCTIBLE, until_eot: true)
        end
      end

      class LoyaltyAbility2 < Magic::LoyaltyAbility
        def loyalty_change = -2

        def resolve!
          planeswalker.delayed_response(
            turn: game.current_turn,
            event_type: Events::PreliminaryAttackersDeclared,
            response: -> {
              attackers = game.current_turn.attacks.count

              attackers.times do
                token = planeswalker.controller.create_token(token_class: SoldierToken, enters_tapped: true)

                game.current_turn.declare_attacker(token)
              end
            }
          )
        end
      end

      class LoyaltyAbility3 < Magic::LoyaltyAbility
        def loyalty_change = -6

        def resolve!
          game.add_emblem(Emblem.new(owner: planeswalker.controller))
        end
      end

      def loyalty_abilities
        [
          LoyaltyAbility1,
          LoyaltyAbility2,
          LoyaltyAbility3,
        ]
      end
    end
  end
end
