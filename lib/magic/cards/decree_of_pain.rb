module Magic
  module Cards
    class DecreeOfPain < Sorcery
      card_name "Decree of Pain"
      cost generic: 6, black: 2
      cycling generic: 3, black: 2

      # "Destroy all creatures. They can't be regenerated. Draw a card for each creature destroyed this way."
      def resolve!
        creatures = game.battlefield.creatures.to_a
        creatures.each { trigger_effect(:destroy_target, target: _1) }
        destroyed = creatures.count { _1.zone.nil? }
        draw_cards(destroyed) if destroyed.positive?
      end

      # "When you cycle this card, all creatures get -2/-2 until end of turn."
      def cycling_effect!
        super
        game.battlefield.creatures.each do |creature|
          pump(creature, -2, -2)
        end
      end
    end
  end
end
