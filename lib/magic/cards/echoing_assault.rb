module Magic
  module Cards
    EchoingAssault = Enchantment("Echoing Assault") do
      cost generic: 4, red: 1
    end

    class EchoingAssault < Enchantment
      # "Creature tokens you control have menace."
      class TokensMenace < Abilities::Static::KeywordGrant
        keyword_grants Keywords::MENACE
        applicable_targets { source.controller.creatures.select(&:token?) }
      end

      class EndStepSacrifice < TriggeredAbility::BeginningOfEndStep
        def call = actor.sacrifice!
      end

      # "choose target nontoken creature that's attacking that player. Create a token that's a copy of that creature,
      # except it's 1/1. The token enters tapped and attacking that player. Sacrifice it at the beginning of the next
      # end step."
      class CopyChoice < Magic::Choice::Targeted
        def initialize(actor:, defender:)
          @defender = defender
          super(actor: actor)
        end

        def choices
          game.current_turn.attacks.select { |attack| attack.target == @defender }.map(&:attacker).reject(&:token?).select { _1.controller == controller }
        end

        def choice_amount = 1

        def resolve!(target:)
          copy = Permanent.resolve(
            game: game,
            owner: controller,
            card: target.copiable_card,
            token: true,
            copy: true,
            cast: false,
            enters_tapped: true,
          )
          copy.modify_base_power(1, until_eot: false)
          copy.modify_base_toughness(1, until_eot: false)
          copy.apply_continuous_effects!
          game.current_turn.declare_attacker(copy, target: @defender)
          copy.register_turn_trigger(Events::BeginningOfEndStep, EndStepSacrifice)
        end
      end

      # "Whenever you attack a player": once for each player attacked.
      class AttackTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller
        end

        def call
          event.attacks.map(&:target).select { _1.respond_to?(:player?) && _1.player? }.uniq.each do |defender|
            choice = CopyChoice.new(actor: actor, defender: defender)
            # Mandatory, so a lone legal target is chosen for you (Stack#add_choice).
            game.add_choice(choice) if choice.choices.any?
          end
        end
      end

      def static_abilities = [TokensMenace]
      def event_handlers = { Events::FinalAttackersDeclared => AttackTrigger }
    end
  end
end
