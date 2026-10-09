module Magic
  module Cards
    GlinTheMighty = Creature("Glóin the Mighty") do
      cost generic: 3, red: 1
      legendary_creature_type("Dwarf Warrior")
      power 4
      toughness 3
    end

    class GlinTheMighty < Creature
      # Easy Pickings {2}{R}, Sorcery -- Adventure: "Easy Pickings deals 1 damage to each creature your opponents
      # control."
      adventure generic: 2, red: 1

      def adventure_resolve!(**)
        battlefield.not_controlled_by(controller).creatures.each do |creature|
          trigger_effect(:deal_damage, target: creature, damage: 1)
        end
      end

      # "At the beginning of your first main phase, add {R}{R}."
      class FirstMainTrigger < TriggeredAbility
        def should_perform? = event.active_player == controller

        def call
          controller.add_mana(red: 2)
        end
      end

      def event_handlers = super.merge({ Events::FirstMainPhase => FirstMainTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
