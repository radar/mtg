module Magic
  module Cards
    OrphansOfTheWheat = Creature("Orphans of the Wheat") do
      cost generic: 1, white: 1
      creature_type "Human"
      power 2
      toughness 1
    end

    class OrphansOfTheWheat < Creature
      # Picks any number of untapped creatures (`resolve!(targets: [...])`, `[]` for none); each one tapped this way
      # gives the source +1/+1 until end of turn.
      class TapChoice < Magic::Choice
        def choices = controller.creatures.untapped

        def resolve!(targets: [])
          targets = Array(targets).uniq
          invalid = targets - choices
          raise ArgumentError, "#{invalid.map(&:name).join(', ')} can't be tapped" if invalid.any?

          targets.each(&:tap!)
          trigger_effect(:modify_power_toughness, target: actor, power: targets.size, toughness: targets.size) if targets.any?
        end
      end

      # "Whenever this creature attacks, tap any number of untapped creatures you control. This creature gets +1/+1
      # until end of turn for each creature tapped this way."
      class AttacksTrigger < TriggeredAbility
        def should_perform? = event.attacker == actor

        def call
          choice = TapChoice.new(actor:)
          game.choices.add(choice) if choice.choices.any?
        end
      end

      def event_handlers = super.merge({ Events::CreatureAttacked => AttacksTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
