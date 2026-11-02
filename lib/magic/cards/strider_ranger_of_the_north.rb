module Magic
  module Cards
    StriderRangerOfTheNorth = Creature("Strider, Ranger of the North") do
      cost "{2}{R}{G}"
      legendary_creature_type("Human Ranger")
      power 4
      toughness 4
    end

    class StriderRangerOfTheNorth < Creature
      # "Target creature gets +1/+1 until end of turn. Then if that creature has power 4 or greater, it gains first
      # strike until end of turn." The power is checked as the ability resolves, after the +1/+1.
      class PumpChoice < Magic::Choice::Targeted
        def choices = battlefield.creatures

        def choice_amount = 1

        def resolve!(target:)
          pump target, 1, 1
          target.apply_continuous_effects!
          give_keyword target, :first_strike if target.power >= 4
        end

        # The target is mandatory: declining picks a legal creature.
        def decline! = resolve!(target: choices.first)
      end

      # "Landfall -- Whenever a land you control enters, ..."
      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform? = you?

        def call
          choice = PumpChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers
        super.merge(Events::Landfall => LandfallTrigger)
      end
    end
  end
end
