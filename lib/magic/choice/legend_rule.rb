module Magic
  class Choice
    # Rule 704.5j: a player controlling two or more legendary permanents with the same
    # name chooses one of them to keep and puts the rest into their owners' graveyards.
    class LegendRule < Targeted
      attr_reader :permanents

      def initialize(player:, permanents:)
        @player = player
        @permanents = permanents
        super(actor: player)
      end

      def controller = @player
      def choices = permanents
      def choice_amount = 1

      def resolve!(target:)
        (permanents - [target]).each(&:put_into_graveyard!)
      end
    end
  end
end
