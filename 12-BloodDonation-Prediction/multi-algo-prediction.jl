#= 
[BloodDonation_Prediction_VariousML_algorithms](https://www.kaggle.com/code/m0sanjith/blooddonation-prediction-variousml-algorithms/input)
=#

using DataFrames,CSV,Query,Pipe 

df = @pipe CSV.File("./data/transfusion.csv")|> DataFrame|>dropmissing