module Magic
  class Choice
    # Rule 701.62: look at the top two cards of your library, put one onto the battlefield face down as a 2/2 creature and
    # the other into your graveyard. With one card left it is manifested without a question, with none nothing happens.
    #
    #   Magic::Choice::ManifestDread.perform(actor: actor)              # the actor's controller manifests dread
    #   Magic::Choice::ManifestDread.perform(actor: actor, player: p2)  # "its controller manifests dread"
    #
    # Answer the choice with `game.resolve_choice!(target: card)`, the card to manifest.
    class ManifestDread < Choice
      def self.perform(actor:, player: actor.controller)
        choice = new(actor: actor, player: player)
        if choice.choices.size == 1
          choice.resolve!(target: choice.choices.first)
        elsif choice.choices.any?
          actor.game.add_choice(choice)
        end
      end

      attr_reader :player, :choices

      def initialize(actor:, player: actor.controller)
        super(actor: actor)
        @player = player
        @choices = player.library.first(2)
      end

      def chooser = player

      def prompt = "Put one of the top two cards of your library onto the battlefield face down. The other goes to your graveyard."

      def resolve!(target:)
        raise ArgumentError, "#{target.name} is not a valid choice" unless choices.include?(target)

        (choices - [target]).each(&:move_to_graveyard!)
        game.manifest!(target, controller: player)
      end
    end
  end
end
