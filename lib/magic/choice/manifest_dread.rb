module Magic
  class Choice
    # Rule 701.62: look at the top two cards of your library, put one onto the battlefield face down as a 2/2 creature and
    # the other into your graveyard. With one card left it is manifested without a question, with none nothing happens.
    # Fires `Events::ManifestedDread` ("whenever you manifest dread").
    #
    #   Magic::Choice::ManifestDread.perform(actor: actor)              # the actor's controller manifests dread
    #   Magic::Choice::ManifestDread.perform(actor: actor, player: p2)  # "its controller manifests dread"
    #
    # Answer the choice with `game.resolve_choice!(target: card)`, the card to manifest. A subclass can override
    # `manifested(permanent)` to continue once the face-down creature is there ("then put X +1/+1 counters on it");
    # `perform` called on the subclass uses it.
    class ManifestDread < Choice
      def self.perform(actor:, player: actor.controller)
        choice = new(actor: actor, player: player)
        if choice.choices.size == 1
          choice.resolve!(target: choice.choices.first)
        elsif choice.choices.any?
          actor.game.add_choice(choice)
        else
          choice.nothing_to_manifest
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

        milled = (choices - [target]).first
        milled&.move_to_graveyard!
        permanent = game.manifest!(target, controller: player)
        game.notify!(Events::ManifestedDread.new(player: player, permanent: permanent, graveyard_card: milled))
        manifested(permanent)
        permanent
      end

      # Called once the face-down creature has entered. Does nothing here.
      def manifested(_permanent) = nil

      # Called by `perform` when the library is empty and so nothing was manifested. Does nothing here.
      def nothing_to_manifest = nil
    end
  end
end
