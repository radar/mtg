module Magic
  module Cards
    RadagastTheBrown = Creature("Radagast the Brown") do
      cost generic: 2, green: 2
      legendary_creature_type("Avatar Wizard")
      power 2
      toughness 5
    end

    class RadagastTheBrown < Creature
      # "You may reveal a creature card that doesn't share a creature type with a creature you control from among
      # those cards and put it into your hand. Put the rest on the bottom of your library in a random order."
      class LookChoice < Magic::Choice::LookAtTopCards
        def decline! = resolve!(target: nil)
      end

      # "Whenever Radagast or another nontoken creature you control enters, look at the top X cards of your library,
      # where X is that creature's mana value."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          creature? && !event.permanent.token? && under_your_control?
        end

        def call
          amount = event.permanent.mana_value
          return unless amount.positive?

          # The creature types among the creatures you control as the trigger resolves.
          taken = controller.creatures.flat_map { _1.types & Types::Creatures.values }.uniq
          game.add_choice(
            LookChoice.new(
              actor: actor,
              amount: amount,
              filter: ->(card) { card.creature? && (card.types & taken).empty? }
            )
          )
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => EntersTrigger }
    end
  end
end
