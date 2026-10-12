module Magic
  module Cards
    TheEaglesAreComing = Instant("The Eagles Are Coming!") do
      cost generic: 1, white: 1
      kicker_cost generic: 2, white: 2
    end

    class TheEaglesAreComing < Instant
      BirdSoldierToken = Token.create "Bird Soldier" do
        creature_type "Bird Soldier"
        power 4
        toughness 4
        colors :white
        keywords :flying
      end

      # "Choose target creature you own. If this spell was kicked, instead choose any number of target creatures you
      # own."
      def target_choices
        game.battlefield.creatures.select { _1.owner == controller }
      end

      # "Return each chosen creature to your hand. At the beginning of the next upkeep, create a 4/4 white Bird Soldier
      # creature token with flying for each creature returned to your hand this way."
      def resolve!(targets:)
        chosen = targets.uniq
        chosen = chosen.first(1) unless kicker_cost.paid?
        returned = chosen.select { _1.zone&.battlefield? }
        returned.each { |creature| trigger_effect(:return_to_owners_hand, target: creature) }
        @tokens_owed = returned.size
        @token_controller = controller
        @tokens_turn = game.current_turn.number
      end

      attr_reader :tokens_owed, :token_controller

      def tokens_pending? = !!@tokens_owed&.positive?

      def tokens_created!
        @tokens_owed = 0
      end

      class UpkeepTrigger < TriggeredAbility
        # The spell has resolved and sits in the graveyard while its delayed trigger waits.
        def self.works_from_graveyard? = true

        def should_perform? = actor.tokens_pending?

        def call
          count = actor.tokens_owed
          actor.tokens_created!
          trigger_effect(:create_token, token_class: BirdSoldierToken, amount: count, controller: actor.token_controller)
        end
      end

      def event_handlers = super.merge({ Events::BeginningOfUpkeep => UpkeepTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
