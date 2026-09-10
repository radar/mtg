module Magic
  module Cards
    AllosaurusShepherd = Creature("Allosaurus Shepherd") do
      creature_type "Elf Shaman"
      cost green: 1
      power 1
      toughness 1
    end

    class AllosaurusShepherd < Creature
      def can_be_countered?
        false
      end

      class PreventGreenSpellCountering < StaticAbility
        def prevents_countering?(card)
          card.colors.include?(:green) && card.controller == controller
        end
      end

      class TransformElvesAbility < Magic::ActivatedAbility
        costs "{4}{G}{G}"

        def resolve!
          controller.creatures.by_any_type("Elf").each do |elf|
            elf.modify_base_power(5)
            elf.modify_base_toughness(5)
            elf.add_types("Dinosaur")
          end
        end
      end

      def static_abilities = [PreventGreenSpellCountering]
      def activated_abilities = [TransformElvesAbility]
    end
  end
end
