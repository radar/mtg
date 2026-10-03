# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "You may cast target Zombie creature card from your graveyard this turn." (Zul Ashur): a permission
      # that lasts to end of turn (`game.play_permissions.grant_until_end_of_turn(from_graveyard: true)`);
      # casting it is a normal cast, at the card's normal timing, for its normal cost.
      class GrantCastFromGraveyard < Data.define(:filter)
        include Effect

        LINE = /\AYou may cast target (?<filter>[^.]*?) cards? from your graveyard this turn\.?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text))

          filter = ReturnCards.parse_filter(m[:filter].strip, nil) or return
          new(filter:)
        end

        def target_choices
          filter.empty? ? "controller.graveyard.cards" : "controller.graveyard.cards.select { #{filter.join(' && ')} }"
        end

        def resolve_call = "game.play_permissions.grant_until_end_of_turn(card: target, player: controller, from_graveyard: true)"
      end
    end
  end
end
