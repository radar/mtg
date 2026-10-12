module Magic
  module Cards
    TenderWildguide = Creature("Tender Wildguide") do
      cost generic: 1, green: 1
      creature_type("Possum Druid")
      power 2
      toughness 2
      offspring generic: 2
    end

    class TenderWildguide < Creature
      # {T}: Add one mana of any color.
      class ManaAbility < Magic::TapManaAbility
        choices :all
      end

      # {T}: Put a +1/+1 counter on this creature.
      class GrowAbility < Magic::ActivatedAbility
        costs "{T}"

        def resolve!
          add_counter("+1/+1", to: source)
        end
      end

      def activated_abilities = [ManaAbility, GrowAbility]
    end
  end
end
