module Magic
  module Cards
    EnvoyOfTheAncestors = Creature("Envoy of the Ancestors") do
      cost generic: 2, white: 1
      creature_type "Human Cleric"
      power 2
      toughness 3
    end

    class EnvoyOfTheAncestors < Creature
      # "Outlast {W}": {W}, {T}: Put a +1/+1 counter on this creature. Activate only as a sorcery.
      class OutlastAbility < Magic::ActivatedAbility
        costs "{W}, {T}"
        activate_only_as_sorcery

        def resolve!
          add_counter("+1/+1", to: source)
        end
      end

      # "Modified creatures you control have lifelink."
      class LifelinkGrant < Abilities::Static::KeywordGrant
        keyword_grants Keywords::LIFELINK

        def applicable_targets
          your.creatures.select(&:modified?)
        end
      end

      def activated_abilities = [OutlastAbility]
      def static_abilities = [LifelinkGrant]
    end
  end
end
