module Magic
  class Choice
    # "Reveal the top X cards of your library. You may put any number of permanent cards with mana value X or
    # less from among them onto the battlefield. Then put all cards revealed this way that weren't put onto the
    # battlefield into your graveyard." (Genesis Wave.) `cards` are the revealed cards (still in the library);
    # the player picks any number of those passing `filter` (`resolve!(targets: [...])`, `[]` for none), the
    # rest go to the graveyard.
    class PutOntoBattlefieldFromAmong < Choice
      attr_reader :cards

      def initialize(actor:, cards:, filter:)
        @cards = cards.to_a
        # Applied now, not kept: a lambda can't be copied with Marshal, which arena does to games.
        @choices = @cards.select(&filter)
        super(actor: actor)
      end

      attr_reader :choices

      def resolve!(targets: [])
        targets = Array(targets).uniq
        invalid = targets - choices
        raise ArgumentError, "#{invalid.map(&:name).join(', ')} can't be put onto the battlefield" if invalid.any?

        targets.each { trigger_effect(:return_target_from_graveyard_to_battlefield, target: _1, controller: controller) }
        (cards - targets).each(&:move_to_graveyard!)
      end
    end
  end
end
