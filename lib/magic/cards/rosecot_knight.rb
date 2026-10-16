module Magic
  module Cards
    RosecotKnight = Creature("Rosecot Knight") do
      cost generic: 4, white: 1
      creature_type "Human Knight"
      keywords :vigilance
      power 3
      toughness 4
    end

    class RosecotKnight < Creature
      # "You may reveal an artifact or enchantment card from among them and put it into your hand. Put the rest on the
      # bottom of your library in a random order. If you didn't put a card into your hand this way, put a +1/+1 counter
      # on this creature." Declining (`game.skip_choice!`) bottoms every card and adds the counter.
      class LookChoice < Magic::Choice::LookAtTopCards
        def resolve!(target: nil)
          super
          add_counter "+1/+1", to: actor unless target
        end

        def decline!
          resolve!
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          choice = LookChoice.new(actor: actor, amount: 6, filter: ->(card) { card.artifact? || card.enchantment? })
          # With nothing to take there is nothing to choose, but the cards still go to the bottom and the counter is added.
          choice.choices.empty? ? choice.resolve! : game.choices.add(choice)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
