module Magic
  module Cards
    RootweaverDruid = Creature("Rootweaver Druid") do
      cost generic: 2, green: 1
      creature_type "Elf Druid"
      power 2
      toughness 1
    end

    class RootweaverDruid < Creature
      # "When this creature enters, each opponent may search their library for up to three basic land
      # cards. They each put one of those cards onto the battlefield tapped under your control and the
      # rest onto the battlefield tapped under their control. Then each player who searched their
      # library this way shuffles."
      class SearchChoice < Magic::Choice
        attr_reader :player

        def initialize(actor:, player:)
          super(actor: actor)
          @player = player
        end

        # The searching opponent makes the decision, not the Druid's controller.
        def controller = player

        def choices = player.library.select(&:basic_land?)

        # "Up to three basic land cards."
        def upto = 3

        def may? = true

        def decline!
        end

        # targets: up to three basic lands. for_you: the one that goes to the Druid's controller
        # (defaults to the first chosen).
        def resolve!(targets: [], for_you: nil)
          targets = Array(targets).uniq
          raise ArgumentError, "can search for at most 3 cards, got #{targets.size}" if targets.size > 3

          invalid = targets - choices
          raise ArgumentError, "#{invalid.map(&:name).join(', ')} can't be chosen" if invalid.any?

          for_you ||= targets.first
          raise ArgumentError, "#{for_you.name} wasn't chosen" if for_you && !targets.include?(for_you)

          targets.each do |card|
            card.resolve!(enters_tapped: true, controller: card.equal?(for_you) ? actor.controller : player)
          end
          player.shuffle!
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          opponents.each { |opponent| game.add_choice(SearchChoice.new(actor: actor, player: opponent)) }
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
