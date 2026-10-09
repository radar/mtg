module Magic
  module Cards
    class SupperForSpiders < Instant
      card_name "Supper for Spiders"
      cost generic: 1, black: 1

      # Creature cards in your opponents' graveyards that were put there from the battlefield this turn.
      def fresh_corpses
        died = game.current_turn.events.select { _1.is_a?(Events::CardEnteredZone) && _1.from&.battlefield? && _1.to&.graveyard? }.map(&:card)
        game.opponents(controller).flat_map { |opponent| opponent.graveyard.cards.to_a }
          .select { |card| card.creature? && died.include?(card) }
      end

      # "Put onto the battlefield under your control all creature cards in your opponents' graveyards that were put
      # there from the battlefield this turn. They are Food artifacts with '{2}, {T}, Sacrifice this artifact: You gain
      # 3 life.' (They lose all other types and subtypes.)"
      def resolve!
        fresh_corpses.each do |card|
          permanent = Permanent.resolve(card: card, game: game, from_zone: card.zone, cast: false, controller: controller)
          lost = permanent.types - [T::Artifact]
          permanent.remove_types(*lost, until_eot: false)
          permanent.add_types(T::Artifact, "Food", until_eot: false)
          permanent.grant_activated_ability!(Tokens::Food::GainLife)
        end
      end
    end
  end
end
