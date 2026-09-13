module Magic
  module Cards
    class ObNixilisReignited < Planeswalker
      card_name "Ob Nixilis Reignited"
      planeswalker "Nixilis"
      cost "{3}{B}{B}"
      loyalty 5

      class LoyaltyAbility1 < LoyaltyAbility
        def loyalty_change = 1

        def resolve!
          trigger_effect(:draw_cards)
          trigger_effect(:lose_life, target: controller, life: 1)
        end
      end

      class LoyaltyAbility2 < LoyaltyAbility
        def loyalty_change = -3

        def single_target?
          true
        end

        def target_choices
          battlefield.creatures
        end

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
        end
      end

      class Emblem < Magic::Emblem
        def receive_event(event)
          case event
          when Events::CardDraw
            trigger_effect(:lose_life, target: owner, life: 2)
          end
        end
      end

      class LoyaltyAbility3 < LoyaltyAbility
        def loyalty_change = -8

        def single_target?
          true
        end

        def target_choices
          game.opponents(controller)
        end

        def resolve!(target:)
          game.add_emblem(Emblem.new(game: game, owner: target))
        end
      end

      def loyalty_abilities = [LoyaltyAbility1, LoyaltyAbility2, LoyaltyAbility3]
    end
  end
end
