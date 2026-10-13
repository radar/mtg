module Magic
  module Cards
    TwitchingDoll = Creature("Twitching Doll") do
      cost generic: 1, green: 1
      artifact_creature_type "Spider Toy"
      power 2
      toughness 2
    end

    class TwitchingDoll < Creature
      SpiderToken = Token.create("Spider") do
        creature_type "Spider"
        colors :green
        power 2
        toughness 2
        keywords :reach
      end

      # "{T}: Add one mana of any color. Put a nest counter on this creature."
      class ManaAbility < Magic::TapManaAbility
        choices :all

        def resolve!
          super
          source.add_counter("nest")
        end
      end

      # "{T}, Sacrifice this creature: Create a 2/2 green Spider creature token with reach for each counter on this
      # creature. Activate only as a sorcery."
      class SacrificeAbility < Magic::ActivatedAbility
        costs "{T}, Sacrifice {this}"

        activate_only_as_sorcery

        def resolve!
          amount = source.counters.of_type(Counters::Nest).count
          create_token(token:SpiderToken, amount:) if amount.positive?
        end
      end

      def activated_abilities = [ManaAbility, SacrificeAbility]
    end
  end
end
