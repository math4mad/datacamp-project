## 1. load package
include("types.jl")
import MLJ:transform,predict,predict_mode,fit!
using GLMakie
using LinearAlgebra
using CSV, Random,DataFrames,Pipe,PrettyTables,TableTransforms



"""
    load_csv(str::String,drop=true)

加载 CSV 文件, 参数: name  , 是否丢弃缺失值数据
"""
function load_csv(str::String,drop=true)
    fetch(str) = str |> d -> CSV.File("./data/$str.csv") |> DataFrame 
    #to_ScienceType(d)=coerce(d,:Condition=>Multiclass)
    df =drop ? fetch(str)|> dropmissing : fetch(str)
    return df
end


"""
    boundary_data(df,;n=200)
    生成绘制决策边界的数据, 根据 df 的极值
    返回 grid 数据的tx,ty 范围和 x_test 数据
    x_test 用于生成预测结果
    示例:
```julia
    ypred=predict(svc, x_test)
    contourf(tx,ty,ypred)
```
    
TBW
"""
function boundary_data(df::AbstractDataFrame,;n::Int=200)
    
    n1=n2=n
    xlow,xhigh=extrema(df[:,1])
    ylow,yhigh=extrema(df[:,2])
    tx = range(xlow,xhigh; length=n1)
    ty = range(ylow,yhigh; length=n2)
    x_test = mapreduce(collect, hcat, Iterators.product(tx, ty));
    x_test=MLJ.table(x_test')
    return tx,ty, x_test
end

"""
    iris_label_transform(i)

iris 字符标签串数组转为数字标签
"""
function iris_label_transform(i)
    if i=="setosa"
        res=1
     elseif  i=="versicolor"
        res=2
     else
        res=3
     end
end

"""
    plot_pair_cor(df::AbstractDataFrame,save_imgs::Bool=false)
    两列 dataframe  plot cor
"""
function plot_pair_cor(df::AbstractDataFrame, save_imgs::Bool=false)
    name_arr = names(df)
    if length(name_arr) == 2
        fig = Figure()
        ax = Axis(fig[1, 1], title="$(name_arr[1])-$(name_arr[2])-Cor", xlabel="$(name_arr[1])", ylabel="$(name_arr[2])")
        Box(fig[1, 1], color=(:orange, 0.05))
        scatter!(ax, df[!, 1], df[!, 2], markersize=16, color=(:green, 0.1), strokewidth=3, strokecolor=:black)
        save_imgs && save("$(name_arr[1])_$(name_arr[2])_cor.png", fig)
        fig

    else
        @error "df must has two cols in pair plot"
    end

end
