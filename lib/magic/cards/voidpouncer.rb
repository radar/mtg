module Magic
  module Cards
    Voidpouncer = Creature("Voidpouncer") do
      cost generic: 1, red: 1
      creature_type "Eldrazi"
      power 3
      toughness 1
      keywords :devoid
      kicker_cost generic: 2, colorless: 1
    end

    class Voidpouncer < Creature
      # "If this creature was kicked, it enters with two +1/+1 counters and a trample counter on it..."
      def entering_counters
        kicker_cost.paid? ? { "+1/+1" => 2, "trample" => 1 } : {}
      end

      # "...and with haste."
      class KickedHaste < Abilities::Static::KeywordGrant
        keyword_grants Keywords::HASTE

        applicable_targets { [source] }

        conditions { source.kicked? }
      end

      def static_abilities = [KickedHaste]
    end
  end
end
