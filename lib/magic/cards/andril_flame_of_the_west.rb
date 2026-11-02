module Magic
  module Cards
    AndrilFlameOfTheWest = Equipment("Andúril, Flame of the West") do
      legendary_artifact
      cost generic: 3
      equip [Costs::Mana.new(generic: 2)], sorcery_speed: true
    end

    class AndrilFlameOfTheWest < Equipment
      SpiritToken = Token.create "Spirit" do
        creature_type "Spirit"
        power 1
        toughness 1
        colors :white
        keywords :flying
      end

      # "Equipped creature gets +3/+1."
      class Buff < Abilities::Static::PowerAndToughnessModification
        modify power: 3, toughness: 1
        applies_to_target
      end

      def static_abilities = [Buff]

      # "Whenever equipped creature attacks, create two tapped 1/1 white Spirit creature tokens with flying. If that
      # creature is legendary, instead create two of those tokens that are tapped and attacking." The creature comes from
      # the event and is remembered when the trigger is queued, so the tokens still appear if the Equipment leaves first.
      class AttackTrigger < TriggeredAbility
        def should_perform?
          return false unless event.attacker == actor.attached_to

          @legendary = event.attacker.legendary?
          @attack_target = event.target
          true
        end

        def call
          if @legendary
            create_token(token: SpiritToken, amount: 2, enters_tapped: true, attacking: true, attack_target: @attack_target)
          else
            create_token(token: SpiritToken, amount: 2, enters_tapped: true)
          end
        end
      end

      def event_handlers = super.merge({ Events::CreatureAttacked => AttackTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
