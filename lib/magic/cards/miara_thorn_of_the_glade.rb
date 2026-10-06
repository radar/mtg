module Magic
  module Cards
    MiaraThornOfTheGlade = Creature("Miara, Thorn of the Glade") do
      cost generic: 1, black: 1
      legendary_creature_type "Elf Scout"
      power 1
      toughness 2
    end

    class MiaraThornOfTheGlade < Creature
      # "you may pay {1} and 1 life. If you do, draw a card." (Can't pay life you don't have.)
      class MayPayChoice < Magic::Choice::May
        # What a UI pays on the player's behalf: {1} (the life is paid as the choice resolves).
        def payment_cost(_x = nil) = { generic: 1 }

        def resolve!(payment: {})
          return unless controller.life >= 1

          controller.pay_mana(payment)
          trigger_effect(:lose_life, target: controller, life: 1)
          trigger_effect(:draw_card)
        end
      end

      # "Whenever Miara or another Elf you control dies, ..."
      class ElfDiedTrigger < TriggeredAbility
        def self.works_from_graveyard? = true

        def should_perform?
          event.controller == controller && event.permanent.type?("Elf")
        end

        def call
          game.choices.add(MayPayChoice.new(actor: actor))
        end
      end

      def event_handlers
        { Events::CreatureDied => ElfDiedTrigger }
      end
    end
  end
end
