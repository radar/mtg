module Magic
  module Cards
    DawnwingMarshal = Creature("Dawnwing Marshal") do
      cost generic: 1, white: 1
      creature_type("Cat Soldier")
      keywords :flying
      power 2
      toughness 2
    end

    class DawnwingMarshal < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{4}{W}"

        def resolve!
          battlefield.controlled_by(controller).creatures.each { |creature| pump(creature, 1, 1) }
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
