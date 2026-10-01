module Magic
  class Choice
    # "<creature> endures N": put N +1/+1 counters on the creature, or create an N/N white
    # Spirit creature token. Accepting (`game.resolve_choice!`) puts the counters; declining
    # (`game.skip_choice!`) makes the token. A creature that has left the battlefield can't get
    # counters, so either answer makes the token. The token's controller is the actor's controller.
    class Endure < Magic::Choice::May
      SpiritToken = Magic::Token.create "Spirit" do
        creature_type "Spirit"
        power 1
        toughness 1
        colors :white
      end

      attr_reader :amount, :creature

      def initialize(actor:, amount:, creature: actor)
        @amount = amount
        @creature = creature
        super(actor: actor)
      end

      def resolve!
        return create_spirit unless creature_on_battlefield?

        trigger_effect(:add_counter, counter_type: "+1/+1", target: creature, amount: amount)
      end

      def decline! = create_spirit

      private

      def creature_on_battlefield? = creature.zone&.battlefield? || false

      def create_spirit
        return unless amount.positive?

        trigger_effect(:create_token, token_class: SpiritToken, base_power: amount, base_toughness: amount, controller: controller)
      end
    end
  end
end
