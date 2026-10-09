module Magic
  module Cards
    BeornTheFierce = Creature("Beorn the Fierce") do
      cost generic: 3, green: 2
      legendary_creature_type("Bear Shapeshifter Warrior")
      keywords :trample
      power 6
      toughness 6
    end

    class BeornTheFierce < Creature
      # "Other Bears you control get +2/+2."
      class BearBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 2
        other_creatures "Bear"
      end

      def static_abilities = [BearBuff]

      # "At the beginning of combat on your turn, put a trample counter on up to one target creature you control. It
      # becomes a Bear in addition to its other types. Then if you control three or more Bears, draw two cards."
      class TargetChoice < Magic::Choice::Targeted
        def prompt = "Put a trample counter on up to one target creature you control."

        def choices = controller.creatures

        def choice_amount = 0..1

        def resolve!(target:)
          trigger_effect(:add_counter, counter_type: "trample", target: target, amount: 1)
          target.add_types("Bear", until_eot: false)
          game.tick!
          draw_if_three_bears
        end

        def decline! = draw_if_three_bears

        def draw_if_three_bears
          trigger_effect(:draw_cards, number_to_draw: 2) if controller.creatures.by_type("Bear").count >= 3
        end
      end

      class CombatTrigger < TriggeredAbility
        def should_perform? = event.active_player == controller

        def call
          game.add_choice(TargetChoice.new(actor: actor))
        end
      end

      def event_handlers = { Events::BeginningOfCombat => CombatTrigger }
    end
  end
end
