module Magic
  module Cards
    IcewindElemental = Creature("Icewind Elemental") do
      cost generic: 4, blue: 1
      creature_type("Elemental")
      keywords :flying
      power 3
      toughness 4
    end

    class IcewindElemental < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:draw_card)
          game.choices.add(Magic::Choice::Discard.new(actor: actor, player: controller))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
