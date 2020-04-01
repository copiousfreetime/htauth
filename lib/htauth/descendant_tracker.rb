module HTAuth
  #
  # Use by either
  #
  #   class Foo
  #     extend DescendantTracker
  #   end
  #
  # or
  #
  #   class Foo
  #     class << self
  #       include DescendantTracker
  #     end
  #   end
  #
  # It will track all the classes that inherit from the extended class and keep
  # them in a Set that is available via the 'children' method.
  #
  module DescendantTracker
    def inherited( klass )
      return unless klass.instance_of?( Class )
      self.children << klass
    end

    #
    # The list of children that are registered
    #
    def children
      unless defined? @children
        @children = Array.new
      end
      return @children
    end

    #
    # find the child that returns truthy for then given method and
    # parameters
    #
    def find_child( method, *args )
      children.find do |child|
        child.send( method, *args )
      end
    end
  end
end
