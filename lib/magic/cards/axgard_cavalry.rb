module Magic
  module Cards
    AxgardCavalry = Creature("Axgard Cavalry") do
      cost generic: 1, red: 1
      creature_type("Dwarf Berserker")
      power 2
      toughness 2
    end

    class AxgardCavalry < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{T}"

        def target_choices
          battlefield.creatures
        end

        def resolve!(target:)
          give_keyword(target, :haste)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
