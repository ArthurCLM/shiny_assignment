# Shiny Appsilon assignment

The project can be seen at the link: https://arthurclm.shinyapps.io/shiny/

The dashboard works as follows:

When loading the screen, the user can observe two filters and a map, each of these filters represents the type of selection, one being by the "vernacularName" variable and the other by the "scientificName" variable, it is worth nothing that when selecting a filter option "vernacularName", automatically the filter "scientificName" is updated and consequently the base of observations is updated as well. As a consequence, when updating the base, the tabs 'Map', 'Table', 'Chart Line', 'Other charts' are updated automatically.

![](shiny_appsilon_assignment/images_tutorial/img1.png)

In the 'Map' tab, the user can observe the points on the map, when touching the observation, some information that I found of some relevance to the user will appear, such as: 'Id', 'Country', 'Vernacular Name' , 'Scientific Name', 'Kingdom' and so on.

![](shiny_appsilon_assignment/images_tutorial/img2.png)

We can also see that there is another filter that the user can view only points with available images. To view these images, just click on the marker.

![](shiny_appsilon_assignment/images_tutorial/img2.png)

The tabs called **'Table', 'Chart-Line', 'Other Charts'** are information regarding the base country of Poland. The first one is a summary of the filtered information, the second one is a time series graph of the information and the last tab is just some bar graphs of other variables that i found interesting for the user to see.

All the steps to obtain the final base for the realization of this project are present in the **get.data.R** function, there I commented step by step all the approaches I had and my idea of how to extract the database from Poland.

**About the Extra tasks**

Beautiful UI skill: I change the layout a little bit, using .css file within the *www* folder
