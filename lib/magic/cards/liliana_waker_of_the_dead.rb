module Magic
  module Cards
    class LilianaWakerOfTheDead < Planeswalker
      card_name "Liliana, Waker of the Dead"
      planeswalker "Liliana"
      cost generic: 2, black: 2
      loyalty 4

      # "+1: Each player discards a card. Each opponent who can't loses 3 life." Players with a card in hand are
      # asked which to discard.
      class LoyaltyAbility1 < LoyaltyAbility
        def loyalty_change = 1

        def resolve!
          game.players.each do |player|
            if player.hand.any?
              game.add_choice(Magic::Choice::Discard.new(player:))
            elsif game.opponents(controller).include?(player)
              trigger_effect(:lose_life, target: player, life: 3)
            end
          end
        end
      end

      # "-3: Target creature gets -X/-X until end of turn, where X is the number of cards in your graveyard."
      class LoyaltyAbility2 < LoyaltyAbility
        def loyalty_change = -3

        def target_choices = battlefield.creatures

        def single_target? = true

        def resolve!(target:)
          x = controller.graveyard.cards.count
          trigger_effect(:modify_power_toughness, target:, power: -x, toughness: -x)
        end
      end

      class ReanimateChoice < Magic::Choice::Targeted
        def choices
          game.players.flat_map { |player| player.graveyard.cards.select(&:creature?) }
        end

        def choice_amount = 1

        # "...put target creature card from a graveyard onto the battlefield under your control. It gains haste."
        def resolve!(target:)
          permanent = Permanent.resolve(game:, card: target, from_zone: target.zone, cast: false, controller:)
          permanent.grant_haste!
        end
      end

      # "At the beginning of combat on your turn, ..."
      class Emblem < Magic::Emblem
        def receive_event(event)
          return unless event.is_a?(Events::BeginningOfCombat) && event.active_player == owner

          choice = ReanimateChoice.new(actor: self)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      class LoyaltyAbility3 < LoyaltyAbility
        def loyalty_change = -7

        def resolve!
          game.add_emblem(Emblem.new(game: game, owner: controller))
        end
      end

      def loyalty_abilities = [LoyaltyAbility1, LoyaltyAbility2, LoyaltyAbility3]
    end
  end
end
