module Magic
  module Cards
    BloodlineBidding = Sorcery("Bloodline Bidding") do
      cost generic: 6, black: 2
      convoke
    end

    class BloodlineBidding < Sorcery
      # Return all creature cards of the chosen type from your graveyard to the battlefield.
      class TypeChoice < Magic::Choice::CreatureType
        def resolve!(creature_type:)
          controller.graveyard.select { |card| card.creature? && card.type?(creature_type) }.each do |card|
            Permanent.resolve(card: card, game: game, from_zone: card.zone, cast: false, controller: controller)
          end
        end
      end

      def resolve!
        game.choices.add(TypeChoice.new(actor: self))
      end
    end
  end
end
