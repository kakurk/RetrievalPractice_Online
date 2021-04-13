pick_scene_choices <- function(corScene, condition){
  # pick 6 scenes as choices for the 6 AFC
  
  FortyScenes %>%
    pull(file) -> ConcatenatedOptions
  
  # create a "wide" table
  tibble(SceneFiles = ConcatenatedOptions, RespOption = sample(1:6)) %>%
    arrange(RespOption) %>% 
    pivot_wider(names_from = RespOption, names_prefix = 'RespOption', values_from = SceneFiles) -> Out
  
  return(Out)
  
}