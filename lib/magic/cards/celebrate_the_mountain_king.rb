module Magic
  module Cards
    CelebrateTheMountainKing = Enchantment("Celebrate the Mountain-king") do
      cost generic: 3, white: 1
    end

    class CelebrateTheMountainKing < Enchantment
      class ExileEffect < Effects::ExilePermanent
        def resolve!
          super
          # An exiled token ceases to exist: there is nothing to return later.
          source.exiled_cards << target.card unless target.token?
        end
      end

      # "for each opponent, exile up to one target nonland permanent that player controls until this
      # enchantment leaves the battlefield."
      class ExileChoice < Magic::Choice::Targeted
        def initialize(actor:, opponent:)
          @opponent = opponent
          super(actor: actor)
        end

        def prompt = "Exile up to one target nonland permanent #{@opponent.name} controls."

        def choices = @opponent.permanents.nonland

        def choice_amount = 0..1

        def resolve!(target:)
          actor.game.add_effect(ExileEffect.new(source: actor, target: target))
        end
      end

      class ExileTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.opponents(controller).each do |opponent|
            choice = ExileChoice.new(actor: actor, opponent: opponent)
            game.add_choice(choice) if choice.choices.any?
          end
        end
      end

      class RecruitTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          Recruit.call(player: controller)
        end
      end

      class LeavesTrigger < TriggeredAbility::LeaveTheBattlefield
        def call
          actor.exiled_cards.each(&:return_to_battlefield!)
        end
      end

      def etb_triggers = [ExileTrigger, RecruitTrigger]
      def ltb_triggers = [LeavesTrigger]
    end
  end
end
