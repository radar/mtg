module Magic
  module Cards
    class SpikedCorridorTorturePit < Room
      DevilToken = Token.create "Devil" do
        creature_type "Devil"
        colors :red
        power 1
        toughness 1
      end

      class DevilToken
        class DamageChoice < Magic::Choice::Targeted
          def prompt = "Choose any target. #{actor.name} deals 1 damage to it."

          def choices = game.players + battlefield.creatures.to_a + battlefield.planeswalkers.to_a

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:deal_damage, source: actor, target: target, damage: 1)
          end
        end

        # "When this token dies, it deals 1 damage to any target."
        class DiesTrigger < TriggeredAbility::Death
          def call
            game.add_choice(DamageChoice.new(actor: actor))
          end
        end

        def death_triggers = [DiesTrigger]
      end

      class SpikedCorridor < Room::Door
        card_name "Spiked Corridor"
        cost generic: 3, red: 1

        # "When you unlock this door, create three 1/1 red Devil creature tokens with 'When this token dies, it deals 1 damage
        # to any target.'"
        when_unlocked do
          3.times { trigger_effect(:create_token, token_class: SpikedCorridorTorturePit::DevilToken) }
        end
      end

      class TorturePit < Room::Door
        card_name "Torture Pit"
        cost generic: 3, red: 1

        # "If a source you control would deal noncombat damage to an opponent, it deals that much damage plus 2 instead."
        class ExtraDamage < ReplacementEffect::DamageDoubler
          def recipient_applies?(target) = target.is_a?(Magic::Player) && receiver.game.opponents(receiver.controller).include?(target)

          def call(effect)
            effect.with_damage(effect.damage + 2)
          end
        end

        def replacement_effects = { Effects::DealDamage => ExtraDamage }
      end

      doors SpikedCorridor, TorturePit
    end
  end
end
