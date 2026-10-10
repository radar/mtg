module Magic
  module Cards
    RuthlessWinnower = Creature("Ruthless Winnower") do
      creature_type "Elf Rogue"
      cost "{3}{B}{B}"
      power 4
      toughness 4
    end

    class RuthlessWinnower < Creature
      class SacrificeChoice < Magic::Choice::Targeted
        attr_reader :player

        # The player sacrificing makes the choice, not Ruthless Winnower's controller.
        def chooser = player

        def prompt = "Sacrifice a non-Elf creature."

        def initialize(actor:, player:)
          @player = player
          super(actor: actor)
        end

        def choices
          @player.creatures.excluding_type("Elf")
        end

        def choice_amount
          1
        end

        # The opponent picks which of their own creatures to sacrifice; nothing is targeted.
        def targets? = false

        def resolve!(target:)
          target.sacrifice!
        end
      end

      class UpkeepTrigger < TriggeredAbility
        def call
          choice = SacrificeChoice.new(actor: actor, player: event.player)
          game.choices.add(choice) if choice.choices.any?
        end
      end

      def event_handlers
        {
          Events::BeginningOfUpkeep => UpkeepTrigger
        }
      end
    end
  end
end
