module Magic
  module Cards
    StarfallInvocation = Sorcery("Starfall Invocation") do
      cost generic: 3, white: 2
    end

    class StarfallInvocation < Sorcery
      # "Gift a card": promised as the spell is cast (see Costs::Gift).
      def kicker_cost
        @gift ||= Costs::Gift.new(self)
      end

      # "return a creature card put into your graveyard this way to the battlefield under your control."
      class ReturnChoice < Magic::Choice::Targeted
        attr_reader :choices

        def initialize(actor:, choices:)
          @choices = choices
          super(actor: actor)
        end

        def targets? = false
        def choice_amount = 1

        def resolve!(target:)
          target.resolve!(controller: controller)
        end
      end

      def resolve!(controller: self.controller)
        gift = kicker_cost.paid?
        # "they draw a card before its other effects."
        game.opponents(controller).first.draw! if gift

        destroyed = battlefield.creatures.to_a.filter_map do |creature|
          creature.card if creature.destroy! && !creature.token? && creature.owner == controller
        end

        return unless gift && destroyed.any?

        game.add_choice(ReturnChoice.new(actor: self, choices: destroyed))
      end
    end
  end
end
