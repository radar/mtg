module Magic
  module Cards
    OsseousSticktwister = Creature("Osseous Sticktwister") do
      cost black: 1, generic: 1
      artifact_creature_type "Scarecrow"
      power 2
      toughness 2
      keywords :lifelink
    end

    class OsseousSticktwister < Creature
      # The opponent may sacrifice a nonland permanent or discard a card (`resolve!(permanent:)` / `resolve!(card:)`).
      # Declining both (or having neither to give) means this creature deals damage equal to its power to them.
      class SacrificeOrDiscardChoice < Magic::Choice::May
        attr_reader :player

        def chooser = player

        def initialize(actor:, player:)
          @player = player
          super(actor: actor)
        end

        def prompt = "Sacrifice a nonland permanent or discard a card, or take damage equal to #{actor.name}'s power."

        def permanents = battlefield.controlled_by(player).reject(&:land?)

        def cards = player.hand.cards.to_a

        def choices = permanents + cards

        def resolve!(permanent: nil, card: nil)
          if permanent && permanents.include?(permanent)
            permanent.sacrifice!
          elsif card && cards.include?(card)
            card.discard!
          else
            raise ArgumentError, "choose a nonland permanent you control or a card in your hand"
          end
        end

        def decline!
          deal_damage(actor.power, to: player)
        end
      end

      # "Delirium -- At the beginning of your end step, if there are four or more card types among cards in your
      # graveyard, each opponent may sacrifice a nonland permanent of their choice or discard a card. Then this
      # creature deals damage equal to its power to each opponent who didn't sacrifice a permanent or discard a card
      # this way."
      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          controllers_end_step? && controller.graveyard.delirium?
        end

        def call
          game.opponents(controller).each do |opponent|
            choice = SacrificeOrDiscardChoice.new(actor: actor, player: opponent)
            if choice.choices.any?
              game.choices.add(choice)
            else
              choice.decline!
            end
          end
        end
      end

      def event_handlers = super.merge({ Events::BeginningOfEndStep => EndStepTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
