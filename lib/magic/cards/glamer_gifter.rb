module Magic
  module Cards
    GlamerGifter = Creature("Glamer Gifter") do
      cost generic: 1, blue: 1
      creature_type("Faerie Wizard")
      keywords :flash, :flying
      power 1
      toughness 2
    end

    class GlamerGifter < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            (battlefield.creatures - [actor])
          end

          def choice_amount = 1

          def single_target? = false

          def resolve!(target:)
            target.modify_base_power(4)
            target.modify_base_toughness(4)
            target.add_types(*Magic::Types::Creatures.values)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
