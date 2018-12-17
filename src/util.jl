using DataFrames

function length_no_missing(ar)
    length(collect(skipmissing(ar)))
end

function lshift(v)
    v = circshift(v, -1)
    v[length(v)] = 0
    return v
end

function dataframify(x...)
    DataFrame([x...])
end

function dropna(ar...)
    df = dataframify(ar...)
    cases = completecases(df)
    return df[cases, 1], df[cases, 2]  # TODO: expand this over the ...
end
