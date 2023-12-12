using GLMakie ,FileIO

img =load("./2-nba-shooting-data/halfcourt.png")

x = range(-250, 250, length=size(img,1))
y = range(-50,250, length=size(img,2))

fig = Figure()
image(fig[1, 1], rotr90(img),axis = (aspect = DataAspect(),))

fig