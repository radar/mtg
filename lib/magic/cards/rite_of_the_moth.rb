module Magic
  module Cards
    class RiteOfTheMoth < Sorcery
      card_name "Rite of the Moth"
      cost generic: 1, white: 1, black: 2
      flashback Costs::Mana.new(generic: 3, white: 2, black: 1)

      def single_target? = true

      def target_choices
        controller.graveyard.cards.select(&:creature?)
      end

      # "Return target creature card from your graveyard to the battlefield with a finality counter on it."
      def resolve!(target:)
        Permanent.put_onto_battlefield(game: game, card: target, from_zone: target.zone, controller: controller, counters: { "finality" => 1 })
      end
    end
  end
end
