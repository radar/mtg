module Magic
  module Cards
    ComposerOfSpring = Creature("Composer of Spring") do
      cost "{1}{G}"
      creature_type "Satyr Bard"
      power 2
      toughness 3
    end

    class ComposerOfSpring < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          enchantment? && under_your_control?
        end


        def call
          choice = if battlefield.controlled_by(controller).enchantments.count > 6
            LandOrCreatureChoice
          else
            LandChoice
          end

          game.add_choice(choice.new(actor: actor))
        end
      end

      class LandChoice < Magic::Choice::May
        def choices
          controller.hand.lands
        end

        def resolve!(target:)
          target.resolve!(enters_tapped: true)
        end
      end

      class LandOrCreatureChoice < Magic::Choice::May
        def choices
          controller.hand.lands + controller.hand.creatures
        end

        def resolve!(target:)
          target.resolve!(enters_tapped: true)
        end
      end

      def event_handlers
        {
          Events::EnteredTheBattlefield => EntersTrigger
        }
      end

    end
  end
end
