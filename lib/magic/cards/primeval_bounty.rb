module Magic
  module Cards
    PrimevalBounty = Enchantment("Primeval Bounty") do
      cost generic: 5, green: 1
    end

    class PrimevalBounty < Enchantment
      class SpellCastTrigger1 < TriggeredAbility::SpellCast
        def should_perform?
          you? && spell.type?("Creature")
        end

        BeastToken = Token.create "Beast" do
          creature_type "Beast"
          power 3
          toughness 3
          colors :green
        end

        def call
          trigger_effect(:create_token, token_class: BeastToken)
        end
      end

      class SpellCastTrigger2 < TriggeredAbility::SpellCast
        def should_perform?
          you? && !spell.type?("Creature")
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.controlled_by(controller).creatures
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 3)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform?
          you?
        end

        def call
          trigger_effect(:gain_life, target: controller, life: 3)
        end
      end

      def event_handlers = { Events::SpellCast => [SpellCastTrigger1, SpellCastTrigger2], Events::Landfall => LandfallTrigger }
    end
  end
end
