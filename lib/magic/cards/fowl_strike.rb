module Magic
  module Cards
    class FowlStrike < Instant
      card_name "Fowl Strike"
      cost generic: 1, green: 1

      def single_target? = true

      def target_choices = battlefield.creatures.select(&:flying?)

      # "Destroy target creature with flying."
      def resolve!(target:)
        destroy(target)
      end

      # "Reinforce 2 -- {2}{G}, Discard this card: Put two +1/+1 counters on target creature."
      class ReinforceAbility < Magic::ActivatedAbility
        def description = "Reinforce 2: put two +1/+1 counters on target creature"

        def costs = [Costs::Mana.new(generic: 2, green: 1), Costs::SelfDiscard.new(source)]

        def requirements_met?
          !!source.zone&.hand? && source.owner == controller
        end

        def target_choices = battlefield.creatures

        def resolve!(target:)
          target.add_counter("+1/+1", amount: 2)
        end
      end

      def hand_abilities = [ReinforceAbility.new(source: self)]
    end
  end
end
