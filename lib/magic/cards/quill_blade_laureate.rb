module Magic
  module Cards
    QuillBladeLaureate = Creature("Quill-Blade Laureate") do
      cost generic: 1, white: 1
      creature_type "Human Cleric"
      keywords :double_strike
      power 1
      toughness 1
    end

    class QuillBladeLaureate < Creature
      class PreparedTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          under_your_control?
        end

        def call
          actor.prepare!
        end
      end

      class CastTwofoldIntent < Magic::ActivatedAbility
        costs "{1}{W}"

        def requirements_met?
          source.prepared?
        end

        def single_target?
          true
        end

        def target_choices
          creatures
        end

        def resolve!(target:)
          source.unprepare!
          target.modify_power(1)
          target.grant_double_strike!
        end
      end

      def etb_triggers = [PreparedTrigger]
      def activated_abilities = [CastTwofoldIntent]
    end
  end
end
