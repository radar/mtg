module Magic
  module Cards
    TimidShieldbearer = Creature("Timid Shieldbearer") do
      cost generic: 1, white: 1
      creature_type("Kithkin Soldier")
      power 2
      toughness 2
    end

    class TimidShieldbearer < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{4}{W}"

        def resolve!
          battlefield.controlled_by(controller).creatures.each { |creature| trigger_effect(:modify_power_toughness, target: creature, power: 1, toughness: 1) }
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
