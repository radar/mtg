module Magic
  module Cards
    KonaRescueBeastie = Creature("Kona, Rescue Beastie") do
      cost generic: 3, green: 1
      legendary_creature_type "Beast Survivor"
      power 4
      toughness 3
    end

    class KonaRescueBeastie < Creature
      # "You may put a permanent card from your hand onto the battlefield."
      class PutChoice < Magic::Choice
        def choices = controller.hand.select(&:permanent?)

        def upto = 1

        def may? = true

        def prompt = "Kona, Rescue Beastie: you may put a permanent card from your hand onto the battlefield."

        def decline!
        end

        def resolve!(targets: [])
          targets = Array(targets).uniq
          invalid = targets - choices
          raise ArgumentError, "#{invalid.map(&:name).join(', ')} can't be put onto the battlefield" if invalid.any?
          raise ArgumentError, "can put at most 1 card onto the battlefield" if targets.size > 1

          targets.each(&:resolve!)
        end
      end

      # "Survival — At the beginning of your second main phase, if Kona is tapped, ..."
      class SurvivalTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && actor.tapped?
        end

        def call
          choice = PutChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::SecondMainPhase => SurvivalTrigger }
    end
  end
end
