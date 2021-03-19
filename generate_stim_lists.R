## Generate Trial Lists

## Parameters
scene.stim.dir <- 'stim/scenes/'
object.stim.dir <- 'stim/objects/'

## Requirements
library(tidyverse)
library(imager)
library(pbapply)

imageInfo <- function(filepath){
  # a function that determines the layout (i.e., horizontal or vertical)
  # of an image
  require(imager)
  img <- load.image(filepath)
  imgDim <- dim(img)
  maxDim <- which.max(imgDim)
  if(maxDim == 1){
    layout <- 'horizontal'
  } else {
    layout <- 'vertical'
  }
  width <- imgDim[1]
  height <- imgDim[2]
  out <- tibble(layout = layout, width = width, height = height)
  return(out)
}

## Stim Lists

# Scenes

scene.fileNames <- list.files(scene.stim.dir, full.names = T)
scene.imageInfo <- map_dfr(scene.fileNames, imageInfo)
scene.names <- str_extract(scene.fileNames, '(?<=scenes\\/).*(?=[0-9]\\.)')
scene.pairNum <- str_extract(scene.fileNames, '[0-9]') %>% as.numeric()

scene.Tbl <- tibble(file = scene.fileNames, name = scene.names, pairNum = scene.pairNum)
scene.Tbl <- bind_cols(scene.Tbl, scene.imageInfo)

scene.Tbl %>%
  filter(layout == 'horizontal') %>%
  filter(pairNum == 1) -> scene.Tbl

# a vector of indices of scenes that I determined to be too "busy"
busyVector = c(20,35,38,45,64,69,78,81,86)
scene.Tbl$busy = 'not_busy'
scene.Tbl$busy[busyVector] = 'busy'

scene.Tbl %>%
  filter(busy == 'not_busy') -> scene.Tbl

print(nrow(scene.Tbl))

write.csv(x = scene.Tbl, 'stim/select_scene_stim.csv', row.names = F)

# Objects

object.fileNames <- list.files(object.stim.dir, full.names = T)

object.imageInfo <- map_dfr(object.fileNames, imageInfo)
object.names <- str_extract(object.fileNames, '(?<=objects\\/).*(?=_[0-9])')
object.pairNum <- str_extract(object.fileNames, '[0-9]') %>% as.numeric()

object.Tbl <- tibble(file = object.fileNames, name = object.names, pairNum = object.pairNum)
object.Tbl <- bind_cols(object.Tbl, object.imageInfo)

object.Tbl %>%
  filter(pairNum == 1) %>%
  mutate(Ratio = height/width) -> object.Tbl

print(nrow(object.Tbl))

write.csv(x = object.Tbl, 'stim/select_object_stim.csv', row.names = F)
