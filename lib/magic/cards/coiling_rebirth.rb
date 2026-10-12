module Magic
  module Cards
    class CoilingRebirth < Sorcery
      card_name "Coiling Rebirth"
      cost generic: 3, black: 2
      gift :card

      def target_choices = controller.graveyard.creatures

      # Return target creature card from your graveyard to the battlefield. Then if the gift was promised and
      # that creature isn't legendary, create a token that's a copy of that creature, except it's 1/1.
      def resolve!(target:)
        legendary = target.legendary?
        returned = Permanent.resolve(card: target, game: game, from_zone: target.zone, cast: false, controller: controller)
        return unless gift_promised? && !legendary && returned

        copy = Permanent.resolve(game: game, owner: controller, card: returned.copiable_card, token: true, copy: true, cast: false)
        return unless copy

        copy.modify_base_power(1, until_eot: false)
        copy.modify_base_toughness(1, until_eot: false)
      end
    end
  end
end
