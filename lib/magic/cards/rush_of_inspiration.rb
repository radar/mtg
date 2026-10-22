module Magic
  module Cards
    # The land back face of Rush of Inspiration. It has no mana cost.
    CracklingFalls = Card("Crackling Falls") do
      type "Land"
    end

    class CracklingFalls < Card
      def enters_tapped? = true

      class ManaAbility < Magic::TapManaAbility
        choices :blue, :red
      end

      def activated_abilities = [ManaAbility]
    end

    RushOfInspiration = Instant("Rush of Inspiration") do
      cost generic: 1, blue_or_red: 2
      back_face CracklingFalls
    end

    class RushOfInspiration < Instant
      # "...discard a card at random unless you pay {E}{E}." Accepting pays; declining discards.
      class PayChoice < Magic::Choice::PayEnergy
        def decline!
          RushOfInspiration.discard_at_random(controller, except: actor)
        end
      end

      # The resolving spell is still in the hand zone, but it is on the stack, so it is not a card to discard.
      def self.discard_at_random(player, except:)
        card = player.hand.cards.to_a.reject { _1 == except }.sample
        card&.discard!
      end

      # Draw two cards. Then discard a card at random unless you pay {E}{E}.
      def resolve!
        draw_cards(2)
        choice = PayChoice.new(actor: self, amount: 2)
        if choice.can_pay?
          game.add_choice(choice)
        else
          self.class.discard_at_random(controller, except: self)
        end
      end
    end
  end
end
