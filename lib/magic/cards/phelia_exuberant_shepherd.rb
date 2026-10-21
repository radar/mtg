module Magic
  module Cards
    PheliaExuberantShepherd = Creature("Phelia, Exuberant Shepherd") do
      legendary_creature_type "Dog"
      cost generic: 1, white: 1
      power 2
      toughness 2
      keywords :flash
    end

    class PheliaExuberantShepherd < Creature
      # "Exile up to one other target nonland permanent. At the beginning of the next end step, return that card to the
      # battlefield under its owner's control. If it entered under your control, put a +1/+1 counter on Phelia."
      class ExileChoice < Magic::Choice::Targeted
        def prompt = "Choose up to one other nonland permanent to exile."
        def choices = battlefield.permanents.nonland.reject { _1.equal?(actor) }
        def choice_amount = 0..1

        def resolve!(target:)
          card = target.card
          exile_target(target)
          game.subscribe(DelayedReturn.new(game: game, cards: [card], reward_for: controller, reward_to: actor))
        end

        def decline! = nil
      end

      class AttacksTrigger < TriggeredAbility
        def should_perform? = event.attack.attacker == actor

        def call
          choice = ExileChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = super.merge({ Events::AttackDeclared => AttacksTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
