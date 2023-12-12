
#= 
  features=["rank", "name", "platform", "year", "genre", "publisher", "na_sales", "eu_sales", "jp_sales", "other_sales", "global_sales"]
=#
using CSV,Tidier,Pipe
using DataFrames


df = @pipe CSV.File("./data/vgsales.csv")|> DataFrame
@pipe names(df)|>lowercase.(_)|>rename!(df,_)
features=["rank", "name", "platform", "year", "genre", "publisher", "na_sales", "eu_sales", "jp_sales", "other_sales", "global_sales"]

# 3.1 What genre games have been made the most?
#df1=@pipe groupby(df,:genre)|>combine(_,nrow)|>rename(_,:nrow=>:counts)
df1=@chain df begin
    @group_by(genre)
    @summarize(counts =nrow())
    @arrange(desc(counts))
end

# 3.2 Which year had the most game release?
df2=@chain df begin
    @group_by(year)
    @summarize(counts =nrow())
    @arrange(desc(counts))
end


# 3.3  Top 5 years games release by genre
# df3=@chain df begin
#     @group_by(yea,genre)
#     @summarize(counts =nrow())
#     @arrange(desc(sales))
# end

#  3.4 Which year had the highest sales worldwide?
df4=@chain df begin
    @group_by(year)
    @summarize(sales =sum(global_sales))
    @arrange(desc(sales))
end

# 3.5 Which genre game has been released the most in a single year?
df5=@chain df begin
    @group_by(year,genre)
    @summarize(counts =nrow())
    @arrange(desc(counts)) # 在每个组中按数量降序排列
    @slice(1)              # 每组最多发布游戏的一行
    @ungroup
end

# 3.6 Which genre game has sold the most in a single year?
df6=@chain df begin
    @group_by(year,genre)
    @summarize(sales =sum(global_sales))
    @arrange(desc(sales)) # 在每个组中按全球销售额降序排列
    @slice(1)              # 每组销量最多的
    @ungroup
end

#3.7 Which genre game have the highest sale price globally?

df7=@chain df begin
    @group_by(genre)
    @summarize(sales =sum(global_sales))
    @arrange(desc(sales)) # 在每个组中按全球销售额降序排列
             # 每组销量最对的
    @ungroup
end

#  3.8 Which platfrom have the highest sale price globally?
df8=@chain df begin
    @group_by(platform)
    @summarize(sales =sum(global_sales))
    @arrange(desc(sales)) # 在每个组中按全球销售额降序排列
    @ungroup
end

# 3.9 Which individual game have the highest sale price globally?

df8=@chain df begin
    @select(name,year,global_sales)
    @arrange(desc(global_sales)) # 在每个组中按全球销售额降序排列
    @slice(1:20)
end

# 3.10 Sales compearison by genre
df10=@chain df begin
    @select(genre,na_sales,eu_sales,jp_sales,other_sales)
    @group_by(genre)
    @summarize(na_sales = sum(na_sales), eu_sales = sum(eu_sales),jp_sales=sum(jp_sales),other_sales=sum(other_sales))
    @ungroup
end

## 3.11 Sales compearison by platform
df11=@chain df begin
    @select(platform,na_sales,eu_sales,jp_sales,other_sales)
    @group_by(platform)
    @summarize(na_sales = sum(na_sales), eu_sales = sum(eu_sales),jp_sales=sum(jp_sales),other_sales=sum(other_sales))
    @ungroup
end

## 3.12 Top 20 Publisher
df12=@chain df begin
    @group_by(publisher)
    @summarize(counts =nrow())
    @arrange(desc(counts))
    @slice 1:20
end

# 3.13  Top global sales by publisher
df13=@chain df begin
    @group_by publisher 
    @summarize sales=sum(global_sales)
    @arrange desc(sales)
    @slice 1:20
end

# 3.14  publisher comparison
df14=@chain df begin
    @group_by(publisher)
    @summarize( na_sales = sum(na_sales), 
                eu_sales = sum(eu_sales),
                jp_sales=sum(jp_sales),
                other_sales=sum(other_sales),
                global_sales=sum(global_sales)
    )
    @arrange desc(global_sales)
    @slice 1:15
end

# 3.15 Top publisher by Count each year
df15=@chain df begin
    @select(year,publisher)
    @group_by(year,publisher)
    @summarize(counts =nrow())
    @arrange(desc(counts)) # 在每个组中按全球销售额降序排列
    @slice(1)              # 每组销量最多的
    @ungroup
end


# 3.16 Total revenue by region
df16=@chain df begin
    @select(na_sales,eu_sales,jp_sales,other_sales,global_sales)
    @summarize( na_sales = sum(na_sales), 
                eu_sales = sum(eu_sales),
                jp_sales=sum(jp_sales),
                other_sales=sum(other_sales),
                global_sales=sum(global_sales)
    )
end

#  3.17 Sales Histogram
op=log
# 在@chain 中做转换是可以的, 但是要处理-Inf 的问题 log(0)==-Inf,所以放到绘图时处理
df17=@chain df begin
    @select(na_sales,eu_sales,jp_sales,other_sales,global_sales)
    # @mutate( na_sales = op(na_sales), 
    # eu_sales = op(eu_sales),
    # jp_sales=op(jp_sales),
    # other_sales=op(other_sales),
    # global_sales=op(global_sales)
    # )

end

# log(0)==-Inf true


df20=@chain df begin
    @group_by(year)
    @summarize(counts =nrow())
    @arrange  desc(counts)
    @slice 1:5
end

df3=@chain

