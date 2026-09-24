# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Target creature you control becomes all colors until end of turn." / "~ becomes
      # red until end of turn." / "It becomes colorless until end of turn."
      class ChangeColors < Data.define(:who, :reference, :colors)
        include Effect

        COLORS = %w[white blue black red green].freeze
        COLOR = /(?:#{COLORS.join('|')})/
        LINE = /\A(?:(?<self>~)|#{PermanentTarget::REFERENCE}) becomes? (?<colors>all colors|colorless|#{COLOR}(?: and #{COLOR})?) until end of turn\.?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text))

          colors = case m[:colors].downcase
                   when "all colors" then COLORS
                   when "colorless" then []
                   else m[:colors].downcase.split(" and ")
                   end
          reference = PermanentTarget.reference(m) unless m[:self]
          new(who: m[:self] ? :self : :reference, reference:, colors: colors.map(&:to_sym))
        end

        def target_choices = reference&.choices
        def earlier_target? = !!reference&.earlier_target?
        def optional_target? = !!reference&.optional

        def resolve_call
          object = who == :self ? THIS : reference.object
          "#{object}.change_colors!(#{colors.inspect})"
        end
      end
    end
  end
end
