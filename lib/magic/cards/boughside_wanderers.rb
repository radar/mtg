module Magic
  module Cards
    BoughsideWanderers = Creature("Boughside Wanderers") do
      cost generic: 4, green: 2
      creature_type("Elf Scout")
      power 4
      toughness 4
    end

    class BoughsideWanderers < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::LookAtTopCards.new(actor: actor, amount: 4, filter: ->(card) { !card.any_type?("Instant", "Sorcery") }))
        end
      end

      def etb_triggers = [EntersTrigger]

      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform?
          you?
        end

        def call
          trigger_effect(:modify_power_toughness, target: actor, power: 2, toughness: 2)
        end
      end

      def event_handlers = super.merge({ Events::Landfall => LandfallTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
