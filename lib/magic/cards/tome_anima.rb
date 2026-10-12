module Magic
  module Cards
    TomeAnima = Creature("Tome Anima") do
      cost generic: 3, blue: 1
      creature_type "Spirit"
      power 3
      toughness 3
    end

    class TomeAnima < Creature
      # "This creature can't be blocked as long as you've drawn two or more cards this turn."
      class Unblockable < Abilities::Static::KeywordGrant
        keyword_grants Keywords::CANT_BE_BLOCKED
        applicable_targets { [source] }
        conditions { game.current_turn.events.count { |e| e.is_a?(Events::CardDraw) && e.player == controller } >= 2 }
      end

      def static_abilities = [Unblockable]
    end
  end
end
