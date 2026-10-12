module Magic
  module Cards
    DwarvenProvisioner = Creature("Dwarven Provisioner") do
      cost generic: 1, white: 1
      creature_type("Dwarf Citizen")
      power 2
      toughness 2
    end

    class DwarvenProvisioner < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{3}{W}"

        def resolve!
          battlefield.controlled_by(controller).creatures.each { |creature| pump(creature, 1, 1) }
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
