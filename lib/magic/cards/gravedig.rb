module Magic
  module Cards
    class Gravedig < Sorcery
      card_name "Gravedig"
      cost generic: 1, black: 1

      # Entwine {2}: paying it lets you choose both modes. Modeled like a kicker; the number of modes is
      # fixed as the spell is cast, so pay the entwine cost before choosing modes.
      kicker_cost generic: 2

      def modes_to_choose = kicker_cost.paid? ? 2 : 1

      ZombieToken = Token.create "Zombie" do
        creature_type "Zombie"
        power 2
        toughness 2
        colors :black
      end

      # Target player creates a 2/2 black Zombie creature token.
      class CreateZombie < Mode
        def target_choices = game.players

        def resolve!(target:)
          create_token(token: ZombieToken, controller: target)
          card.kicker_cost.reset! if card.kicker_cost.respond_to?(:reset!)
        end
      end

      # Return target creature card from your graveyard to your hand.
      class ReturnCreature < Mode
        def target_choices = (card.controller || card.owner).graveyard.creatures

        def resolve!(target:)
          target.move_to_hand!
        end
      end

      modes CreateZombie, ReturnCreature
    end
  end
end
