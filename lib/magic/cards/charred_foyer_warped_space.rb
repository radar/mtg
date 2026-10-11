module Magic
  module Cards
    class CharredFoyerWarpedSpace < Room
      class CharredFoyer < Room::Door
        card_name "Charred Foyer"
        cost generic: 3, red: 1

        # "At the beginning of your upkeep, exile the top card of your library. You may play it this turn."
        class UpkeepTrigger < TriggeredAbility
          def should_perform?
            event.player == controller
          end

          def call
            card = controller.library.first
            return unless card

            card.exile!
            game.play_permissions.grant_until_end_of_turn(card: card, player: controller)
          end
        end

        def event_handlers = { Events::BeginningOfUpkeep => UpkeepTrigger }
      end

      class WarpedSpace < Room::Door
        card_name "Warped Space"
        cost generic: 4, red: 2

        # "Once each turn, you may pay {0} rather than pay the mana cost for a spell you cast from exile." Cast with
        # `pay_nothing: true` to use it.
        class PayNothingFromExile < StaticAbility
          def may_pay_nothing_for?(card, player)
            player == controller && card.zone&.exile? && !@source.activated_this_turn?(self.class)
          end

          def paid_nothing_for_spell!(card, player)
            @source.activated_this_turn!(self.class) if player == controller && card.zone&.exile?
          end
        end

        def static_abilities = [PayNothingFromExile]
      end

      doors CharredFoyer, WarpedSpace
    end
  end
end
