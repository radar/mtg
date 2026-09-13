module Magic
  module Cards
    DwynensElite = Creature("Dwynen's Elite") do
      cost generic: 1, green: 1
      creature_type "Elf Warrior"
      power 2
      toughness 2
    end

    class DwynensElite < Creature
      ElfWarriorToken = Token.create("Elf Warrior") do
        creature_type "Elf Warrior"
        power 1
        toughness 1
        colors :green
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          return unless controller.creatures.except(actor).by_type("Elf").any?

          actor.trigger_effect(:create_token, token_class: ElfWarriorToken)
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
