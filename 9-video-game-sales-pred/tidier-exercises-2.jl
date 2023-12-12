using CSV,Tidier,Pipe
using DataFrames


df = @pipe CSV.File("./data/vgsales.csv")|> DataFrame
@pipe names(df)|>lowercase.(_)|>rename!(df,_)


## 1. filter by function and transform 
is_not_zero(i)=i!=0
@chain df  begin
    @filter is_not_zero(eu_sales)
    @filter is_not_zero(na_sales)
    @mutate(log_eu_sales=log(eu_sales),
            log_na_sales=log(na_sales)
    )
    @select(log_eu_sales,log_na_sales)
end

## 2. comgin groupby and summarise

@chain df begin
    @group_by(year)
    @summarise(release = nrow())
    @arrange(desc(release))
    @slice(1:10)
end

## 3. 在 log 变换之前把 0转换变换为一个极小的正值
@chain df  begin
    @mutate(log_eu_sales = if_else(eu_sales ==0,log(0.0001), log(eu_sales)),
             log_na_sales = if_else(na_sales ==0,log(0.0001), log(na_sales)),
             log_jp_sales = if_else(jp_sales ==0,log(0.0001), log(jp_sales)),
             log_other_sales = if_else(other_sales ==0,log(0.0001), log(other_sales)),
             log_global_sales = if_else(global_sales ==0,log(0.0001), log(global_sales)),
            
    )
    
    @select(log_eu_sales,log_na_sales,log_jp_sales,log_other_sales,log_global_sales)
end
