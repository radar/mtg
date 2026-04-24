module Magic
  module Cards
    class BasriKet < Planeswalker
      card_name "Basri Ket"
      type T::Super::Legendary, T::Planeswalker, "Basri"
      loyalty 3

      class Emblem < Magic::Emblem
        def receive_event(event)
          case event
          when Events::BeginningOfCombat
            return unless event.active_player == owner
            game = owner.game

            trigger_effect(:create_token, token_class: SoldierToken, controller: owner)

            owner.creatures.each do |creature|
              trigger_effect(:add_counter, target: creature, counter_type: Counters::Plus1Plus1)
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
          target.add_counter(counter_type: Counters::Plus1Plus1)
          target.grant_keyword(Keywords::INDESTRUCTIBLE, until_eot: true)
        end
      end

      class LoyaltyAbility2 < Magic::LoyaltyAbility
        def loyalty_change = -2

        def resolve!
          source.card.minus2_active_turn = game.current_turn.number
        end
      end

      class PreliminaryAttackersHandler < TriggeredAbility
        def should_perform?
          actor.card.minus2_active_turn == game.current_turn.number
        end

        def call
          attackers = game.current_turn.attacks.count
          attackers.times do
            token = trigger_effect(:create_token, token_class: SoldierToken, enters_tapped: true).first
            game.current_turn.declare_attacker(token)
          end
        end
      end

      class LoyaltyAbility3 < Magic::LoyaltyAbility
        def loyalty_change = -6

        def resolve!
          game.add_emblem(Emblem.new(game: game, owner: source.controller))
        end
      end

      attr_accessor :minus2_active_turn

      def loyalty_abilities
        [
          LoyaltyAbility1,
          LoyaltyAbility2,
          LoyaltyAbility3,
        ]
      end

      def event_handlers
        {
          Events::PreliminaryAttackersDeclared => PreliminaryAttackersHandler
        }
      end
    end
  end
end
