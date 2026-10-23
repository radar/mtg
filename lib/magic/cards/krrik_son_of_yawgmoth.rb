module Magic
  module Cards
    KrrikSonOfYawgmoth = Creature("K'rrik, Son of Yawgmoth") do
      cost generic: 4, black: 3
      legendary_creature_type "Phyrexian Horror Minion"
      power 2
      toughness 2
      keywords :lifelink
    end

    class KrrikSonOfYawgmoth < Creature
      # The three {B/P} symbols in its own cost: `Cast#pay_life_for_black(n)` pays n of them with 2 life each.
      def phyrexian_black = 3

      # "For each {B} in a cost, you may pay 2 life rather than pay that mana." Spells use `Cast#pay_life_for_black`, activated abilities
      # `ActivateAbility#pay_life_for_black`.
      class PayLifeForBlack < StaticAbility
        def may_pay_life_for_black?(_card, player) = player == controller
      end

      # "Whenever you cast a black spell, put a +1/+1 counter on K'rrik."
      class BlackSpellTrigger < TriggeredAbility::SpellCast
        def should_perform? = event.player == controller && spell.colors.include?(:black)

        def call = add_counter("+1/+1", to: actor)
      end

      def static_abilities = [PayLifeForBlack]

      def event_handlers = { Events::SpellCast => BlackSpellTrigger }
    end
  end
end
