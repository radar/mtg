module Magic
  module Cards
    SanctumOfCalmWaters = Enchantment("Sanctum of Calm Waters") do
      type T::Super::Legendary, T::Enchantment, "Shrine"
      cost generic: 3, blue: 1

      class FirstMainPhaseTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller
        end

        def call
          game.choices.add(SanctumOfCalmWaters::Choice.new(actor: actor))
        end
      end

      def event_handlers
        {
          Events::FirstMainPhase => FirstMainPhaseTrigger
        }
      end
    end

    class SanctumOfCalmWaters < Enchantment
      class Choice < Magic::Choice

        def resolve!
          shrines = controller.permanents.by_type("Shrine").count
          actor.trigger_effect(:draw_cards, number_to_draw: shrines)

          actor.add_choice(:discard)
        end
      end
    end
  end
end
