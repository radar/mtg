module Magic
  module Cards
    OmnivorousFlytrap = Creature("Omnivorous Flytrap") do
      cost generic: 2, green: 1
      creature_type "Plant"
      power 2
      toughness 4
    end

    class OmnivorousFlytrap < Creature
      # "Delirium -- Whenever this creature enters or attacks, if there are four or more card types among cards in your
      # graveyard, distribute two +1/+1 counters among one or two target creatures. Then if there are six or more card
      # types among cards in your graveyard, double the number of +1/+1 counters on those creatures."
      module DistributeCounters
        class DistributeCountersChoice < Magic::Choice
          def prompt = "Omnivorous Flytrap: distribute two +1/+1 counters among one or two creatures."

          def choices = game.battlefield.creatures

          def resolve!(distribution: {})
            distribution.each do |target, amount|
              amount.times { add_counter("+1/+1", to: target) }
            end

            return unless controller.graveyard.card_type_count >= 6

            distribution.each_key do |target|
              existing = target.counters.of_type(Counters::Plus1Plus1).count
              add_counter("+1/+1", to: target, amount: existing) if existing.positive?
            end
          end
        end

        def should_perform?
          super && controller.graveyard.delirium?
        end

        def call
          game.choices.add(DistributeCountersChoice.new(actor: actor))
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        include DistributeCounters
      end

      class AttacksTrigger < TriggeredAbility
        include DistributeCounters

        def should_perform?
          event.attacks.any? { _1.attacker == actor } && super
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers = super.merge(Events::FinalAttackersDeclared => AttacksTrigger)
    end
  end
end
