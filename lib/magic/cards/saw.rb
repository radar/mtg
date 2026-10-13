module Magic
  module Cards
    Saw = Equipment("Saw") do
      cost generic: 2
      equip [Costs::Mana.new(generic: 2)]
    end

    class Saw < Equipment
      class EquippedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 0
        applies_to_target
      end

      class SacrificeChoice < Magic::Choice::SacrificePermanent
        attr_reader :equipped

        def initialize(equipped:, **args)
          @equipped = equipped
          super(**args)
        end

        def candidates = chooser.permanents.reject { _1 == actor || _1 == equipped }

        def resolve!(sacrifice: nil)
          super
          draw_card
        end
      end

      # "Whenever equipped creature attacks, you may sacrifice a permanent other than that creature or this
      # Equipment. If you do, draw a card."
      class AttacksTrigger < TriggeredAbility
        def should_perform? = actor.attached_to && event.attacks.any? { _1.attacker == actor.attached_to }

        def call
          choice = SacrificeChoice.new(actor:, equipped: actor.attached_to)
          game.choices.add(choice) if choice.candidates.any?
        end
      end

      def static_abilities = [EquippedCreatureBuff]

      def event_handlers = super.merge({ Events::FinalAttackersDeclared => AttacksTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
