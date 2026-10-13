module Magic
  module Cards
    HugsGrislyGuardian = Creature("Hugs, Grisly Guardian") do
      legendary_creature_type "Badger Warrior"
      cost x: 1, red: 2, green: 2
      keywords :trample
      power 5
      toughness 5
    end

    class HugsGrislyGuardian < Creature
      # You may play an additional land on each of your turns.
      def additional_lands_per_turn = 1

      # When Hugs enters, exile the top X cards of your library. Until the end of your next turn, you may play
      # those cards.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          x = actor.mana_spent.values.sum - 4
          controller.library.first([x, 0].max).each do |card|
            exile_target(card)
            game.play_permissions.grant_until_end_of_next_turn(card: card, player: controller)
          end
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
