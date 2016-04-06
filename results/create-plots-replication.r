library(ggplot2)
library(reshape2)

allData <- read.csv("adaptation-results-original-replication.csv")

# convert diagnosis to factor
allData$Diagnosis <- as.factor(allData$Diagnosis)
levels(allData$Diagnosis) <- c("CON", "ASC")

# convert experiment to factor
allData$Experiment <- as.factor(allData$Experiment)
levels(allData$Experiment) <- c("Experiment 1", "Experiment 2")


# kick out outliers and only focus on study 1
inData = subset(allData, Inliers==1)


# first percept bias plot
ggplot(inData, aes(x=Diagnosis, y = no.exposure.green.first)) +
  # violin plot
  geom_violin(aes(fill=Diagnosis,
                  scale="count")) +
  # superimpose scatter
  geom_jitter(color = "white",
              width=0.15,
              shape=1) +
  # superimpose reference line
  geom_hline(yintercept=0.5, linetype=2) +
  # superimpose mean and errorbars
  stat_summary(fun.data=mean_se, 
               geom="pointrange", color="gray0") +
  # set the axes
  scale_y_continuous(name="Proportion of first percepts that\nwere green at baseline") +
  scale_x_discrete(name="Diagnosis", labels=c("Control", "Autism"),
                   expand=c(0, 1.2)) +
  coord_cartesian(ylim=c(0, 1)) +
  # adjust the theme
  theme(axis.text.x = element_text(size=14),
        axis.title.x = element_text(size=14),
        axis.title.y = element_text(size=14),
        legend.position = "none")


# shift in first percept plot #
shiftData <- melt(inData[, c("Diagnosis",
                             "val.exposure.exposed.first",
                             "inv.exposure.exposed.first",
                             "Experiment")])

ggplot(shiftData, aes(x=variable, y = value, fill = Diagnosis)) + 
  geom_violin(aes(scale="count")) +
  geom_jitter(color="white",
              position=position_jitterdodge(dodge.width=0.9,jitter.width=0.2),
              show.legend=FALSE,
              shape=1) +
  
  geom_hline(yintercept=0, linetype=2) +
  stat_summary(fun.data=mean_se, 
               geom="pointrange", color="gray0",
               position=position_dodge(width=0.9),
               show.legend=FALSE) +
  # adjust the theme a bit
  theme(axis.text.x = element_text(size=14),
        axis.title.x = element_text(size=14),
        axis.title.y = element_text(size=14),
        legend.position = "top") +
  # adjust the axes
  scale_y_continuous(name="Proportion of first percepts that were the\nadapted image (relative to baseline)") +
  scale_x_discrete(name="Condition", labels=c("Same-Eye Adaptation", "Opposite-Eye Adaptation"))
#  coord_cartesian(ylim=c(-0.5, 0.3))


# change in percept duration plot #
durations <- inData[, c("Diagnosis",
                        "no.exposure.dom.median",
                        "val.exposure.exposed.median",
                        "val.exposure.nonexp.median",
                        "inv.exposure.exposed.median",
                        "inv.exposure.nonexp.median")]

durations[,2:6] <- durations[,2:6] - durations$no.exposure.dom.median

durations <- melt(durations[,c(1, 3:6)])

durations$exposure.condition <- as.factor(durations$variable == "val.exposure.exposed.median" |
  durations$variable == "val.exposure.nonexp.median")
levels(durations$exposure.condition) <- c("Opposite-Eye Adaptation",
                                          "Same-Eye Adaptation")
durations$exposure.condition <- factor(durations$exposure.condition, levels=rev(levels(durations$exposure.condition)))

durations$exposure.type <- as.factor(durations$variable == "val.exposure.exposed.median" |
                                       durations$variable == "inv.exposure.exposed.median")
levels(durations$exposure.type) <- c("Non-adapted\nImage",
                                          "Adapted\nImage")


ggplot(durations, aes(x=exposure.type, y = value, fill = Diagnosis)) +
  # plot violins
  geom_violin(aes(scale="count")) +
  # split into multiple graphs
  facet_grid(. ~ exposure.condition) +
  # superimpose scattered data
  geom_jitter(color="white",
              position=position_jitterdodge(dodge.width=0.9,jitter.width=0.2),
              show.legend=FALSE,
              shape=1) +
  # superimpose horizontal line
  geom_hline(yintercept=0, linetype=2) +
  # superimpose mean and errorbar
  stat_summary(fun.data=mean_se, 
               geom="pointrange", color="gray0",
               position=position_dodge(width=0.9),
               show.legend=FALSE) +
  # adjust the theme a bit
  theme(axis.text.x = element_text(size=14),
        axis.title.x = element_text(size=14),
        axis.title.y = element_text(size=14),
        legend.position = "top") +
  # adjust the axes
  coord_cartesian(ylim=c(-0.75, 1.05)) +
  scale_y_continuous(name="Change in median dominance duration of stimuli\n(relative to baseline)") +
  scale_x_discrete(name="Stimulus")