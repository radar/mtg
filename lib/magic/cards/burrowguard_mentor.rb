module Magic
  module Cards
    BurrowguardMentor = Creature("Burrowguard Mentor") do
      cost green: 1, white: 1
      creature_type("Rabbit Soldier")
      keywords :trample
      power 0
      toughness 0
    end

    class BurrowguardMentor < Creature
      # Burrowguard Mentor's power and toughness are each equal to the number of creatures you control.
      class CreatureCount < Abilities::Static::CharacteristicSetting
        def applicable_targets = [source]

        def set_base_power = controller.creatures.count

        def set_base_toughness = controller.creatures.count
      end

      def static_abilities = [CreatureCount]
    end
  end
end
