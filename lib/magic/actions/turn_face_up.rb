module Magic
  module Actions
    # Special action (rule 116.2b): turn a face-down permanent you control face up, any time you have priority. For a
    # manifested creature card the price is its mana cost (rule 701.40b). A face-down card that isn't a creature card
    # has no cost to pay, so it can't be turned up.
    class TurnFaceUp < Action
      # What turn-face-up mana is being spent on, as `Costs::Mana#for_use` (for "spend this mana only to turn permanents
      # face up").
      Use = Data.define(:permanent)

      attr_reader :permanent

      def initialize(permanent:, **args)
        @permanent = permanent
        super(**args)
      end

      def inspect
        "#<Actions::TurnFaceUp permanent: #{permanent.card.name}, player: #{player.inspect}>"
      end

      def uses_priority? = false

      def mana_cost
        return unless permanent.card.creature?

        @mana_cost ||= Costs::Mana.new(permanent.card.cost.cost.dup).tap { |cost| cost.for_use = Use.new(permanent: permanent) }
      end

      def pay_mana(payment)
        mana_cost.pay(player: player, payment: payment)
        self
      end

      def can_perform?
        !mana_cost.nil? && mana_cost.can_pay?(player)
      end

      def illegal_reason
        return "#{permanent.card.name} is not face down" unless permanent.face_down?
        return "#{permanent.card.name} is not on the battlefield" unless permanent.zone&.battlefield?
        return "#{player.inspect} does not control that permanent" unless permanent.controller == player
        return "#{permanent.card.name} is not a creature card, so it can't be turned face up" unless permanent.card.creature?

        "#{permanent.card.name} can't be turned face up" unless permanent.can_be_turned_face_up?
      end

      def perform
        mana_cost.finalize!(player)
        permanent.turn_face_up!
      end
    end
  end
end
