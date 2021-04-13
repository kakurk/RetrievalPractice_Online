# generate condition lists

## Requirements

library(tidyverse)
library(jsonlite)

## stimuli tables

scene.Tbl.FileName <- 'stim/select_scene_stim.csv'
scene.Tbl <- read.csv(scene.Tbl.FileName)
object.Tbl.Filename <- 'stim/select_object_stim.csv'
object.Tbl <- read.csv(object.Tbl.Filename)

# condition lists

## Encoding
## pair an object with a scene randomly. Create a random position on the circle for object image to be

### select 40 scenes, objects
scene.Tbl %>% sample_n(6) -> FortyScenes # 40
object.Tbl %>% sample_n(60) -> FortyObjects # 40

### generate x,y positions in a circle

points <- 1000
radius <- 225

drawCirclePoints <- function(points, radius, center_x = 0, center_y = 0) {
  
  slice <- 2 * pi / points
  angle <- slice * seq(1, points, by = 1)
  
  newX <- center_x + radius * cos(angle)
  newY <- center_y + radius * sin(angle)
  
  plot(newX, newY)
  
  out <- tibble(xPos = newX, yPos = newY)
  
  return(out)
}

CircleCoordinates <- drawCirclePoints(points, radius)

### randomly pair scenes and objects
Encoding <- tibble(Object = sample(FortyObjects$file), obj_ratio = FortyObjects$Ratio)
Encoding$Scene <- gl(n = nrow(FortyScenes), k = 10, labels = FortyScenes$file)

### randomly assign each Scene Object pair an x,y coordinate
Encoding %>%
  mutate(xy = map(Scene, ~sample_n(CircleCoordinates, 1))) %>%
  unnest(xy) -> Encoding

## Randomly assign each trial to either restudy OR Ret Practice
Encoding %>%
  nest(data = -Scene) %>%
  mutate(data = map(data, ~mutate(.x, Condition = gl(n = 2, k = 5, labels = c('Restudy', 'RetPractice'))))) %>%
  unnest(cols = c(data)) %>%
  sample_n(size = nrow(.)) -> Encoding

write.csv(x = Encoding, file = 'encoding.csv')
Encoding %>% 
  toJSON() %>% 
  str_c('enc_data = ', .) %>% 
  write_lines(path = 'encoding.js')

### Restudy

Encoding %>%
  filter(Condition == 'Restudy') %>%
  sample_n(size = nrow(.)) -> Restudy

write.csv(x = Restudy, file = 'restudy.csv')
Restudy %>% 
  toJSON() %>% 
  str_c('restudy_data = ', .) %>% 
  write_lines(path = 'restudy.js')

### Retrieval Practice

Encoding %>%
  filter(Condition == 'RetPractice') %>%
  sample_n(size = nrow(.)) -> RetPractice

write.csv(x = RetPractice, file = 'retpractice.csv')
RetPractice %>% 
  toJSON() %>% 
  str_c('retpractice_data = ', .) %>% 
  write_lines(path = 'retpractice.js')

### Retrieval

Scenes.Not.Encoding <- anti_join(scene.Tbl, FortyScenes)

Encoding %>%
  sample_n(size = nrow(.)) -> Retrieval

source('pick_scene_choices_alt.R')

Retrieval %>%
  mutate(SceneChoices = map2(Scene, Condition, pick_scene_choices)) %>%
  unnest(SceneChoices) -> Retrieval

write.csv(x = Retrieval, file = 'retrieval.csv')
Retrieval %>%
  toJSON() %>%
  str_c('retrieval_data = ', .) %>% 
  write_lines(path = 'retrieval.js')