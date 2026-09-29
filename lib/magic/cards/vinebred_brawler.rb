module Magic
  module Cards
    class VinebredBrawler < Creature
      card_name "Vinebred Brawler"
      cost generic: 2, green: 1
      creature_type "Elf Berserker"
      power 4
      toughness 2

      # "This creature must be blocked if able."
      def must_be_blocked? = true

      class PumpChoice < Magic::Choice::Targeted
        def choices = controller.creatures.by_type("Elf").except(actor)

        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:modify_power_toughness, target:, power: 2, toughness: 1)
        end
      end

      # "Whenever this creature attacks, another target Elf you control gets +2/+1 until end of turn."
      class AttacksTrigger < TriggeredAbility
        def should_perform? = event.attacker == actor

        def call
          choice = PumpChoice.new(actor:)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::CreatureAttacked => AttacksTrigger }
    end
  end
end
