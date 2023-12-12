#= 
[9. Movie Genre Classification with Multi-Label Output](https://www.datacamp.com/blog/60-python-projects-for-all-levels-expertise)

[Netflix Genre Classification with LSTM](https://www.kaggle.com/code/hakanahmad/netflix-genre-classification-with-lstm)
 features : ["show_id", "type", "title", "director", "cast", "country", "date_added", "release_year", "rating", "duration", "listed_in", "description"]
=#
import GLMakie:stem!
using CSV, DataFrames, Pipe, JLSO
using MLJ
using TextAnalysis
import MLJ: fit!, transform, predict
using GLMakie
df = @pipe CSV.File("./data/netflix_titles.csv")|> DataFrame
#coerce!(df, :label => Multiclass)
rename!(df,:listed_in=>:genre)
#@pipe describe(df)|>_.nmissing

# 多流派分割后保留第一个 genre
transform!(df, :genre => ByRow(x -> @pipe split(x, ",")|>_[1])=>:genre)
df2=@pipe groupby(df,:genre)|>combine(_,nrow)|>rename(_,:nrow=>:counts)


"""
    plot_netflix_genre_freq(df::AbstractDataFrame)

绘制 netflix  genre barplot
"""
function plot_netflix_genre_freq(df::AbstractDataFrame)
    rows,_=size(df)
    fig=Figure(resolution=(800,900))
    ax=Axis(fig[1,1],title="summary of netflix  genre")
    ax.yticks=(1:rows,df.genre)
    #ax.xticklabelrotation = pi/2
    ax.xlabel="counts"
    ax.ylabel="genre"
    GLMakie.barplot!(ax,1:rows,df.counts;color = df.counts, strokecolor = :black, strokewidth = 1,direction=:x)
    GLMakie.hidedecorations!(ax,label = false, ticklabels = false, ticks = false)
    fig
end
#fig=plot_netflix_genre_freqe(df2)#;save("6-movie-genre-classification/summary-netflix-genre-barplot-2.png",fig)

main_genre = ["Dramas","Comedies","Documentaries","Action & Adventure","International TV Shows"]

main_df=@pipe filter(row -> (row.genre in main_genre), df)|>select(_,[:genre,:description])
#describe(main_df)|>d->d.nmissing

