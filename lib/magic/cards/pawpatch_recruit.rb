module Magic
  module Cards
    PawpatchRecruit = Creature("Pawpatch Recruit") do
      cost green: 1
      creature_type("Rabbit Warrior")
      keywords :trample
      power 2
      toughness 1
      offspring generic: 2
    end

    class PawpatchRecruit < Creature
      # Whenever a creature you control becomes the target of a spell or ability an opponent controls, put a
      # +1/+1 counter on target creature you control other than that creature.
      class TargetedTrigger < TriggeredAbility
        class CounterChoice < Magic::Choice::Targeted
          def initialize(actor:, excluded:)
            @excluded = excluded
            super(actor: actor)
          end

          def choices = battlefield.controlled_by(controller).creatures - [@excluded]

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 1)
          end
        end

        def targeted_creatures
          event.targets.select { _1.is_a?(Permanent) && _1.creature? && _1.controller == controller }
        end

        def should_perform? = opponents.include?(event.player) && targeted_creatures.any?

        def call
          targeted_creatures.each do |creature|
            choice = CounterChoice.new(actor: actor, excluded: creature)
            game.add_choice(choice) if choice.choices.any?
          end
        end
      end

      def event_handlers = super.merge(Events::SpellCast => TargetedTrigger, Events::AbilityActivated => TargetedTrigger)
    end
  end
end
