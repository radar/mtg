module Magic
  module Cards
    Progenitus = Creature("Progenitus") do
      cost white: 2, blue: 2, black: 2, red: 2, green: 2
      legendary_creature_type("Hydra Avatar")
      protections [Protection.new(condition: -> (_) { true })]
      power 10
      toughness 10
    end

    class Progenitus < Creature
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
