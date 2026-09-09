module Magic
  module Cards
    EumidianHatchery = Card("Eumidian Hatchery") do
      type "Land"
    end

    class EumidianHatchery < Card
      InsectToken = Token.create("Insect") do
        creature_type "Insect"
        power 1
        toughness 1
        colors :black
        keywords :flying
      end

      class ManaAbility < Magic::TapManaAbility
        choices :black

        def resolve!
          controller.lose_life(1)
          source.add_counter("hatchling")
          super
        end
      end

      class LeavesTrigger < TriggeredAbility
        def should_perform?
          event.permanent == actor && event.to.graveyard?
        end

        def call
          amount = actor.counters.of_type(Counters::Hatchling).count
          actor.create_token(token_class: InsectToken, amount: amount) if amount.positive?
        end
      end

      def activated_abilities = [ManaAbility]

      def event_handlers
        { Events::PermanentLeavingZone => LeavesTrigger }
      end
    end
  end
end
