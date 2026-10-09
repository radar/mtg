module Magic
  module Cards
    GandalfGoblinsBane = Creature("Gandalf, Goblins' Bane") do
      cost generic: 2, red: 1
      legendary_creature_type("Avatar Wizard")
      power 2
      toughness 3
    end

    class GandalfGoblinsBane < Creature
      # Flameshape {1}{R}, Sorcery -- Adventure: "Look at the top two cards of your library and exile them face down.
      # For as long as they remain exiled, you may play them if you control a Wizard."
      adventure generic: 1, red: 1

      def adventure_resolve!(**)
        controller.library.take(2).each do |card|
          trigger_effect(:exile, target: card)
          game.play_permissions.grant_while_exiled_if_controlling(card: card, player: controller, type: "Wizard")
        end
      end

      # "Whenever you cast a noncreature spell, Gandalf gets +1/+1 until end of turn and deals 1 damage to each
      # opponent."
      class NoncreatureSpellTrigger < TriggeredAbility::SpellCast
        def should_perform? = you? && !spell.creature?

        def call
          trigger_effect(:modify_power_toughness, target: actor, power: 1, toughness: 1, until_eot: true)
          opponents.each { |opponent| trigger_effect(:deal_damage, target: opponent, damage: 1) }
        end
      end

      def event_handlers = super.merge({ Events::SpellCast => NoncreatureSpellTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
