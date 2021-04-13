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