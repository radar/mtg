module Magic
  module Cards
    class ChromeReplicator < Creature
      card_name "Chrome Replicator"
      artifact_creature_type "Construct"
      cost generic: 5
      power 4
      toughness 4

      Construct = Token.create "Construct" do
        type T::Artifact, T::Creature, T::Creatures['Construct']
        power 4
        toughness 4
      end

      enters_the_battlefield do
        # if you control two or more nonland, nontoken permanents with the same name as one another...
        names = game.battlefield.nonland.nontoken.map(&:name)
        duplicate_names = names.group_by(&:itself).values.any? { |group| group.length > 1 }
        if duplicate_names
          actor.trigger_effect(:create_token, token_class: Construct)
        end
      end
    end
  end
end
