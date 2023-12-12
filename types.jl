"""
 mlj  example  description  struct 
 
 ref: link   
 name: dataset name
 model:  mlj model
 category:  learning method
 feature:  selected  X,y 
"""
Base.@kwdef struct  MLJTable
    ref::String
    name::AbstractString
    model
    catetory:: AbstractString
    feature::Vector{Union{AbstractString,Symbol}}
end