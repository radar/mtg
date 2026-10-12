module Magic
  module Cards
    RipSpawnHunter = Creature("Rip, Spawn Hunter") do
      cost generic: 2, green: 1, white: 1
      legendary_creature_type "Human Survivor"
      power 4
      toughness 4
    end

    class RipSpawnHunter < Creature
      # "Reveal the top X cards of your library, where X is its power. Put any number of creature and/or Vehicle cards
      # with different powers from among them into your hand. Put the rest on the bottom of your library in a random
      # order."
      class HandChoice < Magic::Choice
        attr_reader :cards, :choices

        def prompt = "Rip, Spawn Hunter: choose creature and/or Vehicle cards with different powers to put into your hand."

        def initialize(actor:, cards:)
          @cards = cards
          @choices = cards.select { _1.creature? || _1.type?("Vehicle") }
          super(actor: actor)
        end

        def may? = true

        def upto = choices.size

        def decline!
          resolve!(targets: [])
        end

        def resolve!(targets: [])
          targets = Array(targets).uniq
          invalid = targets - choices
          raise ArgumentError, "#{invalid.map(&:name).join(', ')} can't be chosen" if invalid.any?
          raise ArgumentError, "chosen cards must have different powers" if targets.map(&:base_power).uniq.size < targets.size

          cards.each { controller.library.remove(_1) }
          targets.each(&:move_to_hand!)
          (cards - targets).shuffle.each { |card| controller.library.add(card, controller.library.count) }
        end
      end

      # "Survival — At the beginning of your second main phase, if Rip is tapped, ..."
      class SurvivalTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && actor.tapped?
        end

        def call
          cards = controller.library.take(actor.power)
          controller.reveal(*cards)
          game.add_choice(HandChoice.new(actor: actor, cards: cards)) if cards.any?
        end
      end

      def event_handlers = { Events::SecondMainPhase => SurvivalTrigger }
    end
  end
end
