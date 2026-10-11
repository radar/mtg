module Magic
  class Choice
    # "...manifest dread, then attach this Equipment to that creature." The actor is the Equipment; `perform` attaches it to
    # whatever face-down creature that makes (nothing, with an empty library).
    class ManifestDreadAndAttach < ManifestDread
      def manifested(permanent)
        actor.attach_to!(permanent)
      end
    end
  end
end
