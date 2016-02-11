Appreciating the Beauty of dplyr

2014-02-18

Hadley Wickham has once again1 made R ridiculously better. Not only is dplyr incredibly fast, but the new syntax allows for some really complex operations to be expressed in a ridiculously beautiful way.

Consider a data set, course, with a student identifier, sid, a course identifier, course no, a quarter, quarter, and a grade on a scale of 0 to 4, gpa. What if I wanted to know the number of a courses a student has failed over the entire year, as defined by having an overall grade of less than a 1.0?

In dplyr:

course %.% 
group_by(sid, courseno) %.%
summarise(gpa = mean(gpa)) %.%
filter(gpa <= 1.0) %.%
summarise(fails = n())
I refuse to even sully this post with the way I would have solved this problem in the past.