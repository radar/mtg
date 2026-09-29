module Magic
  module Cards
    class FeistySpikeling < Creature
      card_name "Feisty Spikeling"
      cost "{1}{R/W}"
      creature_type "Shapeshifter"
      power 2
      toughness 1
      keywords :changeling

      # "During your turn, this creature has first strike."
      class FirstStrikeOnYourTurn < Abilities::Static::KeywordGrant
        keyword_grants Keywords::FIRST_STRIKE

        conditions { game.current_turn.active_player == controller }

        def applicable_targets = [source]
      end

      def static_abilities = [FirstStrikeOnYourTurn]
    end
  end
end
