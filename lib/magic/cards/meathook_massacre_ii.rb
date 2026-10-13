module Magic
  module Cards
    class MeathookMassacreII < Enchantment
      card_name "Meathook Massacre II"
      type T::Super::Legendary, T::Enchantment
      cost x: 1, black: 4

      # {X}{X}{B}{B}{B}{B}: pay twice X, cast with `value_for_x: X`.
      def x_multiplier = 2

      # "When Meathook Massacre II enters, each player sacrifices X creatures of their choice."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent == actor
        end

        def call
          Magic::Choice::SacrificeCreatures.each_player(actor: actor, amount: actor.x_value.to_i)
        end
      end

      # "Whenever a creature you control dies, you may pay 3 life. If you do, return that card under your control with a
      # finality counter on it."
      class OwnCreatureChoice < Magic::Choice::May
        def initialize(actor:, card:)
          super(actor: actor)
          @card = card
        end

        def prompt = "Pay 3 life to return #{@card.name} to the battlefield?"

        def resolve!
          return unless controller.life >= 3 && @card.zone&.graveyard?

          lose_life(controller, 3)
          Permanent.put_onto_battlefield(game: game, card: @card, from_zone: @card.zone, controller: controller, counters: { "finality" => 1 })
        end
      end

      # "Whenever a creature an opponent controls dies, they may pay 3 life. If they don't, return that card under your
      # control with a finality counter on it." The opponent decides: accepting pays the life, declining gives it to you.
      class OpponentCreatureChoice < Magic::Choice::May
        attr_reader :opponent

        def initialize(actor:, card:, opponent:)
          super(actor: actor)
          @card = card
          @opponent = opponent
        end

        def chooser = opponent

        def prompt = "Pay 3 life, or #{actor.controller.name} returns #{@card.name} under their control?"

        def resolve!
          if opponent.life >= 3
            lose_life(opponent, 3)
          else
            decline!
          end
        end

        def decline!
          return unless @card.zone&.graveyard?

          Permanent.put_onto_battlefield(game: game, card: @card, from_zone: @card.zone, controller: controller, counters: { "finality" => 1 })
        end
      end

      class CreatureDiedTrigger < TriggeredAbility
        def should_perform?
          !event.permanent.token?
        end

        def call
          card = event.permanent.card
          if event.controller == controller
            game.add_choice(OwnCreatureChoice.new(actor: actor, card: card))
          else
            game.add_choice(OpponentCreatureChoice.new(actor: actor, card: card, opponent: event.controller))
          end
        end
      end

      def etb_triggers = [EntersTrigger]
      def event_handlers = { Events::CreatureDied => CreatureDiedTrigger }
    end
  end
end
