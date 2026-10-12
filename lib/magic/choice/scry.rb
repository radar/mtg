module Magic
  class Choice
    class Scry < Choice
      attr_reader :player, :amount

      def initialize(actor:, amount: 1)
        @actor = actor
        @amount = amount
        super(actor: actor)
      end

      def prompt = "Scry #{amount}: put any number of the top #{amount == 1 ? 'card' : "#{amount} cards"} of your library on the bottom and the rest on top in any order."

      def choices
        chooser.library.first(amount)
      end

      def resolve!(top: [], bottom: [])
        chooser.scry(amount:, top:, bottom:)
      end
    end
  end
end
