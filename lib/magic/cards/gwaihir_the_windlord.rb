module Magic
  module Cards
    GwaihirTheWindlord = Creature("Gwaihir the Windlord") do
      cost generic: 4, white: 1, blue: 1
      legendary_creature_type "Bird Noble"
      power 4
      toughness 4
      keywords :flying, :vigilance
    end

    class GwaihirTheWindlord < Creature
      # "This spell costs {2} less to cast as long as you've drawn two or more cards this turn."
      def self_mana_cost_adjustment
        player = controller || owner
        { generic: -> { cards_drawn_this_turn(player) >= 2 ? -2 : 0 } }
      end

      def cards_drawn_this_turn(player)
        return 0 unless game&.current_turn

        game.current_turn.events.count { _1.is_a?(Events::CardDraw) && _1.player == player }
      end

      # "Other Birds you control have vigilance."
      class BirdsVigilance < Abilities::Static::KeywordGrant
        keyword_grants Keywords::VIGILANCE
        applicable_targets { source.controller.creatures.select { _1.type?("Bird") && _1 != source } }
      end

      def static_abilities = [BirdsVigilance]
    end
  end
end
