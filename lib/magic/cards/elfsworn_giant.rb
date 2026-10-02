module Magic
  module Cards
    ElfswornGiant = Creature("Elfsworn Giant") do
      cost generic: 3, green: 2
      creature_type("Giant")
      keywords :reach
      power 5
      toughness 3
    end

    class ElfswornGiant < Creature
      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform?
          you?
        end

        ElfWarriorToken = Token.create "Elf Warrior" do
          creature_type "Elf Warrior"
          power 1
          toughness 1
          colors :green
        end

        def call
          trigger_effect(:create_token, token_class: ElfWarriorToken)
        end
      end

      def event_handlers = { Events::Landfall => LandfallTrigger }
    end
  end
end
