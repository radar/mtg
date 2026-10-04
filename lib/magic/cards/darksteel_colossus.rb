module Magic
  module Cards
    DarksteelColossus = Creature("Darksteel Colossus") do
      cost generic: 11
      artifact_creature_type("Golem")
      keywords :trample, :indestructible
      power 11
      toughness 11
    end

    class DarksteelColossus < Creature
      class ShuffleIntoLibraryInstead < ReplacementEffect
        def applies?(effect)
          effect.target == receiver && effect.to.graveyard?
        end

        def call(effect) = Effects::ShuffleIntoLibrary.new(source: receiver, target: effect.target)
      end

      def replacement_effects = { Effects::MovePermanentZone => ShuffleIntoLibraryInstead }

      def zone_replacement_effects = { Effects::MoveCardZone => ShuffleIntoLibraryInstead }
    end
  end
end
