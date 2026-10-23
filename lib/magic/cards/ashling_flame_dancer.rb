module Magic
  module Cards
    AshlingFlameDancer = Creature("Ashling, Flame Dancer") do
      cost generic: 2, red: 2
      legendary_creature_type "Elemental Shaman"
      power 4
      toughness 4
    end

    class AshlingFlameDancer < Creature
      # "You don't lose unspent red mana as steps and phases end." The engine never empties the mana pool, so this
      # is already true.

      # "Magecraft — Whenever you cast or copy an instant or sorcery spell, discard a card, then draw a card. If this is
      # the second time this ability has resolved this turn, Ashling deals 2 damage to each opponent and each creature
      # they control. If it's the third time, add {R}{R}{R}{R}."
      class DiscardThenDraw < Magic::Choice::Discard
        def initialize(trigger:, **args)
          super(**args)
          @trigger = trigger
        end

        def resolve!(**)
          super
          @trigger.finish!
        end
      end

      class MagecraftTrigger < TriggeredAbility::SpellCast
        def should_perform?
          event.player == controller && (spell.instant? || spell.sorcery?)
        end

        def call
          if controller.hand.any?
            game.choices.add(DiscardThenDraw.new(player: controller, actor: actor, trigger: self))
          else
            finish!
          end
        end

        def finish!
          draw_card
          actor.trigger_once_this_turn!(self.class)
          times = actor.triggered_once_keys_this_turn.count(self.class)
          deal_magecraft_damage if times == 2
          controller.add_mana(red: 4) if times == 3
        end

        def deal_magecraft_damage
          opponents.each do |opponent|
            deal_damage(2, to: opponent)
            opponent.creatures.each { deal_damage(2, to: _1) }
          end
        end
      end

      def event_handlers
        { Events::SpellCast => MagecraftTrigger, Events::SpellCopied => MagecraftTrigger }
      end
    end
  end
end
