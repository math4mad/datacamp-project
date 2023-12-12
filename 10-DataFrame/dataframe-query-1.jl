#= 
  based on video game sales  csv 

=#

using DataFrames,CSV,Query,Pipe 

df = @pipe CSV.File("./data/vgsales.csv")|> DataFrame|>dropmissing

## 1 count
platform_counts= df |>
    @groupby(_.Platform) |>
    @map({Key=key(_), Count=length(_)}) |>
    DataFrame

year_counts=df |>
@groupby(_.Year) |>
@map({Key=key(_), Count=length(_)})|>DataFrame|>@orderby_descending(_.Count)

platform_sales=df |>
@groupby(_.Platform) |>
@map({Key=key(_), Sum=sum(_.Global_Sales)})|>DataFrame|>@orderby_descending(_.Sum)
