module Magic
  module Cards
    EndBlazeEpiphany = Instant("End-Blaze Epiphany") do
      cost red: 1, x: 1
    end

    class EndBlazeEpiphany < Instant
      # "... then choose a card exiled this way. Until the end of your next turn, you may
      # play that card."
      class ChooseExiledCard < Magic::Choice
        attr_reader :player, :choices

        def initialize(actor:, player:, cards:)
          super(actor:)
          @player = player
          @choices = cards
        end

        def resolve!(target:)
          raise ArgumentError, "choose one of the exiled cards" unless choices.include?(target)

          game.play_permissions.grant_until_end_of_next_turn(card: target, player:)
        end
      end

      def target_choices
        battlefield.creatures
      end

      # "End-Blaze Epiphany deals X damage to target creature. When that creature dies this
      # turn, exile a number of cards from the top of your library equal to its power, then
      # choose a card exiled this way." The delayed trigger lives on the creature for the
      # rest of the turn; its power is what it had as it died.
      def resolve!(target:, value_for_x:)
        caster = controller
        spell = self
        dies_trigger = Class.new(TriggeredAbility) do
          define_method(:should_perform?) { this? }
          define_method(:call) { spell.exile_from_top(player: caster, amount: actor.power) }
        end
        target.register_turn_trigger(Events::CreatureDied, dies_trigger)

        trigger_effect(:deal_damage, target:, damage: value_for_x) if value_for_x.positive?
      end

      def exile_from_top(player:, amount:)
        cards = player.library.first([amount, 0].max)
        return if cards.empty?

        cards.each { trigger_effect(:exile, target: _1) }
        game.add_choice(ChooseExiledCard.new(actor: self, player:, cards:))
      end
    end
  end
end
