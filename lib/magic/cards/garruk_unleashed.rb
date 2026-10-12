module Magic
  module Cards
    class GarrukUnleashed < Planeswalker
      card_name "Garruk, Unleashed"
      planeswalker "Garruk"
      cost generic: 2, green: 2
      loyalty 4

      BeastToken = Token.create("Beast") do
        creature_type "Beast"
        power 3
        toughness 3
        colors :green
      end

      # "Up to one target creature gets +3/+3 and gains trample until end of turn." Declining is
      # `game.skip_choice!`.
      class PumpChoice < Magic::Choice::Targeted
        def choices = battlefield.creatures
        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:modify_power_toughness, target: target, power: 3, toughness: 3)
          target.grant_keyword(Keywords::TRAMPLE)
        end
      end

      class LoyaltyAbility1 < LoyaltyAbility
        def loyalty_change = 1
        def description = "Up to one target creature gets +3/+3 and gains trample until end of turn."

        def resolve!
          choice = PumpChoice.new(actor: source)
          game.choices.add(choice) if choice.choices.any?
        end
      end

      class LoyaltyAbility2 < LoyaltyAbility
        def loyalty_change = -2
        def description = "Create a 3/3 green Beast creature token. Then if an opponent controls more creatures than you, put a loyalty counter on Garruk."

        def resolve!
          trigger_effect(:create_token, token_class: BeastToken)
          opponent_has_more = game.opponents(controller).any? { |opponent| opponent.creatures.count > controller.creatures.count }
          source.change_loyalty!(1) if opponent_has_more
        end
      end

      # "At the beginning of your end step, you may search your library for a creature card, put it
      # onto the battlefield, then shuffle."
      class Emblem < Magic::Emblem
        def receive_event(event)
          return unless event.is_a?(Events::BeginningOfEndStep) && event.active_player == owner

          game.search_library(self, find: :creatures, to: :battlefield)
        end
      end

      class LoyaltyAbility3 < LoyaltyAbility
        def loyalty_change = -7
        def description = "You get an emblem with \"At the beginning of your end step, you may search your library for a creature card, put it onto the battlefield, then shuffle.\""

        def resolve!
          game.add_emblem(Emblem.new(game: game, owner: controller))
        end
      end

      def loyalty_abilities = [LoyaltyAbility1, LoyaltyAbility2, LoyaltyAbility3]
    end
  end
end
