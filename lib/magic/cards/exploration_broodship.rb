module Magic
  module Cards
    class ExplorationBroodship < Spacecraft
      card_name "Exploration Broodship"
      cost green: 1
      power 4
      toughness 4

      class FlyingGrant < Abilities::Static::KeywordGrant
        keyword_grants Keywords::FLYING

        def applicable_targets = [@source]
      end

      # "Once during each of your turns, you may cast a permanent spell from your graveyard by sacrificing a land in
      # addition to paying its other costs."
      class CastPermanentsFromGraveyard < StaticAbility
        def permits_casting_from_graveyard?(card, player)
          castable?(card, player)
        end

        def additional_cost_for(card, player)
          Costs::Sacrifice.new(@source, player.lands) if card.zone&.graveyard? && castable?(card, player)
        end

        def cast_from_graveyard!(card, player)
          @source.activated_this_turn!(self.class) if castable?(card, player)
        end

        private

        # No check that a land can be sacrificed: the land is sacrificed before legality is checked.
        def castable?(card, player)
          player == controller && game.current_turn.active_player == player && card.owner == player &&
            card.permanent? && !card.land? && !@source.activated_this_turn?(self.class)
        end
      end

      # 3+ | You may play an additional land on each of your turns.
      station_level 3, additional_lands: 1
      # 8+ | Flying, and the graveyard permission.
      station_level 8, static_abilities: [FlyingGrant, CastPermanentsFromGraveyard]
      becomes_creature_at 8
    end
  end
end
