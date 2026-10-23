module Magic
  module Cards
    class TamiyoSeasonedScholar < Planeswalker
      card_name "Tamiyo, Seasoned Scholar"
      type T::Super::Legendary, T::Planeswalker, "Tamiyo"
      color_indicator :blue
      loyalty 2

      # "+2: Until your next turn, whenever a creature attacks you or a planeswalker you control, it gets -1/-0 until end
      # of turn." Tamiyo flags the effect with `remember_until_turn_of!`, which clears it as her controller's next
      # upkeep begins.
      class LoyaltyAbility1 < LoyaltyAbility
        def loyalty_change = 2
        def description = "Until your next turn, whenever a creature attacks you or a planeswalker you control, it gets -1/-0 until end of turn."

        def resolve!
          source.remember_until_turn_of!(:shielding, controller)
        end
      end

      class AttackTrigger < TriggeredAbility
        def should_perform?
          return false unless actor.state[:shielding]

          target = event.target
          target == controller || (target.is_a?(Permanent) && target.planeswalker? && target.controller == controller)
        end

        def call
          pump(event.attacker, -1, 0)
        end
      end

      # "-3: Return target instant or sorcery card from your graveyard to your hand. If it's a green card, add one mana
      # of any color."
      class ManaChoice < Magic::Choice
        def modes
          { white: "Add {W}", blue: "Add {U}", black: "Add {B}", red: "Add {R}", green: "Add {G}" }
        end

        def resolve!(mode:)
          controller.add_mana(mode => 1)
        end
      end

      class LoyaltyAbility2 < LoyaltyAbility
        def loyalty_change = -3
        def description = "Return target instant or sorcery card from your graveyard to your hand. If it's a green card, add one mana of any color."

        def target_choices = controller.graveyard.cards.select { _1.instant? || _1.sorcery? }

        def single_target? = true

        def resolve!(target:)
          target.move_to_hand!
          game.choices.add(ManaChoice.new(actor: source)) if target.colors.include?(:green)
        end
      end

      class HandSizeEmblem < Magic::Emblem
        def no_maximum_hand_size? = true
      end

      # "-7: Draw cards equal to half the number of cards in your library, rounded up. You get an emblem with 'You have
      # no maximum hand size.'"
      class LoyaltyAbility3 < LoyaltyAbility
        def loyalty_change = -7
        def description = "Draw cards equal to half the number of cards in your library, rounded up. You get an emblem with \"You have no maximum hand size.\""

        def resolve!
          (controller.library.count / 2.0).ceil.times { controller.draw! }
          game.add_emblem(HandSizeEmblem.new(game: game, owner: controller))
        end
      end

      def event_handlers = { Events::CreatureAttacked => AttackTrigger }

      def loyalty_abilities = [LoyaltyAbility1, LoyaltyAbility2, LoyaltyAbility3]
    end

    class TamiyoInquisitiveStudent < Creature
      card_name "Tamiyo, Inquisitive Student"
      cost blue: 1
      legendary_creature_type "Moonfolk Wizard"
      keywords :flying
      power 0
      toughness 3
      back_face TamiyoSeasonedScholar

      # "Whenever Tamiyo attacks, investigate."
      class AttackTrigger < TriggeredAbility
        def should_perform? = event.attacker == actor

        def call = create_token(token: Tokens::Clue)
      end

      # "When you draw your third card in a turn, exile Tamiyo, then return her to the battlefield transformed under her
      # owner's control."
      class ThirdCardTrigger < TriggeredAbility
        def should_perform?
          you? && game.current_turn.events.count { |e| e.is_a?(Events::CardDraw) && e.player == event.player } == 3
        end

        def call = actor.exile_and_return_transformed!
      end

      def event_handlers = {
        Events::CreatureAttacked => AttackTrigger,
        Events::CardDraw => ThirdCardTrigger
      }
    end
  end
end
