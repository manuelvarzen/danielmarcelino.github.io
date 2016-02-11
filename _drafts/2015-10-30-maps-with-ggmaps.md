There are times when a map speaks for itself. 

Two functions in `ggmap` package can be of great value. One is the `geocode`, which transverse any text character into a Google Maps query and returns the coordinates (longitude, latitude) if the term is recognizable. The other magically draws a map out of the text query. There are parameters for controlling the level of details using the zoom, the map type, and the source of the figure.

In the figure below I used the watercolor.


library(ggmap)
geocode("Calgary")
geocode("Saddledome Calgary")

> geocode("Calgary")
Information from URL : http://maps.googleapis.com/maps/api/geocode/json?address=Calgary&sensor=false
Google Maps API Terms of Service : http://developers.google.com/maps/terms
        lon      lat
1 -114.0581 51.04532
> geocode("Saddledome Calgary")
Information from URL : http://maps.googleapis.com/maps/api/geocode/json?address=Saddledome+Calgary&sensor=false
Google Maps API Terms of Service : http://developers.google.com/maps/terms
        lon      lat
1 -114.0513 51.03811


the other is qmap that makes a map out of the text query. We can change the level of detail using the zoom option.

One of the options that I like is of course watercolor using parameter maptype.

qmap("Saddledome Calgary")
qmap("Saddledome Calgary",zoom=15)
qmap("Saddledome Calgary",zoom=15,maptype="watercolor")


You may also be interested in other useful functions for spatial analysis like `get_map` and `ggmap`, which respectively get and plot the map for a query. If you want to decorate you map, you can of course add layers for your data.
