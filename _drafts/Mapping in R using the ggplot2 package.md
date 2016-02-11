



# Mapping using the ggplot2 package

 I plot a map of Brazil with data point distribution, 
I received couple e-mails to share the code. So, in this example I will go through plotting step-by-step 

use points and polygons by themselves but if you'd like to include tile maps from Google, Stamen and others you should check out the ggmap package.

# Read in the point and polygon data

Start by reading in the data. Our point data is in a comma-separated file with latitude and longitude values. Our polygons are a shape file of NYC counties (also known as boroughs). You can get a similar file from the NYC Department of City Planning. Note that we're using the readOGR function from the package rgdal instead of readShapePoly from map tools. You'll see why later in the post.

```library(rgdal)
  library(ggplot2)
    # read in point data (tabular data)
  mapdata<-read.csv("mapdata.csv", stringsAsFactors=FALSE)


  # the shape file of NYC counties/boroughs. Careful about how you define the path
  # and layer. I always find this odd.
  counties<-readOGR("nybb.shp", layer="nybb")
```


- Make some simple maps using ggplot()

Now we can create the maps in the same way we make non-geographic charts in ggplot. (If you know NYC, you know that the map is distorted — don’t worry we will fix this in the last step).

  # map the counties
  ggplot() +  geom_polygon(data=counties, aes(x=long, y=lat, group=group))


How about the points

  # map the points
  ggplot() +  geom_point(data=mapdata, aes(x=longitude, y=latitude), color="red")


Great, this is easy. Let's combine the two:

  # map both ploys and points together
  ggplot()+geom_polygon(data=counties, aes(x=long, y=lat, group=group)) +  
  geom_point(data=mapdata, aes(x=longitude, y=latitude), color="red")


Shucks! Usually when you see something odd like this it's related to inconsistent projections.

3. Make the projections consistent

Projecting geographic data is a pain no matter how long you've been doing it. Even though I've been mapping with R for many years I still need to refer to my cheat sheet with some common projections and examples of the code needed to project.

[Note that ggplot2 does have a function called coord_map() that can be used as a sort of on-the-fly projection but the function is still experimental so we’re sticking with this approach for now.]

Before projecting we need to know the existing projection/coordinate system for the layers. For the counties we can use the function proj4string. Note, though, that if you read in the shape file using readShapePoly from the library map tools instead of readOGR the projection information will not be included.

proj4string(counties)
## [1] "+proj=lcc +lat_1=40.66666666666666 +lat_2=41.03333333333333 +lat_0=40.16666666666666 +lon_0=-74 +x_0=300000 +y_0=0 +datum=NAD83 +units=us-ft +no_defs +ellps=GRS80 +towgs84=0,0,0"


Well, the proj4 format is about as clear as mud. To get a more readable format you can look at the .prj file that came with shape file. For this one you would see the following (note that what you’ll actually see is plain text — the nice formatting you see here comes from spatialreference.org):


Well, the proj4 format is about as clear as mud. To get a more readable format you can look at the .prj file that came with shape file. For this one you would see the following (note that what you’ll actually see is plain text — the nice formatting you see here comes from spatialreference.org):


# ggplot can't deal with a SpatialPointsDataFrame so we can convert back to a data.frame
mapdata<-data.frame(mapdata)

# we're not dealing with lat/long but with x/y
# this is not necessary but for clarity change variable names
names(map data)[names(map data)=="longitude"]<-"x"
names(map data)[names(map data)=="latitude"]<-"y"

# now create the map
ggplot() +geom_polygon(data=counties, aes(x=long, y=lat, group=group))+  geom_point(data=mapdata, aes(x=x, y=y), color="red")


Ahh, that’s better. Still not pretty, but we have the pieces working.

5. Final touches

Here we're going make the map a little nicer. Get rid of axes, new color gradient, clean up title etc.

ggplot() +  
    geom_polygon(data=counties, aes(x=long, y=lat, group=group), fill="grey40", 
        colour="grey90", alpha=1)+
    labs(x="", y="", title="Building Area Within 1000m")+ #labels
    theme(axis.ticks.y = element_blank(),axis.text.y = element_blank(), # get rid of x ticks/text
          axis.ticks.x = element_blank(),axis.text.x = element_blank(), # get rid of y ticks/text
          plot.title = element_text(lineheight=.8, face="bold", vjust=1))+ # make title bold and add space
    geom_point(aes(x=x, y=y, color=buildarea), data=mapdata, alpha=1, size=3, color="grey20")+# to get outline
    geom_point(aes(x=x, y=y, color=buildarea), data=mapdata, alpha=1, size=2)+
    scale_colour_gradientn("Building\narea (sq-km)", 
        colours=c( "#f9f3c2","#660000"))+ # change color scale
    coord_equal(ratio=1) # square plot to avoid the distortion