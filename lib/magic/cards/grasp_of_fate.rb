module Magic
  module Cards
    GraspOfFate = Enchantment("Grasp of Fate") do
      cost generic: 1, white: 2
    end

    class GraspOfFate < Enchantment
      class ExileEffect < Effects::ExilePermanent
        def resolve!
          super
          # An exiled token ceases to exist: there is nothing to return later.
          source.exiled_cards << target.card unless target.token?
        end
      end

      # A target (rule 115), so hexproof, shroud and protection apply: see Choice::Targeted.
      class Choice < Magic::Choice::Targeted
        attr_reader :choices

        def prompt = "Exile up to one target nonland permanent an opponent controls until Grasp of Fate leaves the battlefield."

        def initialize(actor:)
          @choices = actor.game.opponents(actor.controller).flat_map do |opponent|
            opponent.permanents.nonland
          end
          super
        end

        def choice_amount = 1

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
          actor.exiled_cards.each(&:return_to_battlefield!)
        end
      end

      def etb_triggers = [EntersTrigger]
      def ltb_triggers = [LeavesTrigger]
    end
  end
end