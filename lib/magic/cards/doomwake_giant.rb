module Magic
  module Cards
    class DoomwakeGiant < Creature
      card_name "Doomwake Giant"
      cost generic: 4, black: 1
      type T::Enchantment, T::Creature, T::Creatures["Giant"]
      power 4
      toughness 6

      class Trigger < TriggeredAbility
        def should_perform?
          # Whenever {this} or another enchantment enters under your control...
          this? || (actor.type?("Enchantment") && event.permanent.controller?(controller))
        end

        def call
          creatures_opponents_control.each do |creature|
            actor.trigger_effect(:modify_power_toughness, power: -1, toughness: -1, target: creature, until_eot: true)
          end
        end
      end

      def event_handlers
        {
          Events::EnteredTheBattlefield => Trigger
        }
      end
    end
  end
end
