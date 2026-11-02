module Magic
  module Cards
    BarrowBlade = Equipment("Barrow-Blade") do
      cost generic: 1
      equip [Costs::Mana.new(generic: 1)], sorcery_speed: true
    end

    class BarrowBlade < Equipment
      # "Equipped creature gets +1/+1."
      class Buff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        applies_to_target
      end

      def static_abilities = [Buff]

      # "Whenever equipped creature blocks or becomes blocked by a creature, that creature loses all abilities until
      # end of turn." Once for each blocker; "that creature" is the other creature in the event.
      class BlockTrigger < TriggeredAbility
        # Decided when the trigger fires, so the Blade leaving before resolution doesn't matter.
        def should_perform?
          equipped = actor.attached_to
          @other_creature = if equipped.nil?
            nil
          elsif event.attacker == equipped
            event.blocker
          elsif event.blocker == equipped
            event.attacker
          end
          !@other_creature.nil?
        end

        def call
          @other_creature.lose_all_abilities_until_eot! if @other_creature.zone
        end
      end

      def event_handlers = super.merge({ Events::CreatureBlocked => BlockTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
