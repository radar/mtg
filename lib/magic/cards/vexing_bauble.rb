module Magic
  module Cards
    VexingBauble = Artifact("Vexing Bauble") do
      cost generic: 1
    end

    class VexingBauble < Artifact
      # "Whenever a player casts a spell, if no mana was spent to cast it, counter that spell."
      class FreeSpellTrigger < TriggeredAbility::SpellCast
        def should_perform?
          !mana_cost.respond_to?(:mana_spent) || mana_cost.mana_spent.values.sum.zero?
        end

        def call
          cast = game.stack.spells.find { _1.card == spell }
          counter_spell(cast) if cast
        end
      end

      # "{1}, {T}, Sacrifice this artifact: Draw a card."
      class DrawAbility < Magic::ActivatedAbility
        costs "{1}, {T}, Sacrifice {this}"

        def resolve!
          draw_cards(1)
        end
      end

      def activated_abilities = [DrawAbility]
      def event_handlers = { Events::SpellCast => FreeSpellTrigger }
    end
  end
end
