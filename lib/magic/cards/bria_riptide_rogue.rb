module Magic
  module Cards
    BriaRiptideRogue = Creature("Bria, Riptide Rogue") do
      legendary_creature_type "Otter Rogue"
      cost generic: 2, blue: 1, red: 1
      keywords :prowess
      power 3
      toughness 3
    end

    class BriaRiptideRogue < Creature
      # Other creatures you control have prowess: each noncreature spell you cast gives them +1/+1 until end of turn.
      class OtherCreaturesProwess < TriggeredAbility::SpellCast
        def should_perform? = event.player == controller && !spell.creature?

        def call
          (battlefield.controlled_by(controller).creatures - [actor]).each do |creature|
            trigger_effect(:modify_power_toughness, power: 1, toughness: 1, target: creature, until_eot: true)
          end
        end
      end

      # Whenever you cast a noncreature spell, target creature you control can't be blocked this turn.
      class UnblockableTrigger < TriggeredAbility::SpellCast
        class UnblockableChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures

          def choice_amount = 1

          def resolve!(target:)
            target.cant_be_blocked_this_turn!
          end
        end

        def should_perform? = event.player == controller && !spell.creature?

        def call
          game.add_choice(UnblockableChoice.new(actor: actor))
        end
      end

      def event_handlers
        handlers = super
        handlers.merge(Events::SpellCast => [*handlers[Events::SpellCast], OtherCreaturesProwess, UnblockableTrigger])
      end
    end
  end
end
