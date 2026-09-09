module Magic
  module Cards
    OmnathLocusOfRage = Creature("Omnath, Locus of Rage") do
      legendary_creature_type "Elemental"
      cost generic: 3, red: 2, green: 2
      power 5
      toughness 5
    end

    class OmnathLocusOfRage < Creature
      ElementalToken = Token.create("Elemental") do
        creature_type "Elemental"
        power 5
        toughness 5
        colors :red, :green
      end

      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform?
          event.player == controller
        end

        def call
          actor.create_token(token_class: ElementalToken)
        end
      end

      class DeathChoice < Magic::Choice::Targeted
        def choices
          game.any_target
        end

        def resolve!(target:)
          actor.trigger_effect(:deal_damage, target: target, damage: 3)
        end
      end

      class ElementalDiedTrigger < TriggeredAbility
        def should_perform?
          event.permanent.controller == controller && event.permanent.any_type?(T::Creature, T::Creatures["Elemental"])
        end

        def call
          game.add_choice(DeathChoice.new(actor: actor))
        end
      end

      def event_handlers
        {
          Events::Landfall => LandfallTrigger,
          Events::CreatureDied => ElementalDiedTrigger,
        }
      end
    end
  end
end