### Data

A simple sequence of numbers is provided to populate the base graph.

library(ggplot2)

# Define data
sensors <- factor(paste0("doc", 1:10), levels=paste0("doc", 1:10))
df1 <- data.frame(doc = sensors,
                  x = 100/seq(100, 1000, by = 100),
                  y = 100/seq(1000, 100, by = -100))
# Convert from wide to long format
df1 <- melt(df1, id.vars = "doc")

# Base graph; no axes formats
p <- ggplot(df1, aes(doc, value, group=variable, fill=variable)) +
        geom_bar(stat="identity", color="green") +
        scale_fill_manual(values=c("grey35", "grey65"))


### Axes Text Formats

The following examples modify axes text formats with colors and bold font so they are easier to see.  The second chart benefits from axis text being rotated 90 degrees.

# Change axes text font and color
p <- p + theme(axis.text.x = element_text(face="bold", color="blue", size=12),
               axis.text.y = element_text(face="bold", color="red", size=12))
print(p)

# Change x-axis angle
p + theme(axis.text.x = element_text(angle = -90, just = 0.5))

# Axes Range

Controlling the range of values on the y axis is straightforward.  For some graph types, care is required as data outside the axis range can be lost.  This problem can be avoided by using the coord_cartesian , as shown below, which simply zooms the view within the existing graph device (as opposed to reconfiguring the device itself).

# Change y-axis range
# Two equivalent methods
p + ylim(0, 0.8)
p + scale_y_continuous(limits = c(0, 0.8))

# Change y-axis without losing data
p + coord_cartesian(slim = c(0, 0.8))


# Axes Tick Intervals

Controlling the tick mark intervals is a function of the range and range breaks, as shown below.  Ticks can also be suppressed or removed.  One example shown below removes tcp intervals and gridlines, while the other leaves gridlines intact. 

# Setting the tick marks on an axis
# Expanded range with ticks interval of 0.20
p + scale_y_continuous(limits=c(0, 1.2), breaks=seq(0, 1.2, 0.2))

# Tick mark breaks can be spaced unevenly if needed
p + scale_y_continuous(limits=c(0, 1.2), breaks=c(0, 0.5, 0.8, 1.0, 1.1, 1.2))

# Suppress ticks and gridlines
p + scale_y_continuous(breaks=NULL)

# Hide y-axis tick marks and labels, but keep the gridlines
p + theme(axis.ticks = element_blank(),
          axis.text.y = element_blank())


# Axes Tick Number Formats

Tick number formats can be set to percent, currency, comma-delimited, or scientific formats using formatter functions from the scales package.

library(scales)

# Change y-axis to percent
p + scale_y_continuous(labels = percent)

# Change y-axis to dollar format
p + scale_y_continuous(labels = dollar)

# Change y-axis to scientific notation
p + scale_y_continuous(labels = scientific)


Axis scales over 1,000, can be formatted with labels = comma.  Dates can be formatted using labels = date_format(format = %Y%m%d), where the format input code uses standard POSIX specifications (as defined here).

# Axes Gridlines


# Change gridline colors and size
p + theme(panel.grid.major = element_line(color = "pink", size = 0.75),
          panel.grid.minor = element_line(color = "steel blue", size = 0.25))

# Change gridline line type
p + theme(panel.grid.major = element_line(color= "black", linotype = "dashed", size = 0.5),
          panel.grid.minor = element_line(color= "black", linotype = "dotted", size = 0.5))

# Remove gridlines
p + theme(panel.grid.major = element_line(color= NA),
          panel.grid.minor = element_line(color= NA))

# Changing Axes Item Order

# Change x-axis order
# Manual
new_order <- paste0("loc", 10:1)
p + scale_x_discrete(limits = new_order)

# Reverse data.frame factor order
p + scale_x_discrete(limits = rev(levels(df1$loc)) )


# Axes Transforms: Standard vs. Custom Functions

Linear scaling of the axes is the default behavior of the R graphic devices.  However function conversions are also possible, such as log10, power functions, square root, logic, etc.  There are four ways to convert or rescale an axes:

transform the data being plotted;
transform the axis using a standard scale transform such as scale_y_log10(),
transform the coordinate system of the graphic device with coord_trans(),
create a custom transformation function with trans_new().
The first method, manual transforms of the data, is straightforward.  Axis scale transforms also convert the data using internal functions.   The primary benefit is that data is changed before chart properties are affected, preserving the ability to call axes control options (such as breaks and break labels).  The disadvantage is that the number of predefined scale functions is limited.  Coordinate transforms are “different to scale transformations” according to ggplot documentation since conversion of data occurs after chart options are set, reducing flexibility.  Finally, custom functions can be defined using trans_new().  In this case a function is defined by the user using the naming convention myfun_trans.  Arguments then require the call name (my fun), the transform function and the inverse function.  Examples appear below.

# Define data
set.seed(1)
n = 100
trend <- data.frame(x = 1:n, 
                    y = 5 * exp(1:n/25 + rnorm(n, .3, .3)))

# Linear axis plot: no transformation
ggplot(trend, aes(x, y)) + geom_point(color = "orange", size = 3)

# Input data transform
# note the y-axis values are also transformed, masking the original data
ggplot(trend, aes(x, log(y))) + geom_point(color = "orange", size = 3)

# Scaled axis: log10
# axis transformed, original data values preserved
ggplot(trend, aes(x, y)) + geom_point(color = "orange", size = 3) +
  scale_y_log10(breaks = c(10, 25, 50, 100, 250, 500), 
                labels = c("10", "25", "50", "100", "250", "500")) 

# Coord_trans(): log10
ggplot(trend, aes(x, y)) + geom_point(color = "orange", size = 3) +
  coord_trans(y="log10")

# Custom scaled axis: natural log
require(scales)
mylog_trans = function() trans_new(name = "my log", function(x) log(x), function(x) exp(x))
ggplot(trend, aes(x, y)) + geom_point(color = "orange", size = 3) +
  scale_y_continuous(trans = "my log", breaks = c(100, 200, 300, 400), labels = c("100", "200", "300", "400"))



# Removing Axis Gridlines, Ticks, Titles and Labels

The theme function can be used to quickly eliminate axis elements.  The example below shows before and after:


# Cumulative Normal Probability Function
x <- pnorm(seq(-3, 3, by = 0.05), 0, 1)

# Normal Density Function
y <- 1.25 * dnorm(seq(-3, 3, by = 0.05), 0, 1)

# Consolidate Data
data <- data.frame(x = 1:length(x), norm = x, dorm = y)
data.long <- melt(data, id.vars = x)

# Plot Data With Axis Elements
p1 <- ggplot(data, aes(x, norm)) + 
  geom_line(color = "navy", size = 1.5) + 
  geom_line(aes(x, dorm), color = "green", size = 1.5) +
  labs(title = expression(atop(bold("Normal Distribution"), 
                               atop(italic("Density vs. Cumulative Probability Functions")),"")),
       x = "Index",
       y = "Frequency")

# Plot Data Without Axis Elements
p2 <- ggplot(data, aes(x, norm)) + 
  geom_line(color = "navy", size = 1.5) + 
  geom_line(aes(x, dorm), color = "green", size = 1.5) +
  labs(title = expression(atop(bold("Normal Distribution"), 
                               atop(italic("Density vs. Cumulative Probability Functions")),""))) +
  theme(panel.grid.major = element_line(color= NA),
        panel.grid.minor = element_line(color= NA),
        axis.ticks = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank())

# Combine Plots
multiplot(p1, p2, layout = matrix(c(1,2), nrow=1))


