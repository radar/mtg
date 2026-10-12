module Magic
  module Cards
    BeornsHospitality = Enchantment("Beorn's Hospitality") do
      cost generic: 1, green: 1
    end

    class BeornsHospitality < Enchantment
      # The permanent this enchantment's animation applies to ("This effect doesn't end"). A new permanent object after
      # the card leaves and returns is not animated.
      attr_accessor :animated_permanent

      # Landfall -- "Whenever a land you control enters, put a +1/+1 counter on target creature you control."
      class CounterChoice < Magic::Choice::Targeted
        def choices = battlefield.controlled_by(controller).creatures

        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:add_counter, target: target, counter_type: "+1/+1")
        end
      end

      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform? = you?

        def call
          choice = CounterChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # "{5}{G}{G}: This enchantment becomes a Bear creature in addition to its other types and gains 'This creature's
      # power and toughness are each equal to the number of lands you control.' (This effect doesn't end.)"
      class AnimateAbility < Magic::ActivatedAbility
        costs "{5}{G}{G}"

        def resolve!
          source.card.animated_permanent = source
          source.apply_continuous_effects!
        end
      end

      module WhileAnimated
        def applicable_targets
          source.card.animated_permanent.equal?(source) ? [source] : []
        end
      end

      class AnimatedTypes < Abilities::Static::TypeGrant
        include WhileAnimated

        def type_grants = [T::Creature, T::Creatures["Bear"]]
      end

      class AnimatedBasePowerAndToughness < Abilities::Static::CharacteristicSetting
        include WhileAnimated

        def set_base_power(permanent) = permanent.controller.permanents.lands.count
        def set_base_toughness(permanent) = permanent.controller.permanents.lands.count
      end

      def activated_abilities = [AnimateAbility]
      def static_abilities = [AnimatedTypes, AnimatedBasePowerAndToughness]

      def event_handlers = super.merge(Events::Landfall => LandfallTrigger)
    end
  end
end
