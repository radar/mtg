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
        def chooser = player

        def choices = player.library.select(&:basic_land?)

        # "Up to three basic land cards."
        def upto = 3

        def may? = true

        def prompt
          "Rootweaver Druid: search your library for up to three basic land cards. " \
            "One goes onto the battlefield tapped under #{actor.controller.name}'s control, the rest under yours."
        end

        def decline!
        end

        # targets: up to three basic lands. for_you: the one that goes to the Druid's controller. Left out, a single
        # land goes to the Druid's controller and, with several, the searching player is asked which one does
        # (GiveChoice).
        def resolve!(targets: [], for_you: nil)
          targets = Array(targets).uniq
          raise ArgumentError, "can search for at most 3 cards, got #{targets.size}" if targets.size > 3

          invalid = targets - choices
          raise ArgumentError, "#{invalid.map(&:name).join(', ')} can't be chosen" if invalid.any?

          raise ArgumentError, "#{for_you.name} wasn't chosen" if for_you && !targets.include?(for_you)

          for_you ||= targets.first if targets.size <= 1
          if for_you || targets.empty?
            RootweaverDruid.put_onto_battlefield(actor: actor, player: player, cards: targets, for_you: for_you)
          else
            game.add_choice(GiveChoice.new(actor: actor, player: player, cards: targets))
          end
        end
      end

      # Then the searching player picks which of the lands they found goes under the Druid's controller's control.
      class GiveChoice < Magic::Choice::Targeted
        attr_reader :player, :cards

        def initialize(actor:, player:, cards:)
          super(actor: actor)
          @player = player
          @cards = cards
        end

        def chooser = player

        # Picking among their own cards, not targeting.
        def targets? = false

        def choices = cards

        def choice_amount = 1

        def prompt
          "Rootweaver Druid: choose which land goes onto the battlefield under #{actor.controller.name}'s control. " \
            "The others go onto the battlefield under yours."
        end

        def resolve!(target:)
          raise ArgumentError, "#{target.name} wasn't found" unless cards.include?(target)

          RootweaverDruid.put_onto_battlefield(actor: actor, player: player, cards: cards, for_you: target)
        end
      end

      # The land for_you enters tapped under the Druid's controller, the rest tapped under the searching player's; then
      # that player shuffles.
      def self.put_onto_battlefield(actor:, player:, cards:, for_you:)
        cards.each do |card|
          card.resolve!(enters_tapped: true, controller: card.equal?(for_you) ? actor.controller : player)
        end
        player.shuffle!
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
