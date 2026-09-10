module Magic
  module Cards
    ProwessOfTheFair = Enchantment("Prowess of the Fair") do
      type T::Kindred, T::Enchantment, T::Creatures["Elf"]
      cost generic: 1, black: 1
    end

    class ProwessOfTheFair < Enchantment
      ElfWarriorToken = Token.create "Elf Warrior" do
        creature_type "Elf Warrior"
        power 1
        toughness 1
        colors :green
      end

      class CreateTokenChoice < Magic::Choice::May
        def resolve!
          actor.trigger_effect(:create_token, token_class: ElfWarriorToken)
        end
      end

      # Whenever another nontoken Elf is put into your graveyard from the battlefield,
      # you may create a 1/1 green Elf Warrior creature token.
      class ElfPutIntoGraveyardTrigger < TriggeredAbility
        def should_perform?
          event.to.graveyard? &&
            event.permanent != actor &&
            !event.permanent.token? &&
            event.permanent.type?("Elf") &&
            event.permanent.controller == controller
        end

        def call
          game.choices.add(CreateTokenChoice.new(actor: actor))
        end
      end

      def event_handlers
        {
          Events::LeftTheBattlefield => ElfPutIntoGraveyardTrigger
        }
      end
    end
  end
end
