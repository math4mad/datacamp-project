#= 

[2. Video game sales prediction](https://www.datacamp.com/blog/60-python-projects-for-all-levels-expertise)
[Video Game Sales](https://www.kaggle.com/datasets/gregorut/videogamesales)
[Video Game Sales](https://www.kaggle.com/datasets/gregorut/videogamesales/code?datasetId=284&sortBy=voteCount)

["Rank", "Name", "Platform", "Year", "Genre", "Publisher", "NA_Sales", "EU_Sales", "JP_Sales", "Other_Sales", "Global_Sales"]
=#

import MLJ:fit!,transform
using CSV,DataFrames,DataFramesMeta,PrettyTables,Query
using StatsBase,Pipe
using MLJ



df = @pipe CSV.File("./data/vgsales.csv")|> DataFrame|>dropmissing
#@pt first(df,10)
#coerce!(df,:Year=>Continuous)
#since2015=@subset(df, :Year.>2015)
#typeof(df.Year)



function transform_year(y)
    res=undef
    if  eltype(y)==String7
        res=parse(Unit32,y)
    elseif eltype(y)==Vector{UInt32}
        res=max(y...)
    else
        res=y
    end
    return y
end

#df.Year=@pipe transform_year.(df.Year)
#coerce!(df,:Year=>Continuous)
#since2015=@subset(df, :Year.>"2015")

#@transform df @byrow @passmissing :Year =transform_year() 
#res=(df.Year).|>Int32

df2=@pipe groupby(df,:Genre)|>combine(_,nrow)|>rename(_,:nrow=>:counts,:Genre=>:genre)

function plot_genre_freq(df::AbstractDataFrame)
    rows,_=size(df)
    featrues=names(df)
    fig=Figure(resolution=(500,600))
    ax=Axis(fig[1,1],title="summary of game")
    ax.yticks=(1:rows,df.genre)
    #ax.xticklabelrotation = pi/2
    ax.xlabel="counts"
    ax.ylabel="genre"
    GLMakie.barplot!(ax,1:rows,df.counts;color = df.counts, strokecolor = :black, strokewidth = 1,direction=:x)
    GLMakie.hidedecorations!(ax,label = false, ticklabels = false, ticks = false)
    fig
end

#@pipe plot_genre_freq(df2)|>save("9-video-game-sales-pred/video-game-sales-genre-barplot.png",_)

df3=@pipe groupby(df,:Year)|>combine(_,nrow)|>rename(_,:nrow=>:counts,:Year=>:year)|>sort(_,:counts;rev=true)

function plot_combine_count(df::AbstractDataFrame;title::String="summary of game ",cat::String="year")
    @assert names(df)[2]=="counts"
    rows=nrow(df)
    fig=Figure(resolution=(500,600))
    ax=Axis(fig[1,1],title="$(title) by $(cat)")
    ax.yticks=(1:rows,df[:,cat])
    #ax.xticklabelrotation = pi/2
    ax.xlabel="counts"
    ax.ylabel="$cat"
    GLMakie.barplot!(ax,1:rows,df.counts;color = df.counts, strokecolor = :black, strokewidth = 1,direction=:x)
    GLMakie.hidedecorations!(ax,label = false, ticklabels = false, ticks = false)
    fig
end

#@pipe plot_combine_count(df3;cat="year")|>save("9-video-game-sales-pred/video-game-sales-genre-barplot by year.png",_)

#|>rename(_,:nrow=>:counts,:Year=>:year,:Genre=>:genre)|>sort(_,:year;rev=true)|>first(_,5)
#df4=@pipe groupby(df,[:Year,:Genre])|>combine(_,nrow)|>rename(_,:nrow=>:counts,:Year=>:year,:Genre=>:genre)

df5=@pipe groupby(df,:Year)|>@combine(_,:global_sales=sum(:Global_Sales))|>sort(_,:Year;rev=true)
function plot_combine_globalsales(df::AbstractDataFrame)
    #@assert names(df)[2]=="counts"
    rows=nrow(df)
    fig=Figure(resolution=(500,600))
    ax=Axis(fig[1,1],title="video game global sales")
    ax.yticks=(1:rows,df[:,"Year"])
    #ax.xticklabelrotation = pi/2
    ax.xlabel="sales"
    ax.ylabel="year"
    GLMakie.barplot!(ax,1:rows,df.global_sales;color = df.global_sales, strokecolor = :black, strokewidth = 1,direction=:x)
    GLMakie.hidedecorations!(ax,label = false, ticklabels = false, ticks = false)
    fig
end
#@pipe plot_combine_globalsales(df5)|>save("9-video-game-sales-pred/video-game-globalsales-by-year.png",_)


## which is most release  genre in one year 
df6=@pipe groupby(df,[:Year,:Genre])|>combine(_,nrow=>:counts)|>groupby(_,:Year)

# for df in df6
#     d=sort(df,:counts;rev=true)
#     @info first(d)
# end

res6=mapreduce(x->(sort(x,:counts;rev=true)|>first|>copy),vcat, df6)|>DataFrame

function plot_single_most_release(df::AbstractDataFrame)
    #@assert names(df)[2]=="counts"
    rows=nrow(df)
    fig=Figure(resolution=(1000,900))
    ax=Axis(fig[1,1],title="video game most release in single year")
    ax.yticks=(1:rows,df[:,"Year"])
    #ax.xticklabelrotation = pi/2
    ax.xlabel="release"
    ax.ylabel="year"
    GLMakie.barplot!(ax,1:rows,df.counts;color = df.counts, strokecolor = :black, strokewidth = 1,direction=:x
    
    )
    for (idx, row) in enumerate(eachrow(df))
        counts,year,genre=row.counts,row.Year,row.Genre
        GLMakie.text!(ax,counts+2,idx; text="$genre-$year",align = (:left, :center),fontsize=8)
    end
    
    GLMakie.hidedecorations!(ax,label = false, ticklabels = false, ticks = false)
    fig
end
#@pipe plot_single_most_release(res6)|>save("9-video-game-sales-pred/video-game-single-year-most-release-game.png",_)


##  Which genre game has sold the most in a single year


#df7=@pipe select(df,[:Year,:Genre,:Global_Sales])|>groupby(_,[:Year,:Genre])

#res7=@pipe mapreduce(x->(sort(x,:Global_Sales;rev=true)|>first|>copy),vcat, df7)|>DataFrame|>sort(_,:Global_Sales;rev=true)

#df7=@pipe groupby(df,[:Year,:Genre])|>@combine(_,:gs=sum(:Global_Sales))|>groupby(_,[:Year])|>@combine(_,:gs=maximum(:gs))

# 7. Which genre game have the highest sale price globally

df8=@pipe groupby(df,[:Genre])|>@combine(_,:sales=sum(:Global_Sales))|>sort(_,:sales;rev=true)
function plot_globalsales_genre(df::AbstractDataFrame)
    #@assert names(df)[2]=="counts"
    rows=nrow(df)
    fig=Figure(resolution=(800,500))
    ax=Axis(fig[1,1],title="video game sales by genre")
    ax.yticks=(1:rows,df[:,"Genre"])
    #ax.xticklabelrotation = pi/2
    ax.xlabel="sales"
    ax.ylabel="genre"
    GLMakie.barplot!(ax,1:rows,df.sales;color = df.sales, strokecolor = :black, strokewidth = 1,direction=:x,
    bar_labels=:y )
    GLMakie.hidedecorations!(ax,label = false, ticklabels = false, ticks = false)
    fig
end
#@pipe plot_globalsales_genre(df8)|>save("9-video-game-sales-pred/video-game-sales-by-genre.png",_)


# 8. Which platfrom have the highest sale price globally
df9=@pipe groupby(df,["Platform"])|>@combine(_,:sales=sum(:Global_Sales))|>sort(_,:sales;rev=true)
function plot_globalsales_platform(df::AbstractDataFrame)
    #@assert names(df)[2]=="counts"
    rows=nrow(df)
    fig=Figure(resolution=(800,500))
    ax=Axis(fig[1,1],title="video game sales by Platform")
    ax.yticks=(1:rows,df[:,"Platform"])
    #ax.xticklabelrotation = pi/2
    ax.xlabel="sales"
    ax.ylabel="platform"
    GLMakie.barplot!(ax,1:rows,df.sales;color = df.sales, strokecolor = :black, strokewidth = 1,direction=:x,
    bar_labels=:y )
    GLMakie.hidedecorations!(ax,label = false, ticklabels = false, ticks = false)
    fig
end
#@pipe plot_globalsales_platform(df9)|>save("9-video-game-sales-pred/video-game-sales-by-platform.png",_)


# Which individual game have the highest sale price globally?

df10=@pipe sort(df,:Global_Sales;rev=true)|>select(_,["Name","Year","Global_Sales"])|>_[1:20,:]

function plot_top20_game(df::AbstractDataFrame)
    #@assert names(df)[2]=="counts"
    rows=nrow(df)
    fig=Figure(resolution=(800,500))
    ax=Axis(fig[1,1],title="video game sales by single game")
    ax.yticks=(1:rows,df[:,"Name"])
    #ax.xticklabelrotation = pi/2
    ax.xlabel="sales"
    ax.ylabel="name"
    GLMakie.barplot!(ax,1:rows,df.Global_Sales;color = df.Global_Sales, strokecolor = :black, strokewidth = 1,direction=:x)
    for (idx, row) in enumerate(eachrow(df))
        name,year,sales=row.Name,row.Year,row.Global_Sales
        GLMakie.text!(ax,sales+2,idx; text="$year-$sales",align = (:left, :center),fontsize=8)
    end
    GLMakie.hidedecorations!(ax,label = false, ticklabels = false, ticks = false)
    fig
end
#@pipe plot_top20_game(df10)|>save("9-video-game-sales-pred/video-game-sales-by-single.png",_)

#  10. Sales compearison by genre

df11=@pipe select(df,[:Genre,:NA_Sales,:EU_Sales,:JP_Sales,:Other_Sales])|>groupby(_,:Genre)|>@combine(_,$AsTable = (na_sales = sum(:NA_Sales), eu_sales = sum(:EU_Sales),jp_sales=sum(:JP_Sales),other_sales=sum(:Other_Sales)))

function plot_heatmap(df::AbstractDataFrame)
    genre=df.Genre
    data=@pipe select(df,Not(:Genre))
    row,col=size(data)
    ma=@pipe Matrix(data)|>round.(_,digits=1)
    fig=Figure(resolution=(1000,400))
    ax=Axis(fig[1,1],title="video game sales heatmap")
    ax.yticks=(1:col,names(data))
    ax.xticks=(1:row,genre)
    heatmap!(ax,ma)
    [GLMakie.text!(ax,i,j;text="$(ma[i,j])",align = (:center, :center),fontsize=12,color=:white) for i in 1:row,j in 1:col]

    fig
end
#@pipe plot_heatmap(df11)|>save("9-video-game-sales-pred/video-game-sales-heamap.png",_)

res12=@pipe df11|>select(_,Not(:Genre))|>Matrix|>permutedims|>reshape(_,(48,1))|>_[:,1]
cats=@pipe df11|>select(_,Not(:Genre))|>names
type_name=df11.Genre
grp=repeat(1:4, 12)
grp_x=repeat(1:12,inner=4)
colors = cgrad(:tab10)
function plot_genre_dodge()
    fig=Figure(resolution=(1000,600))
    ax=Axis(fig[1,1],title="video game sales dodge")
    ax.xticks=(1:12,type_name)
    GLMakie.barplot!(ax,grp_x,res12; dodge =grp,color=colors[grp],strokecolor = :black, strokewidth = 1,bar_labels = :y,label_rotation=1/2*pi)
    labels = ["$i" for i in cats]
    elements = [PolyElement(polycolor = colors[i]) for (i,c) in enumerate(cats)]
   Legend(fig[1,2], elements, labels, "sales region", orientation=:vertical, tellwidth = true, tellheight =false)
    fig
end

#@pipe plot_genre_dodge()|>save("9-video-game-sales-pred/video-game-sales-compearison-by-genre.png",_)

# 12. Top 20 Publisher

#df13=@pipe groupby(df,[:Publisher])|>@combine(_)
# x = df |>
#     @groupby(_.Publisher) |>
#     @map({Key=key(_), counts=length(_)}) |>
#     DataFrame

#df13=@pipe groupby(df,[:Publisher])|>@combine(_,:games=length(:Year))|>groupby(_,:Publisher)

# 13. Top global sales by publisher

df14=@pipe groupby(df,[:Publisher])|>@combine(_,:sales=sum(:Global_Sales))|>sort(_,:sales;rev=true)|>first(_,20)|>copy|>DataFrame

function plot_top20_publisher(df::AbstractDataFrame)
    #@assert names(df)[2]=="counts"
    rows=nrow(df)
    fig=Figure(resolution=(800,500))
    ax=Axis(fig[1,1],title="video game sales by publisher",yreversed=true)
    ax.yticks=(1:rows,df[:,"Publisher"])
    #ax.xticklabelrotation = pi/2
    ax.xlabel="sales"
    ax.ylabel="pubhisher"
    GLMakie.barplot!(ax,1:rows,df.sales;color = df.sales, strokecolor = :black, strokewidth = 1,direction=:x)
    for (idx, row) in enumerate(eachrow(df))
        sales=round(row.sales,digits=2)
        GLMakie.text!(ax,sales+2,idx; text="$(sales)",align = (:left, :center),fontsize=8)
    end
    GLMakie.hidedecorations!(ax,label = false, ticklabels = false, ticks = false)
    fig
end
#@pipe plot_top20_publisher(df14)|>save("9-video-game-sales-pred/video-game-sales-top20-publisher.png",_)

#  14. publisher comperison
features=["Publisher", "NA_Sales", "EU_Sales", "JP_Sales", "Other_Sales","Global_Sales"]
#df15=@pipe select(df,features)|>groupby(_,:Publisher)|>@combine(_,n1=sum(:Global_Sales))

# 16. Total revenue by region
#,"Global_Sales"
# df7=@pipe select(df,["NA_Sales", "EU_Sales", "JP_Sales", "Other_Sales"])|>@combine(_, $AsTable = (na_sales = sum(:NA_Sales),eu_sales = sum(:EU_Sales),jp_sales=sum(:JP_Sales),other_sales=sum(:Other_Sales)))
df17=@pipe select(df,["NA_Sales", "EU_Sales", "JP_Sales", "Other_Sales"])|>@combine(_, :sales=sum.(eachcol(_)))
df17.cat=["NA_Sales", "EU_Sales", "JP_Sales", "Other_Sales"]
function plot_sales_by_region(df::AbstractDataFrame)
    #@assert names(df)[2]=="counts"
    rows=nrow(df)
    fig=Figure(resolution=(500,500))
    ax=Axis(fig[1,1],title="video game sales by region")
    ax.xticks=(1:rows,df[:,"cat"])
    #ax.xticklabelrotation = pi/2
    ax.xlabel="region"
    ax.ylabel="salse"
    GLMakie.barplot!(ax,1:rows,df.sales;color = df.sales, strokecolor = :black, strokewidth = 1)
    # for (idx, row) in enumerate(eachrow(df))
    #     sales=round(row.sales,digits=2)
    #     GLMakie.text!(ax,sales+2,idx; text="$(sales)",align = (:left, :center),fontsize=8)
    # end
    GLMakie.hidedecorations!(ax,label = false, ticklabels = false, ticks = false)
    fig
end

function plot_sales_by_region_pie(df::AbstractDataFrame)
    
    colors = [:yellow,:red, :purple, :green]
    fig=Figure(resolution=(500,500))
    ax=Axis(fig[1,1];title="video game sales by region",autolimitaspect = 1)
    GLMakie.pie!(ax, df.sales;color=colors,radius=4,inner_radius = 2,
    strokecolor = :white,
    strokewidth = 5)
    labels = ["$i" for i in df.cat]
    elements = [PolyElement(polycolor = colors[i]) for (i,c) in enumerate(df.cat)]
    Legend(fig[1,2], elements, labels, "sales region", orientation=:vertical, tellwidth = true, tellheight =false)
    GLMakie.hidedecorations!(ax,label = false)
    fig
end

#@pipe plot_sales_by_region(df17)|>save("9-video-game-sales-pred/video-game-sales-by-region.png",_)
#@pipe plot_sales_by_region_pie(df17)|>save("9-video-game-sales-pred/video-game-sales-by-region-pie.png",_)

##  17. Sales Histogram
f=log
df18=@pipe select(df,["NA_Sales", "EU_Sales", "JP_Sales", "Other_Sales","Global_Sales"])
log_df18=@pipe @transform(df18,:na_sales=f.(:NA_Sales),:eu_sales=f.(:EU_Sales),:jp_sales=f.(:JP_Sales),
 :other_sales=f.(:Other_Sales),:global_sales=f.(:Global_Sales)
)|>select(_,[:na_sales,:eu_sales,:jp_sales,:other_sales,:global_sales])

function plot_hist(df::AbstractDataFrame)
    cats=names(df)
    fig=Figure(resolution=(600,600))
    for (idx, col) in enumerate(eachcol(df))
        local ax=Axis(fig[fldmod1(idx,2)...],title=cats[idx])
        data=@pipe filter(x->x!=0,col)|>f.(_)
        GLMakie.hist!(ax,data, color = :red, strokewidth = 1, strokecolor = :black,label=cats[idx],normalization =:pdf)
        density!(ax, data; color = (:green, 0.4), label = "density", strokewidth = 1,npoints = 15)
        
    end
    
    fig
end
#@pipe plot_hist(df18)|>save("9-video-game-sales-pred/video-game-sales-histogram.png",_)

