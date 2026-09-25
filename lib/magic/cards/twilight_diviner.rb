module Magic
  module Cards
    TwilightDiviner = Creature("Twilight Diviner") do
      cost generic: 2, black: 1
      creature_type("Elf Cleric")
      power 3
      toughness 3
    end

    class TwilightDiviner < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::Surveil.new(actor: actor, amount: 2))
        end
      end

      # "Whenever one or more other creatures you control enter, if they entered or were cast
      # from a graveyard, create a token that's a copy of one of them. This ability triggers
      # only once each turn." Creatures enter one at a time here, so each entry is its own
      # "one or more"; the once-a-turn mark is taken at trigger time (see
      # OnduSpiritdancer::EntersTrigger for why it can't wait for #call).
      class CopyTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          another_creature? && under_your_control? &&
            event.permanent.entered_from_graveyard? &&
            !actor.triggered_once_this_turn?(self.class)
        end

        def trigger!
          return false unless should_perform?
          actor.trigger_once_this_turn!(self.class)
          true
        end

        def call
          Permanent.resolve(
            game: game,
            owner: controller,
            card: event.permanent.card.class.new(game: game, owner: controller),
            token: true,
            cast: false,
          )
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers
        { Events::EnteredTheBattlefield => CopyTrigger }
      end
    end
  end
end
