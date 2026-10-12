module Magic
  module Cards
    SalvationSwan = Creature("Salvation Swan") do
      cost generic: 3, white: 1
      creature_type("Bird Cleric")
      keywords :flash, :flying
      power 3
      toughness 3
    end

    class SalvationSwan < Creature
      # Whenever this creature or another Bird you control enters, exile up to one target creature you control
      # without flying. Return it to the battlefield under its owner's control with a flying counter on it at
      # the beginning of the next end step.
      class BirdEnters < TriggeredAbility::EnterTheBattlefield
        class ExileChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures.reject(&:flying?)

          def choice_amount = 0..1

          def resolve!(target:)
            card = target.card
            trigger_effect(:exile, target: target)
            game.subscribe(DelayedReturn.new(game: game, cards: [card], counters: { "flying" => 1 }))
          end
        end

        def should_perform? = under_your_control? && event.permanent.type?("Bird")

        def call
          choice = ExileChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = super.merge(Events::EnteredTheBattlefield => BirdEnters)
    end
  end
end
