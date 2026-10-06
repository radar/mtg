module Magic
  module Cards
    MaleficScythe = Equipment("Malefic Scythe") do
      cost generic: 1, black: 1
      equip [Costs::Mana.new(generic: 1)]
    end

    class MaleficScythe < Equipment
      # "This Equipment enters with a soul counter on it."
      enters_with_counters "soul", 1

      # "Equipped creature gets +1/+1 for each soul counter on this Equipment."
      class SoulBuff < Abilities::Static::PowerAndToughnessModification
        applies_to_target

        def power_modification = @source.counters.of_type(Counters::Soul).count
        alias_method :toughness_modification, :power_modification
      end

      def static_abilities = [SoulBuff]

      # "Whenever equipped creature dies, put a soul counter on this Equipment."
      class EquippedCreatureDiesTrigger < TriggeredAbility
        def should_perform? = event.permanent == actor.attached_to

        def call
          trigger_effect(:add_counter, target: actor, counter_type: "soul", amount: 1)
        end
      end

      def event_handlers = { Events::CreatureDied => EquippedCreatureDiesTrigger }
    end
  end
end
