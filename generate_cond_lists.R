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
object.Tbl %>% filter(width == 400) %>% sample_n(6) -> FortyObjects # 40

### generate x,y positions in a circle

points <- 100
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

### randomly pairs scenes and objects
Encoding <- tibble(Scene = sample(FortyScenes$file), Object = sample(FortyObjects$file), obj_ratio = FortyObjects$Ratio)

### randomly assign each Scene Object pair an x,y coordinate
Encoding %>%
  mutate(xy = map(Scene, ~sample_n(CircleCoordinates, 1))) %>%
  unnest(xy) -> Encoding

## Randomly assign each trial to either restudy OR Ret Practice
Encoding %>%
  mutate(Condition = gl(n = 2, k = 3, labels = c('Restudy', 'RetPractice'))) %>% # k = 20
  sample_n(size = nrow(Encoding)) -> Encoding

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

pick_scene_choices <- function(corScene, condition){
  # pick 6 scenes as choices for the 6 AFC
  
  # Pick 3 Novel Lures from Scenes not seen during encoding
  Scenes.Not.Encoding %>%
    sample_n(size = 3) %>%
    pull(file) -> NovelLures

  # Pick 2 Familiar Lures from Scenes seen during encoding,
  # making sure to exclude the correct scene.
  # Also ensure that the familiar lures are drawn from the same
  # condition
  Encoding %>%
    filter(!(Scene %in% corScene)) %>%
    filter(Condition == condition) %>%
    sample_n(size = 2) %>%
    pull(Scene) -> FamiliarLures
  
  # concatenate
  ConcatenatedOptions <- c(NovelLures, FamiliarLures, corScene)

  # create a "wide" table
  tibble(SceneFiles = ConcatenatedOptions, RespOption = sample(1:6)) %>%
    arrange(RespOption) %>% 
    pivot_wider(names_from = RespOption, names_prefix = 'RespOption', values_from = SceneFiles) -> Out
  
  return(Out)
  
}

Retrieval %>%
  mutate(SceneChoices = map2(Scene, Condition, pick_scene_choices)) %>%
  unnest(SceneChoices) -> Retrieval

write.csv(x = Retrieval, file = 'retrieval.csv')
Retrieval %>%
  toJSON() %>%
  str_c('retrieval_data = ', .) %>% 
  write_lines(path = 'retrieval.js')