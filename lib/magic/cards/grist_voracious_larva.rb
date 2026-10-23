module Magic
  module Cards
    class GristThePlagueSwarm < Planeswalker
      card_name "Grist, the Plague Swarm"
      type T::Super::Legendary, T::Planeswalker, "Grist"
      color_indicator :black, :green
      loyalty 3

      InsectToken = Token.create("Insect") do
        creature_type "Insect"
        colors :black, :green
        power 1
        toughness 1
      end

      # "+1: Create a 1/1 black and green Insect creature token, then mill two cards. Put a deathtouch counter on
      # the token if a black card was milled this way."
      class LoyaltyAbility1 < LoyaltyAbility
        def loyalty_change = 1
        def description = "Create a 1/1 black and green Insect creature token, then mill two cards. Put a deathtouch counter on the token if a black card was milled this way."

        def resolve!
          tokens = [*create_token(token: InsectToken)]
          milled = controller.mill(2)
          return unless milled.any? { _1.colors.include?(:black) }

          tokens.each { add_counter Counters::Deathtouch, to: _1 }
        end
      end

      # "-2: Destroy target artifact or enchantment."
      class LoyaltyAbility2 < LoyaltyAbility
        def loyalty_change = -2
        def description = "Destroy target artifact or enchantment."

        def target_choices = battlefield.select { _1.artifact? || _1.enchantment? }

        def single_target? = true

        def resolve!(target:) = target.destroy!
      end

      # "-6: For each creature card in your graveyard, create a token that's a copy of it, except it's a 1/1 black
      # and green Insect."
      class LoyaltyAbility3 < LoyaltyAbility
        def loyalty_change = -6
        def description = "For each creature card in your graveyard, create a token that's a copy of it, except it's a 1/1 black and green Insect."

        def resolve!
          controller.graveyard.cards.select(&:creature?).each do |card|
            [*copy_as_token(card, base_power: 1, base_toughness: 1)].each do |token|
              token.become_creature_type!("Insect")
              token.change_colors!([:black, :green], until_eot: false)
            end
          end
        end
      end

      def loyalty_abilities = [LoyaltyAbility1, LoyaltyAbility2, LoyaltyAbility3]
    end

    class GristVoraciousLarva < Creature
      card_name "Grist, Voracious Larva"
      cost green: 1
      legendary_creature_type "Insect"
      power 1
      toughness 2
      keywords :deathtouch
      back_face GristThePlagueSwarm

      class PayChoice < Magic::Choice::PayToTransform
        def prompt = "Pay {G} to exile Grist and return it transformed?"

        def transform! = actor.exile_and_return_transformed!
      end

      # "Whenever Grist or another creature you control enters, if it entered from your graveyard or you cast it
      # from your graveyard, you may pay {G}. If you do, exile Grist, then return it to the battlefield
      # transformed under its owner's control."
      class EntersFromGraveyardTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent.creature? && event.permanent.controller == controller && event.permanent.entered_from_graveyard?
        end

        def call
          mana = { green: 1 }
          game.choices.add(PayChoice.new(actor:, mana:)) if Costs::Mana.new(mana).can_pay?(controller)
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => EntersFromGraveyardTrigger }
    end
  end
end
