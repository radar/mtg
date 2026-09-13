module Magic
  module Cards
    ElvishPromenade = Sorcery("Elvish Promenade") do
      type T::Kindred, T::Sorcery, T::Creatures["Elf"]
      cost "{3}{G}"
    end

    class ElvishPromenade < Sorcery
      ElfWarriorToken = Token.create "Elf Warrior" do
        creature_type "Elf Warrior"
        power 1
        toughness 1
        colors :green
      end

      def resolve!
        elves = controller.creatures.by_type("Elf")
        trigger_effect(:create_token, token_class: ElfWarriorToken, amount: elves.count)
      end
    end
  end
end
