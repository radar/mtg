module Magic
  module Cards
    CunningRhetoric = Enchantment("Cunning Rhetoric") do
      cost generic: 2, black: 1
    end

    class CunningRhetoric < Enchantment
      # Whenever an opponent attacks you and/or one or more planeswalkers you control,
      # exile the top card of that player's library.
      class AttackTrigger < TriggeredAbility
        def should_perform?
          event.active_player != controller && event.attacks.any? { attacks_you_or_your_planeswalkers?(_1.target) }
        end

        def attacks_you_or_your_planeswalkers?(target)
          target == controller || (target.is_a?(Magic::Permanent) && target.controller == controller)
        end

        def call
          card = event.active_player.library.first
          return unless card

          actor.exiled_cards << card
          card.exile!
        end
      end

      # You may play that card for as long as it remains exiled, and you may spend mana
      # as though it were mana of any color to cast it.
      class PlayPermission < Abilities::Static::AnyColorForAnyCost
        def permits_casting_from_exile?(card)
          @source.exiled_cards.include?(card)
        end

        def any_color_for?(card)
          @source.exiled_cards.include?(card)
        end
      end

      def event_handlers = { Events::FinalAttackersDeclared => AttackTrigger }
      def static_abilities = [PlayPermission]
    end
  end
end
