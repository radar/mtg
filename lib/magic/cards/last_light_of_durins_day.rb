module Magic
  module Cards
    LastLightOfDurinsDay = Enchantment("Last Light of Durin's Day") do
      cost generic: 1, red: 1
    end

    class LastLightOfDurinsDay < Enchantment
      # "Mountaincycling {2}"
      landcycling({ generic: 2 }, filter: "Mountain")

      # "...search your hand and/or library for a Dragon card and put it onto the battlefield."
      class DragonChoice < Magic::Choice::Targeted
        def targets? = false

        def choices = controller.hand.select { |card| card.any_type?("Dragon") } +
          controller.library.select { |card| card.any_type?("Dragon") }

        def choice_amount = 0..1

        def resolve!(target: nil)
          target&.resolve!
          controller.shuffle!
        end
      end

      # "Whenever a Mountain you control enters, put a quest counter on this enchantment. If it has six or more quest
      # counters on it, sacrifice it. If you do, search your hand and/or library for a Dragon card and put it onto the
      # battlefield. If you search your library this way, shuffle."
      class MountainTrigger < TriggeredAbility
        def should_perform? = you? && event.permanent.land? && event.permanent.any_type?("Mountain")

        def call
          trigger_effect(:add_counter, counter_type: "quest", target: actor, amount: 1)
          return unless actor.counters.of_type(Counters["quest"]).count >= 6

          trigger_effect(:sacrifice, target: actor)
          game.add_choice(DragonChoice.new(actor: actor))
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => MountainTrigger }
    end
  end
end
