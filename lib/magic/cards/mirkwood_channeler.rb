module Magic
  module Cards
    MirkwoodChanneler = Creature("Mirkwood Channeler") do
      cost generic: 3, green: 1
      creature_type "Elf Druid"
      power 3
      toughness 3
    end

    class MirkwoodChanneler < Creature
      # "...target Elf you control gains trample and gets +X/+X until end of turn, where X is the number of Forests you
      # control." X is counted on resolution. The target is mandatory (the Channeler is itself an Elf).
      class ElfChoice < Magic::Choice::Targeted
        def choices = controller.creatures.select { _1.type?("Elf") }

        def choice_amount = 1

        def resolve!(target:)
          forests = controller.permanents.count { _1.land? && _1.type?("Forest") }
          give_keyword(target, :trample)
          pump(target, forests, forests)
        end

        def decline!
          target = choices.first
          resolve!(target: target) if target
        end
      end

      # "At the beginning of combat on your turn, ..."
      class BeginningOfCombatTrigger < TriggeredAbility
        def should_perform? = event.active_player == controller

        def call
          choice = ElfChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::BeginningOfCombat => BeginningOfCombatTrigger }
    end
  end
end
