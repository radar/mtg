module Magic
  module Cards
    GraspOfFate = Enchantment("Grasp of Fate") do
      cost generic: 1, white: 2
    end

    class GraspOfFate < Enchantment
      class ExileEffect < Effects::ExilePermanent
        def resolve!
          super
          source.exiled_cards << target.card
        end
      end

      class Choice < Magic::Choice
        attr_reader :choices

        def initialize(actor:)
          @choices = actor.game.opponents(actor.controller).flat_map do |opponent|
            opponent.permanents.nonland
          end
          super
        end

        def resolve!(target:)
          actor.game.add_effect(ExileEffect.new(source: actor, target: target))
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.add_choice(Choice.new(actor: actor))
        end
      end

      class LeavesTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          actor.exiled_cards.each(&:resolve!)
        end
      end

      def etb_triggers = [EntersTrigger]
      def ltb_triggers = [LeavesTrigger]
    end
  end
end