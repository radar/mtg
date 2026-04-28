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
              trigger_effect(:add_counter, target: creature, counter_type: "+1/+1")
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
          target.add_counter("+1/+1")
          target.grant_indestructible!
        end
      end

      class SoldierTokensTrigger < TriggeredAbility
        def call
          attackers = game.current_turn.attacks.count

          attackers.times do
            token = trigger_effect(:create_token, token_class: SoldierToken, enters_tapped: true).first
            game.current_turn.declare_attacker(token)
          end
        end
      end

      class LoyaltyAbility2 < Magic::LoyaltyAbility
        def loyalty_change = -2

        def resolve!
          source.register_turn_trigger(Events::PreliminaryAttackersDeclared, SoldierTokensTrigger)
        end
      end

      class LoyaltyAbility3 < Magic::LoyaltyAbility
        def loyalty_change = -6

        def resolve!
          game.add_emblem(Emblem.new(game: game, owner: source.controller))
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
