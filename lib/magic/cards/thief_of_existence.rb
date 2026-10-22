module Magic
  module Cards
    ThiefOfExistence = Creature("Thief of Existence") do
      cost generic: 1, colorless: 1, green: 1
      creature_type "Eldrazi"
      power 3
      toughness 4
      keywords :devoid
    end

    class ThiefOfExistence < Creature
      # Set when the cast trigger exiled something: "Thief of Existence gains 'When this creature leaves the
      # battlefield, target opponent draws a card.'" The card keeps it as it becomes a permanent.
      attr_accessor :opponent_draws_on_leaving

      # "...exile up to one target noncreature, nonland permanent an opponent controls with mana value 4 or less."
      class ExileChoice < Magic::Choice::Targeted
        def choices
          battlefield.not_controlled_by(controller).select do |permanent|
            !permanent.creature? && !permanent.land? && permanent.mana_value <= 4
          end
        end

        def choice_amount = 0..1

        # "If you do, ..."
        def resolve!(target:)
          exile_target(target)
          actor.opponent_draws_on_leaving = true
        end
      end

      # "When you cast this spell, ..."
      class CastTrigger < TriggeredAbility::CastThisSpell
        def call
          actor.opponent_draws_on_leaving = false
          choice = ExileChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # "When this creature leaves the battlefield, target opponent draws a card."
      class LeavesTrigger < TriggeredAbility::LeaveTheBattlefield
        class OpponentChoice < Magic::Choice::Targeted
          def choices = game.opponents(controller)

          def choice_amount = 1

          def resolve!(target:)
            draw_card(player: target)
          end
        end

        def should_perform? = event.permanent == actor && actor.card.opponent_draws_on_leaving

        def call
          # The gained ability belongs to this permanent only (CR 400.7).
          actor.card.opponent_draws_on_leaving = false
          game.add_choice(OpponentChoice.new(actor: actor))
        end
      end

      def cast_triggers = [CastTrigger]
      def ltb_triggers = [LeavesTrigger]
    end
  end
end
