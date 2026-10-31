module Magic
  module Cards
    MorgulKnifeWound = Aura("Morgul-Knife Wound") do
      cost generic: 1, black: 1
    end

    class MorgulKnifeWound < Aura
      enchant "Creature"

      def target_choices
        battlefield.creatures
      end

      # "Enchanted creature gets -3/-0"
      class EnchantedCreatureDebuff < Abilities::Static::PowerAndToughnessModification
        modify power: -3, toughness: 0
        applies_to_target
      end

      def static_abilities = [EnchantedCreatureDebuff]

      # "...and has 'At the beginning of your upkeep, exile this creature unless you pay 2 life.'"
      # The trigger belongs to the enchanted creature's controller, so the Aura watches every upkeep and acts only on
      # that player's. Paying is a choice (offered only when they have the life); declining or being unable exiles.
      class PayLifeOrExile < Magic::Choice::May
        def creature = actor.attached_to

        def chooser = creature.controller

        def prompt = "Pay 2 life? If you don't, exile #{creature.name}."

        def can_pay? = chooser.life >= 2

        def resolve!
          chooser.lose_life(2)
        end

        def decline!
          exile_target creature
        end
      end

      class UpkeepTrigger < TriggeredAbility
        def should_perform?
          actor.attached_to && event.player == actor.attached_to.controller
        end

        def call
          choice = PayLifeOrExile.new(actor: actor)
          if choice.can_pay?
            game.choices.add(choice)
          else
            choice.decline!
          end
        end
      end

      def event_handlers = { Events::BeginningOfUpkeep => UpkeepTrigger }
    end
  end
end
