module Magic
  module Cards
    ClawsOfValakut = Aura("Claws of Valakut") do
      cost "{1}{R}{R}"
    end

    class ClawsOfValakut < Aura
      enchant "Creature"

      def target_choices
        battlefield.creatures
      end

      def static_abilities
        [PowerModification, KeywordGrantFirstStrike]
      end

      class PowerModification < Abilities::Static::PowerAndToughnessModification
        applies_to_target

        def power_modification
          source.controller.lands.by_any_type("Mountain").count
        end
      end

      class KeywordGrantFirstStrike < Abilities::Static::KeywordGrant
        keyword_grants Keywords::FIRST_STRIKE
        applies_to_target
      end
    end
  end
end
