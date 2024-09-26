function logger(msg::String)
    open("log/$FILENAME", "a") do f
        println(f, msg)
    end
end
