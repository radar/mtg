module Magic
  module Cards
    RefurbishedFamiliar = Creature("Refurbished Familiar") do
      cost generic: 3, black: 1
      type T::Artifact, T::Creature, *creature_types("Zombie Rat")
      power 2
      toughness 1
      keywords :flying
    end

    class RefurbishedFamiliar < Creature
      # "Affinity for artifacts": costs {1} less for each artifact you control.
      def self_mana_cost_adjustment
        buyer = controller || owner
        { generic: -> { -buyer.permanents.artifacts.count } }
      end

      # "When this creature enters, each opponent discards a card. For each opponent who can't, you draw a card."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.opponents(controller).each do |opponent|
            if opponent.hand.any?
              game.add_choice(Magic::Choice::Discard.new(actor: actor, player: opponent))
            else
              draw_cards(1)
            end
          end
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
