library(reshape2)
library(effsize)

allData <- read.csv("adaptation-results-original-replication.csv")

# convert diagnosis to factor
allData$Diagnosis <- factor(allData$Diagnosis, labels=c("CON", "ASC"))
# convert study to factor
allData$Study <- factor(allData$Study, labels=c("Original Sample", "Replication Sample"))

# set up lookup tables for the different variables
lookup.exposure <- c(val.exposed.median.diffscore="Same-eye",
                     val.nonexp.median.diffscore="Same-eye",
                     inv.exposed.median.diffscore="Opposite-eye",
                     inv.nonexp.median.diffscore="Opposite-eye",
                     val.exposure.exposed.first="Same-eye",
                     inv.exposure.exposed.first="Opposite-eye",
                     val.exposure.red.median="Same-eye",
                     val.exposure.green.median="Same-eye",
                     inv.exposure.red.median="Opposite-eye",
                     inv.exposure.green.median="Opposite-eye")
lookup.stimulus <- c(val.exposed.median.diffscore="Adapted",
                     val.nonexp.median.diffscore="Non-adapted",
                     inv.exposed.median.diffscore="Adapted",
                     inv.nonexp.median.diffscore="Non-adapted",
                     val.exposure.red.median="Red image",
                     val.exposure.green.median="Green image",
                     inv.exposure.red.median="Red image",
                     inv.exposure.green.median="Green image")

# determine who to exclude
allData$exclude = 
  allData$no.exposure.no.dom > mean(allData$no.exposure.no.dom) +
  2 * sd(allData$no.exposure.no.dom) |
  allData$val.exposure.no.dom > mean(allData$val.exposure.no.dom) +
  2 * sd(allData$val.exposure.no.dom) |
  allData$inv.exposure.no.dom > mean(allData$inv.exposure.no.dom) +
  2 * sd(allData$inv.exposure.no.dom) |
  allData$val.exposure.exposed.first == 0.5 |
  allData$inv.exposure.exposed.first == 0.5

summary(allData$exclude)
  
inData = subset(allData, !exclude)


# Test if there's a difference in first report bias
t.test(no.exposure.green.first ~ Diagnosis, data=inData, var.equal=TRUE)
# Test if the bias is different between study or diagnosis
oneway.test(no.exposure.green.first ~ interaction(Diagnosis, Study), data=inData)
# Test if the bias is true & significant for everyone
t.test(subset(inData, Diagnosis=="CON" & Study=="Original Sample")$no.exposure.green.first)
t.test(subset(inData, Diagnosis=="ASC" & Study=="Original Sample")$no.exposure.green.first)
t.test(subset(inData, Study=="Replication Sample")$no.exposure.green.first)


# rm-anova to test if exposure type affected first percept
rmData <- melt(inData[, c("ID", "Diagnosis", "Study",
                     "val.exposure.exposed.first",
                     "inv.exposure.exposed.first")],
               variable.name="adaptation.condition",
               value.name="exposed.first")
levels(rmData$adaptation.condition) <- c("Same-eye adaptation",
                                        "Opposite-eye adaptation")
exposed.first.aov <- aov(exposed.first ~ Diagnosis * adaptation.condition + Error(ID/adaptation.condition), data = rmData)
summary(exposed.first.aov)
# t-tests to check if both are significant
exposed.first.val.t.test <- t.test(inData$val.exposure.exposed.first)
exposed.first.val.effsize <- mean(inData$val.exposure.exposed.first)/
  sd(inData$val.exposure.exposed.first)
exposed.first.inv.t.test <- t.test(inData$inv.exposure.exposed.first)
exposed.first.inv.effsize <- mean(inData$inv.exposure.exposed.first)/
  sd(inData$inv.exposure.exposed.first)


# rm-anova to test if exposure type affected percept duration
rmData <- melt(inData[, c("ID", "Diagnosis", "Study",
                          "val.exposed.median.diffscore",
                          "val.nonexp.median.diffscore",
                          "inv.exposed.median.diffscore",
                          "inv.nonexp.median.diffscore")],
               value.name="median.percept.duration")
rmData$adaptation.condition <- factor(lookup.exposure[as.character(rmData$variable)])
rmData$stimulus.type <- factor(lookup.stimulus[as.character(rmData$variable)])
median.duration.aov.test <- aov(median.percept.duration ~
                             Diagnosis * adaptation.condition * stimulus.type +
                               Error(ID/(adaptation.condition * stimulus.type)),
                           data = rmData)
median.duration.aov.etsq <- EtaSq(median.duration.aov.test, type = 1)
# t-tests to check which condition shifted which medians
median.duration.val.nonadapted.t.test <- t.test(inData$val.nonexp.median.diffscore)
median.duration.val.nonadapted.effsize <- mean(inData$val.nonexp.median.diffscore)/
  sd(inData$val.nonexp.median.diffscore)
median.duration.inv.nonadapted.t.test <- t.test(inData$inv.nonexp.median.diffscore)
median.duration.inv.nonadapted.effsize <- mean(inData$inv.nonexp.median.diffscore)/
  sd(inData$inv.nonexp.median.diffscore)
median.duration.val.adapted.t.test <- t.test(inData$val.exposed.median.diffscore)
median.duration.val.adapted.effsize <- mean(inData$val.exposed.median.diffscore)/
  sd(inData$val.exposed.median.diffscore)
median.duration.inv.adapted.t.test <- t.test(inData$inv.exposed.median.diffscore)
median.duration.inv.adapted.effsize <- mean(inData$inv.exposed.median.diffscore)/
  sd(inData$inv.exposed.median.diffscore)



# test if there is an effect of color on percept length
rmData3 <- melt(inData[, c("ID", "Diagnosis", "Study",
                          "val.exposure.red.median",
                          "val.exposure.green.median",
                          "inv.exposure.red.median",
                          "inv.exposure.green.median")],
               value.name="median.percept.duration")
rmData3$adaptation.condition <- factor(lookup.exposure[as.character(rmData3$variable)])
rmData3$stimulus.type <- factor(lookup.stimulus[as.character(rmData3$variable)])
color.percepts


# source('create-plots.r', echo = TRUE)