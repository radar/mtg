module Magic
  module Cards
    class SettleTheWreckage < Instant
      card_name "Settle the Wreckage"
      cost generic: 2, white: 2

      # "That player may search their library for that many basic land cards, put those cards onto the battlefield
      # tapped, then shuffle." The searching player is the target, not the caster.
      class SearchChoice < Magic::Choice::SearchLibrary
        def initialize(actor:, player:, upto:)
          @player = player
          super(actor: actor, filter: Filter[:basic_lands], enters_tapped: true, upto: upto, to_zone: :battlefield)
          @choices = player.library.filter(Filter[:basic_lands])
        end

        def controller = @player
      end

      def single_target?
        true
      end

      def target_choices = game.players

      def resolve!(target:)
        attackers = battlefield.creatures.attacking.controlled_by(target).to_a
        attackers.each { trigger_effect(:exile, target: _1) }
        choice = SearchChoice.new(actor: self, player: target, upto: attackers.size)
        game.add_choice(choice) if attackers.any? && choice.choices.any?
      end
    end
  end
end
