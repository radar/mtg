module Magic
  module Cards
    OvikaEnigmaGoliath = Creature("Ovika, Enigma Goliath") do
      cost generic: 5, blue: 1, red: 1
      legendary_creature_type("Phyrexian Nightmare")
      keywords :flying
      ward generic: 3, life: 3
      power 6
      toughness 6
    end

    class OvikaEnigmaGoliath < Creature
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          you? && !spell.type?("Creature")
        end

        PhyrexianGoblinToken = Token.create "Phyrexian Goblin" do
          creature_type "Phyrexian Goblin"
          power 1
          toughness 1
          colors :red
        end

        def call
          Array(trigger_effect(:create_token, token_class: PhyrexianGoblinToken, amount: event.spell.mana_value)).each { |token| trigger_effect(:grant_keyword, target: token, keyword: :haste) }
        end
      end

      def event_handlers = super.merge({ Events::SpellCast => SpellCastTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
