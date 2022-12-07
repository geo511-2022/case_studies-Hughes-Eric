#Use library(ggplot2)
library(ggplot2)
library(dplyr)
library(gapminder)


woKuwait <- gapminder %>% filter(country != "Kuwait")

#Plot #1 (the first row of plots)

ggplot(woKuwait, aes(lifeExp, gdpPercap, color = continent, size=pop/100000))+ theme_bw() + geom_point()+
  scale_y_continuous(trans = "sqrt") + facet_wrap(~year,nrow=1) + 
  labs(title = "Wealth and life expectancy through time", x = "Life Expectancy", y = "GDP per capita") + 
  guides(size= guide_legend(title = "Population (100k)"))

ggsave("plot_1.png", width = 15)

dev.off(ggsave("plot_1.png", width = 15))

#Prepare the data for the second plot
gapminder_continent <- woKuwait %>% 
  group_by(continent, year) %>% 
  summarize(gdpPercapweighted = weighted.mean(x = gdpPercap, w = pop), pop = sum(as.numeric(pop)))

#Plot #2 (the second row of plots)
ggplot(woKuwait, aes(year, gdpPercap, color = continent))  + geom_line(aes(group = country)) + geom_point() +
  geom_line(data = gapminder_continent, aes(x = year, y = gdpPercapweighted), color = 'black') + 
  geom_point(data = gapminder_continent, aes(x = year, y = gdpPercapweighted, size = pop/100000), colour = 'black') +
  facet_wrap(~continent, nrow=1) + theme_bw() + guides(size= guide_legend(title = "Population (100k)")) +
  labs(y = "GDP per capita",x  = "Year") 

ggsave("plot_2.png", width = 15)

dev.off(ggsave("plot_2.png", width = 15))
