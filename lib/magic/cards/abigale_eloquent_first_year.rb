module Magic
  module Cards
    class AbigaleEloquentFirstYear < Creature
      card_name "Abigale, Eloquent First-Year"
      cost "{W/B}{W/B}"
      legendary_creature_type "Bird Bard"
      power 1
      toughness 1
      keywords :flying, :first_strike, :lifelink

      class TargetChoice < Magic::Choice::Targeted
        def choices = battlefield.creatures.except(actor)

        def choice_amount = 0..1

        # "... loses all abilities. Put a flying counter, a first strike counter, and a lifelink
        # counter on that creature."
        def resolve!(target:)
          target.lose_all_abilities!
          %w[flying first\ strike lifelink].each { trigger_effect(:add_counter, counter_type: _1, target:) }
        end
      end

      # "When Abigale enters, up to one other target creature loses all abilities. ..."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          choice = TargetChoice.new(actor:)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
