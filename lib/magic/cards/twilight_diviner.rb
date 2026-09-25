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

      def etb_triggers = [EntersTrigger]

      # "Whenever one or more other creatures you control enter, if they entered or were
      # cast from a graveyard, create a token that's a copy of one of them. This ability
      # triggers only once each turn." A spell's card stays in the zone it was cast from
      # until it resolves, so `event.from` is a graveyard in both cases. Creatures enter
      # one event at a time, so the first one to enter is the one copied.
      class GraveyardCreatureEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          another_creature? && under_your_control? && event.from&.graveyard? && !actor.triggered_once_this_turn?(self.class)
        end

        def call
          actor.trigger_once_this_turn!(self.class)
          Permanent.resolve(game:, owner: controller, card: event.permanent.copiable_card, token: true, copy: true, cast: false)
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => GraveyardCreatureEntersTrigger }
    end
  end
end
