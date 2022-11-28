# Shin Appsilon assignment

The dashboard works as follows:

When loading the screen, the user can observe two filters and a map, each of these filters represent the type of selection, one being by the "vernacularName" variable and the other by the "scientificName" variable, it is worth nothing that when selecting a filter option "vernacularName", automatically the filter "scientificName" is updated and consequently the base of observations is updated as well. As a consequence, when updating the base, the tabs 'Map', 'Table', 'Chart Line', 'Other charts' are updated automatically.

![](shiny_appsilon_assignment/images_tutorial/img1.png)

In the 'Map' tab, the user can observe the points on the map, when touching the observation, some information that I found of some relevance to the user will appear, such as: 'Id', 'Country', 'Vernacular Name' , 'Scientific Name', 'Kingdom' and so on.

![](shiny_appsilon_assignment/images_tutorial/img2.png)

We can also see that there is another filter that the user can view only points with available images. To view these images, just click on the marker.

![](shiny_appsilon_assignment/images_tutorial/img2.png)

The tabs **'Table', 'Chart-Line', 'Other Charts'** 

**About the Extra tasks**

Beautiful UI skill: I change the layout a little bit, using .css file within the *www* folder

Infrastructure skill: I used a simple application using shiny-server with Azure cloud provider. As you can see in the link:

I also put this dashboard on https://www.shinyapps.io/, follow the link: https://arthurclm.shinyapps.io/shiny/
