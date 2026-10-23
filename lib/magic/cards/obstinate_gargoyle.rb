module Magic
  module Cards
    class ObstinateGargoyle < Creature
      card_name "Obstinate Gargoyle"
      artifact_creature_type "Gargoyle"
      cost generic: 1, white: 1, black: 1
      power 2
      toughness 2
      keywords :persist

      # "This creature has flying as long as it's modified."
      class ModifiedFlying < Abilities::Static::KeywordGrant
        keyword_grants Keywords::FLYING

        conditions { source.modified? }
        applicable_targets { [source] }
      end

      def static_abilities = [ModifiedFlying]
    end
  end
end
