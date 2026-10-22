module Magic
  module Cards
    class JoltedAwake < Sorcery
      card_name "Jolted Awake"
      cost white: 1
      cycling generic: 2

      # Then you may pay an amount of {E} equal to that card's mana value. If you do, return it to the battlefield.
      class PayChoice < Magic::Choice::PayEnergy
        attr_reader :card

        def initialize(actor:, card:)
          @card = card
          super(actor: actor, amount: card.mana_value)
        end

        def resolve!
          super
          reanimate(card, controller: chooser) if card.zone&.graveyard?
        end
      end

      def multi_target? = true

      def target_choices
        [controller.graveyard.cards.select { |card| card.artifact? || card.creature? }]
      end

      # Choose up to one target artifact or creature card in your graveyard. You get {E}{E}. Then you may pay an
      # amount of {E} equal to that card's mana value. If you do, return it from your graveyard to the battlefield.
      def resolve!(targets:)
        gain_energy 2
        card = targets.first
        return unless card&.zone&.graveyard?

        choice = PayChoice.new(actor: self, card: card)
        game.add_choice(choice) if choice.can_pay?
      end
    end
  end
end
