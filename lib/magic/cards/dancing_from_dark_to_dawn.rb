module Magic
  module Cards
    DancingFromDarkToDawn = Enchantment("Dancing from Dark to Dawn") do
      cost generic: 3, green: 2
    end

    class DancingFromDarkToDawn < Enchantment
      BearToken = Token.create "Bear" do
        creature_type "Bear"
        power 2
        toughness 2
        colors :green
      end

      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && spell.type?("Creature")
        end

        class TargetChoice < Magic::Choice::Targeted
          def initialize(actor:, amount:)
            @amount = amount
            super(actor: actor)
          end

          def choices
            controller.creatures
          end

          def choice_amount = 1

          def resolve!(target:)
            add_counter("+1/+1", to: target, amount: @amount)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor, amount: spell.mana_value)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform?
          you?
        end

        def call
          create_token(token:DancingFromDarkToDawn::BearToken)
        end
      end

      def event_handlers
        { Events::SpellCast => SpellCastTrigger, Events::Landfall => LandfallTrigger }
      end
    end
  end
end
