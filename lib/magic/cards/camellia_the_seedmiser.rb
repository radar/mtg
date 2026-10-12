module Magic
  module Cards
    CamelliaTheSeedmiser = Creature("Camellia, the Seedmiser") do
      type T::Super::Legendary, T::Creature, *creature_types("Squirrel Warlock")
      cost "{1}{B}{G}"
      keywords :menace
      power 3
      toughness 3
    end

    class CamelliaTheSeedmiser < Creature
      SquirrelToken = Token.create "Squirrel" do
        creature_type "Squirrel"
        power 1
        toughness 1
        colors :green
      end

      # Other Squirrels you control have menace.
      class SquirrelMenace < Abilities::Static::KeywordGrant
        keyword_grants Keywords::MENACE

        def applicable_targets = controller.creatures.select { _1.type?("Squirrel") }.reject { _1 == source }
      end

      def static_abilities = [SquirrelMenace]

      # Whenever you sacrifice one or more Foods, create a 1/1 green Squirrel creature token.
      class SacrificeTrigger < TriggeredAbility
        def should_perform?
          event.permanent.controller == controller && event.permanent.type?("Food")
        end

        def call
          trigger_effect(:create_token, token_class: SquirrelToken)
        end
      end

      def event_handlers = super.merge(Events::PermanentSacrificed => SacrificeTrigger)

      # {2}, Forage: Put a +1/+1 counter on each other Squirrel you control.
      class ForageAbility < Magic::ActivatedAbility
        costs "{2}, Forage"

        def resolve!
          controller.creatures.select { _1.type?("Squirrel") }.reject { _1 == source }.each do |squirrel|
            trigger_effect(:add_counter, counter_type: "+1/+1", target: squirrel, amount: 1)
          end
        end
      end

      def activated_abilities = [ForageAbility]
    end
  end
end
