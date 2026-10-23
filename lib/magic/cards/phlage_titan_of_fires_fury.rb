module Magic
  module Cards
    class PhlageTitanOfFiresFury < Creature
      card_name "Phlage, Titan of Fire's Fury"
      cost "{1}{R}{W}"
      legendary_creature_type "Elder Giant"
      power 6
      toughness 6

      # Escape—{R}{R}{W}{W}, Exile five other cards from your graveyard.
      def escape_cost = Costs::Mana.new(red: 2, white: 2)
      def escape_exile_valid?(cards) = cards.size == 5

      # "it deals 3 damage to any target and you gain 3 life"
      class DamageChoice < Choice::Targeted
        def choice_amount = 1
        def target_choices = game.any_target

        def resolve!(target:)
          deal_damage(3, to: target)
          gain_life 3
        end
      end

      # "When Phlage enters, sacrifice it unless it escaped."
      class SacrificeTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          sacrifice actor unless actor.card.escaped?
        end
      end

      class EntersDamageTrigger < TriggeredAbility::EnterTheBattlefield
        def call = game.choices.add(DamageChoice.new(actor: actor))
      end

      class AttackDamageTrigger < TriggeredAbility
        def should_perform? = event.attacker == actor
        def call = game.choices.add(DamageChoice.new(actor: actor))
      end

      def etb_triggers = [SacrificeTrigger, EntersDamageTrigger]

      def event_handlers
        super.merge(Events::CreatureAttacked => AttackDamageTrigger)
      end
    end
  end
end
