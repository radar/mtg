module Magic
  module Cards
    # The land back face of Boggart Trawler. It has no mana cost.
    BoggartBog = Card("Boggart Bog") do
      type "Land"
    end

    class BoggartBog < Card
      # "As this land enters, you may pay 3 life. If you don't, it enters tapped."
      def shock_life = 3

      class ManaAbility < Magic::TapManaAbility
        choices :black
      end

      def activated_abilities = [ManaAbility]
    end

    BoggartTrawler = Creature("Boggart Trawler") do
      cost generic: 2, black: 1
      creature_type "Goblin"
      power 3
      toughness 1
      back_face BoggartBog
    end

    class BoggartTrawler < Creature
      # "Exile target player's graveyard."
      class ExileGraveyardChoice < Magic::Choice::Targeted
        def prompt = "Exile target player's graveyard."

        def choices = game.players

        def choice_amount = 1

        def resolve!(target:)
          target.graveyard.cards.to_a.each(&:exile!)
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.add_choice(ExileGraveyardChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
