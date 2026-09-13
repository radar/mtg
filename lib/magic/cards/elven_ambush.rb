module Magic
  module Cards
    ElvenAmbush = Instant("Elven Ambush") do
      cost "{3}{G}"
    end

    class ElvenAmbush < Instant
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
