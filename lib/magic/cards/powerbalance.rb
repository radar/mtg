module Magic
  module Cards
    Powerbalance = Enchantment("Powerbalance") do
      cost red: 2
    end

    class Powerbalance < Enchantment
      # The second "may": cast the revealed card for free.
      class MayCast < Magic::Choice::May
        def initialize(actor:, card:)
          @card = card
          super(actor: actor)
        end

        def prompt = "Cast #{@card.name} without paying its mana cost?"

        def resolve!
          return unless @card.zone == controller.library

          action = controller.prepare_cast(card: @card, by_effect: true)
          action.mana_cost = {}
          if @card.respond_to?(:target_choices) && !(@card.respond_to?(:multi_target?) && @card.multi_target?)
            choices = action.target_choices
            action.targeting(choices.first) if choices.any?
          end
          game.take_action(action)
        end
      end

      # "Whenever an opponent casts a spell, you may reveal the top card of your library."
      class MayReveal < Magic::Choice::May
        def initialize(actor:, mana_value:)
          @mana_value = mana_value
          super(actor: actor)
        end

        def prompt = "Reveal the top card of your library?"

        # "If you do, you may cast that card without paying its mana cost if the two spells have the same mana value."
        def resolve!
          top = controller.library.first
          return unless top

          reveal_cards [top]
          return if top.land? || top.mana_value != @mana_value

          game.choices.add(MayCast.new(actor: actor, card: top))
        end
      end

      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform? = event.player != controller

        def call
          game.choices.add(MayReveal.new(actor: actor, mana_value: spell_mana_value))
        end

        # CR 202.3e: on the stack, each {X} in the cost counts as the chosen value of X.
        def spell_mana_value
          printed = spell.cost.cost
          x_symbols = printed[:x] || 0
          printed.except(:x).values.sum + x_symbols * (event.x_value || 0)
        end
      end

      def event_handlers = { Events::SpellCast => SpellCastTrigger }
    end
  end
end
