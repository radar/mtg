module Magic
  module Cards
    AlpineHoundmaster = Creature("Alpine Houndmaster") do
      creature_type("Human Warrior")
      cost generic: 1, red: 1, white: 1
      power 2
      toughness 3

      enters_the_battlefield do
        game.choices.add(AlpineHoundmaster::MaySearchChoice.new(actor: actor))
      end
    end

    class AlpineHoundmaster < Creature
      class SearchChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :hand, reveal: true, upto: 2, filter: [])
        end

        def choices
          Magic::CardList.new(
            controller.library.by_name("Alpine Watchdog") +
            controller.library.by_name("Igneous Cur")
          )
        end
      end

      class MaySearchChoice < Magic::Choice::May
        def resolve!
          game.add_choice(AlpineHoundmaster::SearchChoice.new(actor: actor))
        end
      end

      class AttackTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { |attack| attack.attacker == actor }
        end

        def call
          other_attackers = event.attacks.reject { |attack| attack.attacker == actor }.count
          actor.trigger_effect(:modify_power_toughness, power: other_attackers, target: actor, until_eot: true)
        end
      end

      def event_handlers
        {
          Events::FinalAttackersDeclared => AttackTrigger
        }
      end
    end
  end
end
