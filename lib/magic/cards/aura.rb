module Magic
  module Cards
    class Aura < Attachment
      TYPE_LINE = "Enchantment -- Aura"

      # Declares what the Aura can enchant (rule 303.4a), matching the "Enchant ..." line of the
      # Oracle text: `enchant "Creature"`, `enchant "Creature", you_control: true`, `enchant :player`
      # or `enchant :permanent`. This is separate from `target_choices`, which is only about what
      # can be targeted while casting (and in this engine sometimes filters more tightly, e.g.
      # "tapped" or "you control", than the Oracle text does).
      #
      # State-based actions re-check it (rule 704.5m). An Aura that doesn't declare a
      # restriction is treated as able to enchant anything.
      def self.enchant(type, you_control: false)
        define_method(:can_enchant?) do |host, aura:|
          next false if you_control && host.controller != aura.controller

          case type
          when :player then host.player?
          when :permanent then host.respond_to?(:permanent?) && host.permanent?
          else host.respond_to?(:type?) && host.type?(type)
          end
        end
      end

      def can_enchant?(_host, aura:)
        true
      end
    end
  end
end
