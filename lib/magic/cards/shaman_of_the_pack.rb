module Magic
  module Cards
    ShamanOfThePack = Creature("Shaman of the Pack") do
      cost generic: 1, black: 1, green: 1
      creature_type "Elf Shaman"
      power 3
      toughness 2
    end

    class ShamanOfThePack < Creature
      class LifeLossChoice < Magic::Choice::Targeted
        def choices
          game.opponents(controller)
        end

        def choice_amount
          1
        end

        def resolve!(target:)
          elf_count = controller.creatures.by_any_type("Elf").count
          target.trigger_effect(:lose_life, source: actor, life: elf_count)
        end
      end

      class EnteredTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(ShamanOfThePack::LifeLossChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EnteredTrigger]
    end
  end
end
