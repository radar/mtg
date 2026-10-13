module Magic
  module Cards
    SmaugWickedWorm = Creature("Smaug, Wicked Worm") do
      cost generic: 3, black: 1, red: 1
      legendary_creature_type "Dragon"
      keywords :flying
      power 5
      toughness 5
    end

    class SmaugWickedWorm < Creature
      # "When Smaug enters, create X tapped Treasure tokens, where X is the number of artifacts your opponents control."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          count = battlefield.artifacts.not_controlled_by(controller).count
          create_token(token:Tokens::Treasure, amount: count, enters_tapped: true) if count.positive?
        end
      end

      def etb_triggers = [EntersTrigger]

      # "Whenever you cast a spell, if mana from a Treasure was spent to cast it, you draw a card and lose 1 life."
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform? = you? && spell.treasure_mana_spent?

        def call
          draw_card
          lose_life(controller, 1)
        end
      end

      def event_handlers = super.merge({ Events::SpellCast => SpellCastTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
