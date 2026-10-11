module Magic
  module Cards
    # The Duskmourn Overlords: Avatar Horror enchantment creatures with impending and a trigger for "whenever this
    # permanent enters or attacks".
    #
    #   class OverlordOfTheMistmoors < Overlord
    #     card_name "Overlord of the Mistmoors"
    #     cost generic: 5, white: 2
    #     impending 4, Costs::Mana.new(generic: 2, white: 2)
    #     power 6
    #     toughness 6
    #
    #     enters_or_attacks { trigger_effect(:draw_card) }
    #   end
    #
    # Cast it for its impending cost with `player.cast_as(:impending, card:)`. It isn't a creature while it has time
    # counters, so it can't attack until they are gone, but "enters" triggers as it comes in.
    class Overlord < Creature
      enchantment_creature_type("Avatar Horror")

      # The block is the trigger's `call` (run on the trigger, so `trigger_effect`, `game`, `actor` and `controller` work).
      def self.enters_or_attacks(&block)
        enters = Class.new(TriggeredAbility::EnterTheBattlefield) do
          def should_perform? = event.permanent == actor
        end
        attacks = Class.new(TriggeredAbility) do
          def should_perform? = event.attacks.any? { _1.attacker == actor }
        end
        enters.define_method(:call, &block)
        attacks.define_method(:call, &block)
        # Named, so a game holding a Permanent that uses these triggers can be Marshal-dumped.
        const_set(:EntersTrigger, enters)
        const_set(:AttacksTrigger, attacks)
        define_method(:etb_triggers) { [enters] }
        define_method(:event_handlers) { { Events::FinalAttackersDeclared => attacks } }
      end
    end
  end
end
