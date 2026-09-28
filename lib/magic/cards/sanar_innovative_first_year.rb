module Magic
  module Cards
    SanarInnovativeFirstYear = Creature("Sanar, Innovative First-Year") do
      legendary_creature_type "Goblin Sorcerer"
      cost "{2}{U/R}{U/R}"
      power 2
      toughness 4
    end

    class SanarInnovativeFirstYear < Creature
      # "For each of those colors, you may exile a card of that color from among the revealed
      # cards. Then shuffle. You may cast the exiled cards this turn."
      class ExileChoice < Magic::Choice
        attr_reader :revealed, :colors

        def initialize(actor:, revealed:, colors:)
          super(actor: actor)
          @revealed = revealed
          @colors = colors
        end

        def choices = revealed

        # exiles: { color => card }, at most one card per color, each card having that color.
        def resolve!(exiles: {})
          exiles.each do |color, card|
            raise ArgumentError, "#{color} is not one of the colors" unless colors.include?(color)
            raise ArgumentError, "#{card.name} was not revealed" unless revealed.include?(card)
            raise ArgumentError, "#{card.name} is not #{color}" unless card.colors.include?(color)
          end
          cards = exiles.values
          raise ArgumentError, "a card can only be exiled once" unless cards.uniq.count == cards.count

          cards.each do |card|
            card.exile!
            game.play_permissions.grant_until_end_of_turn(card: card, player: controller)
          end
          controller.library.shuffle!
        end
      end

      # Vivid -- At the beginning of your first main phase, reveal cards from the top of your
      # library until you reveal X nonland cards, where X is the number of colors among
      # permanents you control.
      class FirstMainPhaseTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller
        end

        def call
          colors = controller.permanents.flat_map { |permanent| permanent.colors.to_a }.uniq
          revealed = []
          nonland_count = 0
          controller.library.each do |card|
            break if nonland_count >= colors.count

            revealed << card
            nonland_count += 1 unless card.land?
          end
          return if revealed.empty?

          trigger_effect(:reveal_cards, target: revealed)
          game.add_choice(ExileChoice.new(actor: actor, revealed: revealed, colors: colors))
        end
      end

      def event_handlers = { Events::FirstMainPhase => FirstMainPhaseTrigger }
    end
  end
end
