module Magic
  module Cards
    PersistentMarshstalker = Creature("Persistent Marshstalker") do
      cost generic: 1, black: 1
      creature_type("Rat Berserker")
      power 3
      toughness 1
    end

    class PersistentMarshstalker < Creature
      # This creature gets +1/+0 for each other Rat you control.
      class RatBuff < Abilities::Static::PowerAndToughnessModification
        def applicable_targets = [source]

        def power_modification = (source.controller.creatures - [source]).count { _1.type?("Rat") }
      end

      def static_abilities = [RatBuff]

      # Threshold -- Whenever you attack with one or more Rats, if there are seven or more cards in your
      # graveyard, you may pay {2}{B}. If you do, return this card from your graveyard to the battlefield
      # tapped and attacking.
      class ReturnTrigger < TriggeredAbility::YouAttack
        def self.works_from_graveyard? = true

        class PayChoice < Magic::Choice::PayMana
          def resolve!(payment: nil)
            super
            card = actor
            return unless card.zone&.graveyard?

            permanent = Permanent.put_onto_battlefield(card: card, game: game, from_zone: card.zone, controller: controller, enters_tapped: true)
            game.current_turn.declare_attacker(permanent, target: game.opponents(controller).first) if permanent
          end
        end

        def should_perform?
          super && attackers.any? { _1.type?("Rat") } && actor.zone&.graveyard? && controller.graveyard.count >= 7
        end

        def call
          choice = PayChoice.new(actor: actor, mana: { generic: 2, black: 1 })
          game.choices.add(choice) if choice.can_pay?
        end
      end

      def event_handlers = super.merge(Events::FinalAttackersDeclared => ReturnTrigger)
    end
  end
end
