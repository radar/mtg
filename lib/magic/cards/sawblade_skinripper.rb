module Magic
  module Cards
    SawbladeSkinripper = Creature("Sawblade Skinripper") do
      cost generic: 1, black: 1, red: 1
      creature_type "Human Assassin"
      power 3
      toughness 2
      keywords :menace
    end

    class SawbladeSkinripper < Creature
      # "{2}, Sacrifice another creature or enchantment: Put a +1/+1 counter on this creature."
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{2}, Sacrifice another creature or enchantment"

        def resolve!
          source.add_counter("+1/+1")
        end
      end

      def activated_abilities = [ActivatedAbility]

      # "At the beginning of your end step, if you sacrificed one or more permanents this turn, this creature deals
      # that much damage to any target."
      class DamageChoice < Magic::Choice::Targeted
        attr_reader :amount

        def prompt = "#{actor.name} deals #{amount} damage to any target."

        def initialize(amount:, **args)
          @amount = amount
          super(**args)
        end

        def choice_amount = 1

        def choices = game.any_target

        def resolve!(target:)
          actor.trigger_effect(:deal_damage, source: actor, target:, damage: amount)
        end
      end

      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform? = controllers_end_step? && sacrificed_count.positive?

        def call
          game.add_choice(DamageChoice.new(actor:, amount: sacrificed_count))
        end

        private

        def sacrificed_count
          game.current_turn.events.count do |e|
            e.is_a?(Events::PermanentSacrificed) && e.permanent.controller == controller
          end
        end
      end

      def event_handlers = { Events::BeginningOfEndStep => EndStepTrigger }
    end
  end
end
