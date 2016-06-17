library(tidyr)
library(dplyr)
library(ggplot2)
select <- dplyr::select

regData <- read.csv("adaptation-results-original-replication.csv")

tallData <- read.csv("first-percept-durs-tall.csv") %>%
  rename_(.dots=setNames(names(.), gsub("table_", "", names(.))))

levels(tallData$varname)[3:4] <- "noadap.first.dur"

wideData <- tallData %>%
    aggregate(varvalue ~ id + varname + diagnosis,
              FUN = mean,
              data= .) %>%
    spread(varname, varvalue) %>%
    rename_(.dots=
              setNames(names(.), gsub("dur", "mean", names(.)))) %>%
  left_join(
    tallData %>%
      aggregate(varvalue ~ id + varname + diagnosis,
                FUN = length,
                data= .) %>%
      spread(varname, varvalue) %>%
      rename_(.dots=
                setNames(names(.), gsub("dur", "n", names(.)))
      )
  ) %>%
  left_join(
    tallData %>%
      aggregate(varvalue ~ id + varname + diagnosis,
                FUN = sd,
                data= .) %>%
      spread(varname, varvalue) %>%
      rename_(.dots=
                setNames(names(.), gsub("dur", "sd", names(.))))
  )



# Create a distribution plot
ggplot(tallData, mapping = aes(x = varvalue)) +
  geom_density(alpha = 0.2,
               aes(color = varname, fill = varname))

##################################################################




ggplot(wideData%>%select(id, diagnosis, ends_with(".n"))%>%gather(condition, n, -id, -diagnosis),
       mapping = aes(x=condition,
                     y=n,
                     fill=diagnosis)) +
  geom_violin() +
  geom_jitter(shape=1, position=position_jitterdodge(dodge.width=0.9,
                                                     jitter.width=0.1))
  



for (condition in unique(tallData$varname)) {
  noadap.gammfit <-
    tallData %>%
    subset(varname==condition) %>%
    .$varvalue %>%
    fitdist(distr="gamma", method="mle")
  plot(noadap.gammfit)
}