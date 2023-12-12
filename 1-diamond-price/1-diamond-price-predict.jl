#= 
[Diamond Price prediction using Regression (98,2%)](https://www.kaggle.com/code/wahyuikbalmaulana/diamond-price-prediction-using-regression-98-2)
=#

include("../utils.jl")
using GLM
df=load_csv("diamonds")

#@pt describe(df)
#= 
┌──────────┬─────────────────────┬──────┬─────────────────────┬───────────┬──────────┬──────────┐
│ variable │                mean │  min │              median │       max │ nmissing │   eltype │
│   Symbol │ U{Nothing, Float64} │  Any │ U{Nothing, Float64} │       Any │    Int64 │ DataType │
├──────────┼─────────────────────┼──────┼─────────────────────┼───────────┼──────────┼──────────┤
│  Column1 │             26970.5 │    1 │             26970.5 │     53940 │        0 │    Int64 │
│    carat │             0.79794 │  0.2 │                 0.7 │      5.01 │        0 │  Float64 │
│      cut │             nothing │ Fair │             nothing │ Very Good │        0 │ String15 │
│    color │             nothing │    D │             nothing │         J │        0 │  String1 │
│  clarity │             nothing │   I1 │             nothing │      VVS2 │        0 │  String7 │
│    depth │             61.7494 │ 43.0 │                61.8 │      79.0 │        0 │  Float64 │
│    table │             57.4572 │ 43.0 │                57.0 │      95.0 │        0 │  Float64 │
│    price │              3932.8 │  326 │              2401.0 │     18823 │        0 │    Int64 │
│        x │             5.73116 │  0.0 │                 5.7 │     10.74 │        0 │  Float64 │
│        y │             5.73453 │  0.0 │                5.71 │      58.9 │        0 │  Float64 │
│        z │             3.53873 │  0.0 │                3.53 │      31.8 │        0 │  Float64 │
└──────────┴─────────────────────┴──────┴─────────────────────┴───────────┴──────────┴──────────┘
=#

## coe

data= coerce(df, :cut=>Multiclass,
                 :clarity=>Multiclass,
                 :color=>Multiclass,
                 :carat=>MLJ.Continuous,
                 :depth=>MLJ.Continuous,
                 :table=>MLJ.Continuous,
                 :x=>MLJ.Continuous,
                 :y=>MLJ.Continuous,
                 :z=>MLJ.Continuous
                
            )

# delete  duplicate rows 
#@pipe  unique!(data)|>allunique

res1=lm(@formula(price ~cut+clarity+color+carat), data)
res2=lm(@formula(log(price) ~cut+clarity+color+log(carat)), data)


#residuals(res2)|>stem


function  pair_data_analysis()
    pair_df1=select(df,[:carat,:price])
    #plot_pair_cor(pair_df)
    DataFrames.transform!(df,:carat=>ByRow(x->log(x))=>:log_carat)
    DataFrames.transform!(df,:price=>ByRow(x->log(x))=>:log_price)

    pair_df2=pair_df1=select(df,[:log_carat,:log_price])
    plot_pair_cor(pair_df2,true)
end









