# frozen_string_literal: true

module HTAuth
  # Internal: base class from which all entries are derived
  class Entry
    # Internal: return a new instance of this entry
    def dup
      self.class.from_line(to_s)
    end
  end
end
