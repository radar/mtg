module Magic
  module Cards
    ThranduilTheElvenking = Creature("Thranduil, the Elvenking") do
      cost "{2}{B}{G}{U}"
      legendary_creature_type "Elf Noble"
      power 5
      toughness 6
    end

    class ThranduilTheElvenking < Creature
      # "Thranduil has all activated abilities of all Elf cards in your graveyard."
      class GrantGraveyardElfAbilities < Abilities::Static::GrantActivatedAbilities
        def applies_to?(permanent)
          permanent == @source && elf_cards.any?
        end

        def granted_abilities
          elf_cards.flat_map(&:activated_abilities)
        end

        private

        def elf_cards
          controller.graveyard.cards.select { _1.type?("Elf") }
        end
      end

      def static_abilities = [GrantGraveyardElfAbilities]

      # "Whenever another legendary Elf you control enters, draw two cards, then discard a card."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent != actor && event.permanent.controller == controller && event.permanent.legendary? &&
            event.permanent.type?("Elf")
        end

        def call
          trigger_effect(:draw_cards, number_to_draw: 2)
          game.add_choice(Magic::Choice::Discard.new(actor: actor, player: controller))
        end
      end

      def event_handlers = super.merge({ Events::EnteredTheBattlefield => EntersTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
