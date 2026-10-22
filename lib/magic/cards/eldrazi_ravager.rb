module Magic
  module Cards
    EldraziRavager = Creature("Eldrazi Ravager") do
      cost "{5}{C}"
      creature_type "Eldrazi"
      keywords Keywords::Annihilator.new(1)
      power 6
      toughness 6
    end

    class EldraziRavager < Creature
      cycling "{2}"

      # "Sacrifice two Eldrazi": payment is an Array of exactly two Eldrazi the controller controls.
      class SacrificeTwoEldrazi < Costs::Sacrifice
        def choices = permanent.controller.permanents.select { _1.type?("Eldrazi") }

        def can_pay?(_player = nil) = choices.size >= 2

        def unpayable_reason
          "#{permanent.controller.name} controls fewer than two Eldrazi" unless can_pay?
        end

        def pay(payment:)
          payment = Array(payment)
          raise ArgumentError, "Sacrifice exactly two Eldrazi" unless payment.size == 2 && payment.uniq.size == 2
          raise ArgumentError, "Only Eldrazi you control can be sacrificed" unless payment.all? { choices.include?(_1) }

          payment.each(&:sacrifice!)
        end
      end

      # "Sacrifice two Eldrazi: Return this card from your graveyard to your hand."
      class GraveyardAbility < Magic::ActivatedAbility
        def costs = [SacrificeTwoEldrazi.new(source, nil)]

        def requirements_met? = source.zone&.graveyard? && source.owner == controller

        def resolve!
          source.move_to_hand!(source.owner)
        end
      end

      def graveyard_abilities = [GraveyardAbility.new(source: self)]
    end
  end
end
