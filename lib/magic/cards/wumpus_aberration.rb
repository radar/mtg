module Magic
  module Cards
    WumpusAberration = Creature("Wumpus Aberration") do
      cost generic: 3, green: 1
      creature_type "Eldrazi Beast"
      power 6
      toughness 6
      keywords :devoid, :trample
    end

    class WumpusAberration < Creature
      # "...target opponent may put a creature card from their hand onto the battlefield."
      class PutChoice < Magic::Choice
        attr_reader :player

        def initialize(actor:, player:)
          super(actor: actor)
          @player = player
        end

        # The opponent decides, not Wumpus Aberration's controller.
        def chooser = player

        def choices = player.hand.select(&:creature?)

        def upto = 1

        def may? = true

        def prompt = "You may put a creature card from your hand onto the battlefield."

        def decline!
        end

        def resolve!(targets: [])
          targets = Array(targets).uniq
          invalid = targets - choices
          raise ArgumentError, "#{invalid.map(&:name).join(', ')} can't be put onto the battlefield" if invalid.any?
          raise ArgumentError, "can put at most 1 card onto the battlefield" if targets.size > 1

          targets.each do |card|
            Permanent.put_onto_battlefield(game: game, card: card, from_zone: card.zone, controller: player)
          end
        end
      end

      # "When you cast this spell, if {C} wasn't spent to cast it, ..."
      class CastTrigger < TriggeredAbility::CastThisSpell
        def should_perform? = spent(:colorless).zero?

        def call
          opponent = opponents.first
          choice = PutChoice.new(actor: actor, player: opponent)
          game.choices.add(choice) if choice.choices.any?
        end
      end

      def cast_triggers = [CastTrigger]
    end
  end
end
