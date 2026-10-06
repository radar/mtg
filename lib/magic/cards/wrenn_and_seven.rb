module Magic
  module Cards
    class WrennAndSeven < Planeswalker
      card_name "Wrenn and Seven"
      planeswalker "Wrenn"
      cost generic: 3, green: 2
      loyalty 5

      class LoyaltyAbility1 < LoyaltyAbility
        def loyalty_change = 1
        def description = "Reveal the top four cards of your library. Put all land cards revealed this way into your hand and the rest into your graveyard."

        def resolve!
          cards = library.first(4)
          controller.reveal(*cards)

          cards.each do |card|
            card.land? ? card.move_to_hand! : card.move_to_graveyard!
          end
        end
      end

      class TreefolkToken < Token
        token_name "Treefolk"
        creature_type "Treefolk"
        colors :green
        keywords :reach
        power 0
        toughness 0

        class DynamicPowerAndToughness < Abilities::Static::PowerAndToughnessModification
          def applicable_targets = [source]
          def power_modification = source.controller.lands.count
          alias_method :toughness_modification, :power_modification
        end

        def static_abilities = [DynamicPowerAndToughness]
      end

      class LoyaltyAbility2 < LoyaltyAbility
        def loyalty_change = 0
        def description = "Put any number of land cards from your hand onto the battlefield tapped."

        def resolve!
          game.choices.add(Choice.new(actor: source))
        end

        class Choice < Magic::Choice::MoveToBattlefield
          def choices
            lands = hand.lands
            Magic::Targets::Choices.new(amount: 0..lands.count, choices: lands)
          end

          def resolve!(choices:)
            choices.each { |card| card.resolve!(enters_tapped: true) }
          end
        end
      end

      class LoyaltyAbility3 < LoyaltyAbility
        def loyalty_change = -3
        def description = "Create a green Treefolk creature token with reach and \"This token's power and toughness are each equal to the number of lands you control.\""

        def resolve!
          source.trigger_effect(:create_token, token_class: TreefolkToken)
        end
      end

      class LoyaltyAbility4 < LoyaltyAbility
        def loyalty_change = -8
        def description = "Return all permanent cards from your graveyard to your hand. You get an emblem with \"You have no maximum hand size.\""

        def resolve!
          graveyard.permanents.each(&:move_to_hand!)
          game.add_emblem(Magic::Emblem.new(game: game, owner: controller))
        end
      end

      def loyalty_abilities = [LoyaltyAbility1, LoyaltyAbility2, LoyaltyAbility3, LoyaltyAbility4]
    end
  end
end
