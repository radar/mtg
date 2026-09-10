module Magic
  module Cards
    ImperiousPerfect = Creature("Imperious Perfect") do
      creature_type "Elf Warrior"
      cost generic: 2, green: 1
      power 2
      toughness 2
    end

    class ImperiousPerfect < Creature
      ElfWarriorToken = Token.create "Elf Warrior" do
        creature_type "Elf Warrior"
        power 1
        toughness 1
        colors :green
      end

      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        other_creatures "Elf"
      end

      class CreateTokenAbility < Magic::ActivatedAbility
        costs "{G}, {T}"

        def resolve!
          trigger_effect(:create_token, token_class: ElfWarriorToken)
        end
      end

      def static_abilities = [PowerAndToughnessModification]
      def activated_abilities = [CreateTokenAbility]
    end
  end
end
