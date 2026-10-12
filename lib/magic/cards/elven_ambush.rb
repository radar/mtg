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
        # "for each Elf you control": any permanent with the Elf subtype counts, such as a Kindred enchantment.
        elves = controller.permanents.count { _1.type?("Elf") }
        trigger_effect(:create_token, token_class: ElfWarriorToken, amount: elves)
      end
    end
  end
end
