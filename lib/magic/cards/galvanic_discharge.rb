module Magic
  module Cards
    class GalvanicDischarge < Instant
      card_name "Galvanic Discharge"
      cost red: 1

      # Deals damage equal to the energy paid to the chosen permanent.
      class PayChoice < Magic::Choice::PayAnyEnergy
        attr_reader :target

        def initialize(actor:, target:)
          @target = target
          super(actor: actor)
        end

        def paid(amount)
          deal_damage(amount, to: target) if amount.positive?
        end
      end

      def target_choices = game.battlefield.creatures + game.battlefield.planeswalkers

      # Choose target creature or planeswalker. You get {E}{E}{E}, then you may pay any amount of {E}. This deals that
      # much damage to that permanent.
      def resolve!(target:)
        gain_energy 3
        game.add_choice(PayChoice.new(actor: self, target: target))
      end
    end
  end
end
