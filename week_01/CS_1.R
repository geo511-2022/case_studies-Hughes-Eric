# import ggplot2 library

library(ggplot2)

# import iris data

data(iris)

# find the mean of petal length

petal_length_mean <- mean(iris$Petal.Length)

# assign petal length a variable name 
petal_length <- iris$Petal.Length

# create a histogram
qplot(petal_length, geom = 'histogram', main = "Petal Length Count", xlab = "Petal Length", 
      ylab = "Count", colour = I("black"),fill = I("green"))