module Magic
  module Cards
    CarrotCake = Card("Carrot Cake") do
      type T::Artifact, "Food"
      cost generic: 1, white: 1
    end

    class CarrotCake < Card
      # When this artifact enters and when you sacrifice it, create a 1/1 white Rabbit creature token and scry 1.
      class RabbitTrigger < TriggeredAbility
        def call
          trigger_effect(:create_token, token_class: Tokens::Rabbit)
          game.choices.add(Magic::Choice::Scry.new(actor: actor, amount: 1))
        end
      end

      class SacrificedTrigger < RabbitTrigger
        def should_perform? = event.permanent == actor
      end

      def etb_triggers = [RabbitTrigger]

      def event_handlers = super.merge(Events::PermanentSacrificed => SacrificedTrigger)

      # {2}, {T}, Sacrifice this artifact: You gain 3 life.
      def activated_abilities = [Tokens::Food::GainLife]
    end
  end
end
