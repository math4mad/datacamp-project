
using CSV,DataFrames,Tidier,GLMakie

df=CSV.File("./data/apps.csv")|>DataFrame|>unique

#  clean data 
# cleaned_data = @chain df begin
#          @mutate(Installs = if_else(occursin('k',Installs...),replace(Installs, "k"=>""|>d->d/1000), Installs))
# end

#Installs=Float64.(df.Installs)
Installs=df.Installs
for  (idx,ins) in enumerate(Installs)
     if  occursin("k",ins)
         ins=replace(ins,"k"=>"")
         ins=parse(Float64,ins)/1000|>string
         Installs[idx]=ins
     else occursin("Varies with device",ins)
        ins=replace(ins,"Varies with device"=>"missing")
        Installs[idx]=ins
     end
end

df.Inatalls=Installs

chars_to_remove =["+",",","M",String(:$)]

#cols_to_clean = ["Installs", "Size", "Price"]


