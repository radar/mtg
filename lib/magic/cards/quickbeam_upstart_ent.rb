module Magic
  module Cards
    QuickbeamUpstartEnt = Creature("Quickbeam, Upstart Ent") do
      cost generic: 4, green: 2
      legendary_creature_type "Treefolk"
      power 5
      toughness 6
    end

    class QuickbeamUpstartEnt < Creature
      # "...up to two target creatures each get +2/+2 and gain trample until end of turn."
      class TargetChoice < Magic::Choice::Targeted
        def choices = battlefield.creatures

        def choice_amount = 0..2

        def decline!
        end

        def resolve!(targets:)
          targets = Array(targets).uniq
          raise ArgumentError, "can target at most 2 creatures" if targets.size > 2
          raise ArgumentError, "#{targets.map(&:name).join(', ')} can't be targeted" if (targets - choices).any?

          targets.each do |target|
            pump(target, 2, 2)
            give_keyword(target, :trample)
          end
        end
      end

      # "Whenever Quickbeam or another Treefolk you control enters, ..." Quickbeam is a Treefolk, so his own entry
      # matches.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent.type?("Treefolk") && under_your_control?
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => EntersTrigger }
    end
  end
end
