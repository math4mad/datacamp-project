#= 
[What is Topic Modeling? An Introduction With Examples](https://www.datacamp.com/tutorial/what-is-topic-modeling)
=#

using CSV,DataFrames,StatsBase,Pipe
using MLJ
using TextAnalysis
import MLJ:fit!,transform
using  JLSO

function remove_keys(str)
    sd=StringDocument(str)
    prepare!(sd, strip_articles|strip_stopwords|strip_pronouns|strip_indefinite_articles|strip_numbers|strip_punctuation)
    remove_case!(sd)
    #remove_words!(sd, ["--","a"])
    TextAnalysis.stem!(sd)
    return sd

end

#res=[remove_keys(str) for str in text_data ]

function prepare_docs(text_data::Vector{String})
    docs=@pipe text_data|>remove_keys.(_)|>Corpus
    return  docs
    #JLSO.save("movie-tfidf-mat.jlso",:tfidf_mat => tfidf_mat)
    #@info "succes saved!"

end


# Creating example documents
doc_1 = "A whopping 96.5 percent of water on Earth is in our oceans, covering 71 percent of the surface of our planet. And at any given time, about 0.001 percent is floating above us in the atmosphere. If all of that water fell as rain at once, the whole planet would get about 1 inch of rain."

doc_2 = "One-third of your life is spent sleeping. Sleeping 7-9 hours each night should help your body heal itself, activate the immune system, and give your heart a break. Beyond that--sleep experts are still trying to learn more about what happens once we fall asleep."

doc_3 = "A newborn baby is 78 percent water. Adults are 55-60 percent water. Water is involved in just about everything our body does."

doc_4 = "While still in high school, a student went 264.4 hours without sleep, for which he won first place in the 10th Annual Great San Diego Science Fair in 1964."

doc_5 = "We experience water in all three states: solid ice, liquid water, and gas water vapor."

# Create corpus
corpus = [doc_1, doc_2, doc_3, doc_4, doc_5]

crps=prepare_docs(corpus)

TextAnalysis.lsa(crps)

#update_lexicon!(crps)
#cm = DocumentTermMatrix(crps)

