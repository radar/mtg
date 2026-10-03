module Magic
  module Cards
    DrakusethMawOfFlames = Creature("Drakuseth, Maw of Flames") do
      cost generic: 4, red: 3
      legendary_creature_type("Dragon")
      keywords :flying
      power 7
      toughness 7
    end

    class DrakusethMawOfFlames < Creature
      # "Whenever Drakuseth attacks, it deals 4 damage to any target and 3 damage to each of up to two other
      # targets." The targets are chosen one after the other: the 4-damage target, then up to two others (each
      # skippable with `game.skip_choice!`), none the same as an earlier one.
      class DamageChoice < Magic::Choice::Targeted
        attr_reader :damage, :already_chosen, :remaining

        def initialize(actor:, damage: 4, already_chosen: [], remaining: 2)
          super(actor: actor)
          @damage = damage
          @already_chosen = already_chosen
          @remaining = remaining
        end

        def choices = game.any_target.reject { already_chosen.include?(_1) }

        # The first target is required; the other two are "up to".
        def choice_amount = already_chosen.empty? ? 1 : 0..1

        def resolve!(target:)
          trigger_effect(:deal_damage, target:, damage:)
          return if remaining.zero?

          follow_up = DamageChoice.new(actor:, damage: 3, already_chosen: [*already_chosen, target], remaining: remaining - 1)
          game.add_choice(follow_up) if follow_up.choices.any?
        end
      end

      class AttacksTrigger < TriggeredAbility
        def should_perform? = event.attacks.any? { _1.attacker == actor }

        def call = game.add_choice(DamageChoice.new(actor:))
      end

      def event_handlers = super.merge({ Events::FinalAttackersDeclared => AttacksTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
