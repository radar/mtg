module Magic
  module Cards
    EnigmaDrake = Creature("Enigma Drake") do
      cost generic: 1, blue: 1, red: 1
      creature_type("Drake")
      keywords :flying
      power 0
      toughness 4
    end

    class EnigmaDrake < Creature
      class CharacteristicPower < Abilities::Static::PowerAndToughnessModification
        def applicable_targets = [source]

        def power_modification = controller.graveyard.cards.by_any_type("Instant", "Sorcery").count

        def toughness_modification = 0
      end

      def static_abilities = [CharacteristicPower]
    end
  end
end
