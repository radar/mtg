module Magic
  module Cards
    TemperamentalOozewagg = Creature("Temperamental Oozewagg") do
      cost generic: 3, green: 1
      creature_type "Ooze Brushwagg"
      power 4
      toughness 4
    end

    class TemperamentalOozewagg < Creature
      # "{2}{G}: Adapt 2." (If it has no +1/+1 counters on it, put two +1/+1 counters on it.)
      class AdaptAbility < Magic::ActivatedAbility
        costs "{2}{G}"

        def resolve!
          return if source.counters.of_type(Counters::Plus1Plus1).any?

          add_counter("+1/+1", to: source, amount: 2)
        end
      end

      # "Modified creatures you control have trample."
      class TrampleGrant < Abilities::Static::KeywordGrant
        keyword_grants Keywords::TRAMPLE

        def applicable_targets
          your.creatures.select(&:modified?)
        end
      end

      def activated_abilities = [AdaptAbility]
      def static_abilities = [TrampleGrant]
    end
  end
end
