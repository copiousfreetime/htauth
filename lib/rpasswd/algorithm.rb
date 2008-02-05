module Rpasswd
    # base class all the Passwd algorithms derive from
    class Algorithm
        def name ; end
        def prefix ; end
        def encode(password) ; end
    end
end
