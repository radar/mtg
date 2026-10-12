module Magic
  module Cards
    class SeasonOfWeaving < Sorcery
      card_name "Season of Weaving"
      cost generic: 4, blue: 2

      # {P} -- Draw a card.
      class DrawCard < Mode
        points 1

        def resolve!
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      # {P}{P} -- Choose an artifact or creature you control. Create a token that's a copy of it.
      class CopyPermanent < Mode
        points 2

        def target_choices = battlefield.controlled_by(controller).select { _1.creature? || _1.artifact? }

        def resolve!(target:)
          Permanent.token_copy(game: game, owner: controller, card: target.copiable_card)
        end
      end

      # {P}{P}{P} -- Return each nonland, nontoken permanent to its owner's hand.
      class BounceAll < Mode
        points 3

        def resolve!
          battlefield.reject { _1.land? || _1.token? }.each { trigger_effect(:return_to_owners_hand, target: _1) }
        end
      end

      modes DrawCard, CopyPermanent, BounceAll
      modes_budget 5
    end
  end
end
