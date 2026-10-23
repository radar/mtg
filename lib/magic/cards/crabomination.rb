module Magic
  module Cards
    Crabomination = Creature("Crabomination") do
      cost generic: 4, black: 2
      creature_type "Crab Demon"
      power 5
      toughness 5
    end

    class Crabomination < Creature
      # Emerge from artifact {5}{B}{B}
      def alternative_cost = Costs::Mana.new(generic: 5, black: 2)

      def emerge_from = "Artifact"

      # When this creature enters, target opponent exiles the top card of their library, a card at random from their
      # graveyard, and a card at random from their hand. You may cast a spell from among cards exiled this way
      # without paying its mana cost.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class CastChoice < Magic::Choice::Targeted
          def initialize(actor:, exiled:)
            @exiled = exiled
            super(actor: actor)
          end

          def prompt = "You may cast a spell from among the exiled cards without paying its mana cost."

          def choices = @exiled.reject(&:land?)

          def choice_amount = 0..1

          def resolve!(target:)
            Magic::Choice::FreeCast.start(actor: actor, card: target, exile_after: false)
          end
        end

        def call
          opponent = game.opponents(controller).first
          exiled = [
            opponent.library.cards.first,
            opponent.graveyard.cards.to_a.sample,
            opponent.hand.cards.to_a.sample
          ].compact
          exiled.each(&:exile!)

          choice = CastChoice.new(actor: actor, exiled: exiled)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
