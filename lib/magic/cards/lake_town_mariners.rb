module Magic
  module Cards
    LakeTownMariners = Creature("Lake-town Mariners") do
      cost generic: 4, blue: 2
      creature_type "Human Citizen"
      power 6
      toughness 5
      keywords :vigilance
      ward generic: 2
    end

    class LakeTownMariners < Creature
      # Gone Fishing {3}{U}, Instant -- Adventure: "Exile two target creatures and/or lands you control, then return
      # them to the battlefield under their owner's control."
      adventure generic: 3, blue: 1

      def adventure_instant? = true

      def target_choices
        battlefield.controlled_by(controller).select { |permanent| permanent.creature? || permanent.land? }
      end

      def number_of_targets(_x = nil) = 2

      def distinct_targets? = true

      def adventure_resolve!(targets:, **)
        cards = targets.map(&:card)
        targets.each { |target| trigger_effect(:exile, target: target) }
        cards.each do |card|
          next if card.token?

          Permanent.resolve(game: game, card: card, owner: card.owner, cast: false)
        end
      end
    end
  end
end
