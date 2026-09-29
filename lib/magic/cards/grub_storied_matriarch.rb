module Magic
  module Cards
    class GrubNotoriousAuntie < Creature
      card_name "Grub, Notorious Auntie"
      legendary_creature_type "Goblin Warrior"
      color_indicator :red
      power 2
      toughness 1
      keywords :menace

      class SacrificeTrigger < TriggeredAbility::BeginningOfEndStep
        def call = actor.sacrifice!
      end

      class BlightChoice < Magic::Choice::Blight
        # "... create a tapped and attacking token that's a copy of the blighted creature, except it
        # has 'At the beginning of the end step, sacrifice this token.'"
        def resolve!(target:)
          super
          token = Permanent.resolve(game:, owner: controller, card: target.copiable_card, token: true, copy: true, cast: false, enters_tapped: true)
          token.register_turn_trigger(Events::BeginningOfEndStep, SacrificeTrigger)
          game.current_turn.combat.declare_attacker(token, target: game.current_turn.attacks.find { _1.attacker == actor }&.target)
        end
      end

      class MayBlightChoice < Magic::Choice::May
        def resolve!
          game.choices.add(BlightChoice.new(actor:, amount: 1))
        end
      end

      # "Whenever Grub attacks, you may blight 1. If you do, create a tapped and attacking token
      # that's a copy of the blighted creature, except it has \"At the beginning of the end step,
      # sacrifice this token.\""
      class AttacksTrigger < TriggeredAbility
        def should_perform? = event.attacker == actor

        def call
          game.choices.add(MayBlightChoice.new(actor:)) if Magic::Choice::Blight.possible?(controller, game)
        end
      end

      class PayToTransformTrigger < TriggeredAbility::PayToTransform
        pay black: 1
      end

      def event_handlers
        { Events::CreatureAttacked => AttacksTrigger, Events::FirstMainPhase => PayToTransformTrigger }
      end
    end

    class GrubStoriedMatriarch < Creature
      card_name "Grub, Storied Matriarch"
      cost generic: 2, black: 1
      legendary_creature_type "Goblin Warlock"
      power 2
      toughness 1
      keywords :menace
      back_face GrubNotoriousAuntie

      class ReturnChoice < Magic::Choice::Targeted
        def choices = controller.graveyard.cards.select { _1.type?("Goblin") }

        def choice_amount = 0..1

        def resolve!(target:) = target.move_to_hand!
      end

      # "Whenever this creature enters or transforms into Grub, Storied Matriarch, return up to one
      # target Goblin card from your graveyard to your hand."
      class ReturnTrigger < TriggeredAbility
        def should_perform? = event.permanent == actor

        def call
          choice = ReturnChoice.new(actor:)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call = ReturnTrigger.new(event:, actor:).call
      end

      class PayToTransformTrigger < TriggeredAbility::PayToTransform
        pay red: 1
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers
        { Events::PermanentTransformed => ReturnTrigger, Events::FirstMainPhase => PayToTransformTrigger }
      end
    end
  end
end
