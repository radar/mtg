module Magic
  module Cards
    VrenTheRelentless = Creature("Vren, the Relentless") do
      legendary_creature_type "Rat Rogue"
      cost generic: 2, blue: 1, black: 1
      power 3
      toughness 4
      ward generic: 2
    end

    class VrenTheRelentless < Creature
      # If a creature an opponent controls would die, exile it instead.
      class ExileInstead < ReplacementEffect
        def applies?(effect)
          !!effect.from&.battlefield? && effect.to.graveyard? && effect.target.creature? && effect.target.controller != receiver.controller
        end

        def call(effect)
          exiled = (receiver.state[:exiled] ||= Hash.new(0))
          exiled[receiver.game.current_turn.number] += 1
          Effects::ExilePermanent.new(source: receiver, target: effect.target)
        end
      end

      def replacement_effects = { Effects::MovePermanentZone => ExileInstead }

      # At the beginning of each end step, create X 1/1 black Rat creature tokens with "This token gets +1/+1
      # for each other Rat you control," where X is the number of creatures that were exiled under your
      # opponents' control this turn.
      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform? = (actor.state[:exiled] || {}).fetch(game.current_turn.number, 0).positive?

        def call
          trigger_effect(:create_token, token_class: Tokens::VrenRat, amount: actor.state[:exiled][game.current_turn.number])
        end
      end

      def event_handlers = super.merge(Events::BeginningOfEndStep => EndStepTrigger)
    end
  end
end
