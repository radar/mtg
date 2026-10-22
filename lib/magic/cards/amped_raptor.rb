module Magic
  module Cards
    AmpedRaptor = Creature("Amped Raptor") do
      cost generic: 1, red: 1
      creature_type "Dinosaur"
      power 2
      toughness 1
      keywords :first_strike
    end

    class AmpedRaptor < Creature
      # The controller picks the target of the cast.
      class TargetChoice < Magic::Choice::Targeted
        def initialize(actor:, action:)
          super(actor: actor)
          @action = action
        end

        def prompt = "Choose a target for #{@action.card.name}."

        def choices = @action.target_choices.to_a

        def choice_amount = 1

        # The energy is already paid, so skipping takes the first target.
        def decline!
          resolve!(target: choices.first)
        end

        def resolve!(target:)
          @action.targeting(target)
          game.take_action(@action)
        end
      end

      # You may cast that card by paying an amount of {E} equal to its mana value rather than paying its mana cost.
      class PayChoice < Magic::Choice::PayEnergy
        attr_reader :card

        def initialize(actor:, card:)
          @card = card
          super(actor: actor, amount: card.mana_value)
        end

        def resolve!
          super
          action = controller.prepare_cast(card: card, by_effect: true)
          action.mana_cost = {}
          if AmpedRaptor.single_target?(card)
            game.add_choice(TargetChoice.new(actor: actor, action: action))
          else
            game.take_action(action)
          end
        end
      end

      # A spell with one target needs a legal one to be cast at all.
      def self.single_target?(card)
        card.respond_to?(:target_choices) && !(card.respond_to?(:multi_target?) && card.multi_target?)
      end

      # When this creature enters, you get {E}{E}. Then if you cast it from your hand, exile cards from the top of
      # your library until you exile a nonland card. You may cast that card by paying {E} equal to its mana value.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          gain_energy 2
          return unless actor.cast? && actor.entered_from_zone&.hand?

          exiled = nil
          while (card = controller.library.first)
            exile_target(card)
            unless card.land?
              exiled = card
              break
            end
          end
          return unless exiled

          choice = PayChoice.new(actor: actor, card: exiled)
          game.add_choice(choice) if choice.can_pay? && castable_target?(exiled)
        end

        def castable_target?(card)
          return true unless AmpedRaptor.single_target?(card)

          controller.prepare_cast(card: card, by_effect: true).target_choices.to_a.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
