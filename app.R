library(shiny)
library(shinydashboard)
library(tidyverse)
library(DT)
library(glue)
library(ggrepel)
library(grid)
library(gridExtra)

# ==============================================================================
# 1. GLOBAL DEFINITIONS (Court Maps & Static Data)
# ==============================================================================

# Define Court Map for CPA (Phase 1 & 2)
map_phase1 <- tribble(
  ~Location,               ~x, ~y, ~Label,
  "Center Left Attack",     1,  2, "C Left (A)",
  "Center Mid Attack",      2,  2, "C Mid (A)",
  "Center Right Attack",    3,  2, "C Right (A)",
  "Center Left Defense",    1,  1, "C Left (D)",
  "Center Mid Defense",     2,  1, "C Mid (D)",
  "Center Right Defense",   3,  1, "C Right (D)"
)

map_phase2 <- tribble(
  ~Location,               ~x, ~y, ~Label,
  "Center Left Attack",     1,  2, "C Left (A)",
  "Center Mid Attack",      2,  2, "C Mid (A)",
  "Center Right Attack",    3,  2, "C Right (A)",
  "Center Left Defense",    1,  1, "C Left (D)",
  "Center Mid Defense",     2,  1, "C Mid (D)",
  "Center Right Defense",   3,  1, "C Right (D)",
  "Attacking Left",         1,  3, "Att Left",
  "Attacking Middle",       2,  3, "Att Mid",
  "Attacking Right",        3,  3, "Att Right",
  "Attacking Left Pocket",  1,  4, "AL Pocket",
  "Attacking D",            2,  4, "Att Circle",
  "Attacking Right Pocket", 3,  4, "AR Pocket"
)

# Define Physical Coordinates for Pass Map
zone_coords <- tribble(
  ~zone_name,               ~x,  ~y,
  "Center Left Defense",    20,  85,
  "Center Mid Defense",     50,  85,
  "Center Right Defense",   80,  85,
  "Center Left Attack",     20,  115,
  "Center Mid Attack",      50,  115,
  "Center Right Attack",    80,  115,
  "Attacking Left",         15,  160,
  "Attacking Middle",       50,  160,
  "Attacking Right",        85,  160,
  "Attacking Left Pocket",  10,  185,
  "Attacking Right Pocket", 90,  185,
  "Attacking D",            50,  180
)

# Define Court Map for GN/TO Heatmaps
court_map_gnto <- tribble(
  ~Location,                   ~x, ~y, ~Zone_Label,
  "Defensive Left Pocket",      1, 1, "DL Pocket",
  "Defensive D",                2, 1, "Def Circle",
  "Defensive Right Pocket",     3, 1, "DR Pocket",
  "Defensive Left",             1, 2, "Def Left",
  "Defensive Middle",           2, 2, "Def Mid",
  "Defensive Right",            3, 2, "Def Right",
  "Center Left Defense",        1, 3, "C Left (D)",
  "Center Mid Defense",         2, 3, "C Mid (D)",
  "Center Right Defense",       3, 3, "C Right (D)",
  "Center Left Attack",         1, 4, "C Left (A)",
  "Center Mid Attack",          2, 4, "C Mid (A)",
  "Center Right Attack",        3, 4, "C Right (A)",
  "Attacking Left",             1, 5, "Att Left",
  "Attacking Middle",           2, 5, "Att Mid",
  "Attacking Right",            3, 5, "Att Right",
  "Attacking Left Pocket",      1, 6, "AL Pocket",
  "Attacking D",                2, 6, "Att Circle",
  "Attacking Right Pocket",     3, 6, "AR Pocket"
)

# ==============================================================================
# 2. UI SECTION
# ==============================================================================
ui <- dashboardPage(
  skin = "red",
  dashboardHeader(title = "Netball Match Report"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Upload & Config", tabName = "setup", icon = icon("cogs")),
      menuItem("Match Summary", tabName = "summary", icon = icon("chart-line")),
      menuItem("Shooting Stats", tabName = "shooting", icon = icon("basketball-ball")),
      menuItem("Passing & CPA", tabName = "cpa", icon = icon("project-diagram")),
      menuItem("Defense (GN/TO)", tabName = "defense", icon = icon("shield-alt"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # --- TAB 1: SETUP ---
      tabItem(tabName = "setup",
              fluidRow(
                box(title = "Match Configuration", status = "primary", solidHeader = TRUE, width = 6,
                    fileInput("file1", "Upload Match CSV", accept = ".csv"),
                    textInput("team_name", "My Team Name", value = "Singapore"),
                    textInput("opp_name", "Opponent Name", value = "Malaysia"),
                    dateInput("match_date", "Match Date", value = Sys.Date()),
                    actionButton("process_btn", "Process Data", class = "btn-success")
                ),
                box(title = "Instructions", status = "warning", width = 6,
                    "1. Upload the CSV export from Hudl Sportscode.",
                    "2. Ensure the CSV has columns: 'Row', 'Quarter', 'Start time', etc.",
                    "3. Click 'Process Data' to generate the visuals."
                )
              )
      ),
      
      # --- TAB 2: SUMMARY ---
      tabItem(tabName = "summary",
              fluidRow(
                valueBoxOutput("total_goals_home", width = 6),
                valueBoxOutput("total_goals_away", width = 6)
              ),
              fluidRow(
                box(title = "Match Score Summary", status = "primary", width = 12,
                    DTOutput("score_table"))
              ),
              fluidRow(
                box(title = "Match Momentum", status = "primary", width = 12,
                    plotOutput("momentum_plot", height = "600px"))
              )
      ),
      
      # --- TAB 3: SHOOTING ---
      tabItem(tabName = "shooting",
              fluidRow(
                box(title = "Team Shooting Summary", width = 12, DTOutput("shooting_summary_table"))
              ),
              fluidRow(
                box(title = "Player Shooting Stats", width = 12, DTOutput("player_shooting_table"))
              )
      ),
      
      # --- TAB 4: CPA ---
      tabItem(tabName = "cpa",
              fluidRow(
                box(title = "Centre Pass Attack Summary", width = 12, DTOutput("cpa_summary_table"))
              ),
              fluidRow(
                box(title = "CPA Phase Heatmaps", width = 12, plotOutput("cpa_heatmaps", height = "600px"))
              ),
              fluidRow(
                box(title = "Pass Flow Map", width = 8, plotOutput("pass_flow_map", height = "600px")),
                box(title = "Top Combinations", width = 4, DTOutput("cpa_combo_table"))
              )
      ),
      
      # --- TAB 5: DEFENSE ---
      tabItem(tabName = "defense",
              fluidRow(
                box(title = "Gains & Turnovers Summary", width = 12, DTOutput("gnto_summary_table"))
              ),
              fluidRow(
                box(title = "Court Heatmap: Gains vs Turnovers", width = 12, plotOutput("gnto_heatmap", height = "500px"))
              ),
              fluidRow(
                box(title = "Reasons Breakdown", width = 12, plotOutput("gnto_reasons_plot", height = "400px"))
              )
      )
    )
  )
)

# ==============================================================================
# 3. SERVER SECTION
# ==============================================================================
server <- function(input, output, session) {
  
  # Reactive Value to store the cleaned data
  dataset <- reactiveVal()
  
  # Observe Process Button
  observeEvent(input$process_btn, {
    req(input$file1)
    
    # Read Data
    raw_data <- read_csv(input$file1$datapath)
    
    # 1. CLEAN DATA (Logic from Rmd)
    # Remove empty columns
    clean_data <- raw_data %>%
      select(-one_of(c("Ungrouped", "Notes", "Flags")[sapply(c("Ungrouped", "Notes", "Flags"), function(col) all(is.na(raw_data[[col]])))]))
    
    # Fix Quarters (Remove duplicate Q1, Q1...)
    clean_data <- clean_data %>%
      mutate(Quarter = str_trim(str_remove(Quarter, ",.*")))
    
    dataset(clean_data)
  })
  
  # ----------------------------------------------------------------------------
  # TAB 2: SUMMARY LOGIC
  # ----------------------------------------------------------------------------
  
  # Match Score Calculation
  score_data <- reactive({
    req(dataset())
    df <- dataset()
    
    get_q_scores <- function(d, row_filter, outcome_keyword) {
      d %>%
        filter(Row == row_filter) %>%
        mutate(Goals = str_count(`Shot Outcome`, outcome_keyword)) %>%
        group_by(Quarter) %>%
        summarise(Score = sum(Goals, na.rm = TRUE), .groups = "drop") %>%
        complete(Quarter = c("Q1", "Q2", "Q3", "Q4"), fill = list(Score = 0)) %>%
        pivot_wider(names_from = Quarter, values_from = Score)
    }
    
    sgp <- get_q_scores(df, "SGP Shot", "SGP Goal") %>% mutate(Team = input$team_name)
    opp <- get_q_scores(df, "OPP Shot", "OPP Goal") %>% mutate(Team = input$opp_name)
    
    bind_rows(sgp, opp) %>%
      rowwise() %>%
      mutate(Total = sum(c_across(Q1:Q4), na.rm = TRUE))
  })
  
  # Value Boxes
  output$total_goals_home <- renderValueBox({
    req(score_data())
    val <- score_data() %>% filter(Team == input$team_name) %>% pull(Total)
    valueBox(val, paste(input$team_name, "Score"), icon = icon("trophy"), color = "red")
  })
  
  output$total_goals_away <- renderValueBox({
    req(score_data())
    val <- score_data() %>% filter(Team == input$opp_name) %>% pull(Total)
    valueBox(val, paste(input$opp_name, "Score"), icon = icon("users"), color = "blue")
  })
  
  # Score Table
  output$score_table <- renderDT({
    req(score_data())
    datatable(score_data(), options = list(dom = 't'))
  })
  
  # Momentum Plot
  output$momentum_plot <- renderPlot({
    req(dataset())
    df <- dataset()
    team_n <- input$team_name
    opp_n <- input$opp_name
    
    # Prepare Goal Events
    goal_events <- df %>%
      filter(str_detect(Row, "Shot") & str_detect(`Shot Outcome`, "Goal")) %>%
      mutate(
        Scorer = ifelse(str_detect(`Shot Outcome`, "SGP Goal"), "SGP", "OPP"),
        Time = `Start time`
      ) %>%
      select(Quarter, Time, Scorer) %>%
      arrange(Quarter, Time)
    
    # Calculate Runs
    runs_data <- goal_events %>%
      group_by(Quarter) %>%
      mutate(Run_Group = cumsum(c(1, diff(as.numeric(factor(Scorer))) != 0))) %>%
      group_by(Quarter, Run_Group) %>%
      summarise(
        Scorer = first(Scorer),
        Run_Length = n(),
        Start_Time = min(Time),
        End_Time = max(Time),
        .groups = "drop"
      ) %>%
      filter(Run_Length >= 4)
    
    # Calculate Scores over time
    plot_data <- goal_events %>%
      group_by(Quarter) %>%
      mutate(
        SGP_Points = ifelse(Scorer == "SGP", 1, 0),
        OPP_Points = ifelse(Scorer == "OPP", 1, 0),
        Score_SGP = cumsum(SGP_Points),
        Score_OPP = cumsum(OPP_Points)
      ) %>%
      ungroup() %>%
      pivot_longer(cols = c(Score_SGP, Score_OPP), names_to = "TeamVar", values_to = "Score") %>%
      mutate(TeamDisplay = ifelse(TeamVar == "Score_SGP", team_n, opp_n))
    
    # Colors
    line_colors <- setNames(c("#E03C31", "#1D428A"), c(team_n, opp_n))
    fill_colors <- c("SGP" = "#ffcccc", "OPP" = "#cce5ff")
    
    # Plotting Loop for 4 Quarters
    q_plots <- lapply(c("Q1", "Q2", "Q3", "Q4"), function(q) {
      p_sub <- plot_data %>% filter(Quarter == q)
      r_sub <- runs_data %>% filter(Quarter == q)
      
      ggplot() +
        geom_rect(data = r_sub, aes(xmin = Start_Time, xmax = End_Time, ymin = -Inf, ymax = Inf, fill = Scorer), alpha = 0.5) +
        geom_step(data = p_sub, aes(x = Time, y = Score, color = TeamDisplay), size = 1) +
        scale_color_manual(values = line_colors) +
        scale_fill_manual(values = fill_colors) +
        theme_classic() +
        labs(title = paste("Momentum:", q), x = "Time", y = "Score") +
        theme(legend.position = "none")
    })
    
    grid.arrange(grobs = q_plots, ncol = 2)
  })
  
  # ----------------------------------------------------------------------------
  # TAB 3: SHOOTING LOGIC
  # ----------------------------------------------------------------------------
  output$shooting_summary_table <- renderDT({
    req(dataset())
    df <- dataset()
    
    # Calculation Logic (Simplified from Rmd)
    stats <- df %>%
      filter(Row == "SGP Shot") %>%
      group_by(Quarter) %>%
      summarise(
        Attempts = n(),
        Goals = sum(str_detect(`Shot Outcome`, "Goal"), na.rm = TRUE)
      ) %>%
      bind_rows(summarise(., Quarter = "Total", Attempts = sum(Attempts), Goals = sum(Goals))) %>%
      mutate(Pct = ifelse(Attempts > 0, round((Goals/Attempts)*100, 1), 0))
    
    datatable(stats, options = list(dom = 't')) %>%
      formatStyle(
        'Pct',
        backgroundColor = styleInterval(c(80, 90), c('#E67C73', '#F4B400', '#57BB8A')), # Red, Yellow, Green
        fontWeight = 'bold'
      )
  })
  
  output$player_shooting_table <- renderDT({
    req(dataset())
    df <- dataset()
    
    stats <- df %>%
      filter(Row == "SGP Shot") %>%
      separate_rows(Player, sep = ",\\s*") %>%
      group_by(Player) %>%
      summarise(
        Attempts = n(),
        Goals = sum(str_detect(`Shot Outcome`, "Goal"), na.rm = TRUE)
      ) %>%
      mutate(Pct = ifelse(Attempts > 0, round((Goals/Attempts)*100, 1), 0)) %>%
      arrange(desc(Goals))
    
    datatable(stats) %>%
      formatStyle('Pct', backgroundColor = styleInterval(c(80, 90), c('#E67C73', '#F4B400', '#57BB8A')))
  })
  
  # ----------------------------------------------------------------------------
  # TAB 4: CPA LOGIC
  # ----------------------------------------------------------------------------
  
  output$cpa_summary_table <- renderDT({
    req(dataset())
    df <- dataset()
    
    # Logic for CPA
    calc_cpa <- function(d, r_filter, goal_key) {
      d %>%
        filter(Row == r_filter) %>%
        group_by(Quarter) %>%
        summarise(Poss = n(), Goals = sum(str_detect(`Shot Outcome`, goal_key), na.rm=T)) %>%
        bind_rows(summarise(., Quarter="Total", Poss=sum(Poss), Goals=sum(Goals))) %>%
        mutate(Conv = ifelse(Poss > 0, round((Goals/Poss)*100, 1), 0))
    }
    
    cpa <- calc_cpa(df, "SGP CPA", "SGP Goal") %>% mutate(Type = "CPA")
    dcpa <- calc_cpa(df, "SGP DCPA", "SGP Goal") %>% mutate(Type = "DCPA")
    
    res <- bind_rows(cpa, dcpa) %>% select(Type, Quarter, Poss, Goals, Conv)
    
    datatable(res) %>%
      formatStyle('Conv', backgroundColor = styleInterval(c(75, 80), c('#E67C73', '#F4B400', '#57BB8A')))
  })
  
  # CPA Heatmaps
  output$cpa_heatmaps <- renderPlot({
    req(dataset())
    df <- dataset()
    
    # Helper to count location
    get_loc_counts <- function(d, pass_ptrn, map_df) {
      col_name <- names(d)[str_detect(names(d), regex(pass_ptrn, ignore_case=T))][1]
      if(is.na(col_name)) return(map_df %>% mutate(Count=0))
      
      d %>% filter(Row == "SGP CPA") %>%
        separate_rows(!!sym(col_name), sep=",\\s*") %>%
        mutate(Location = str_trim(!!sym(col_name))) %>%
        group_by(Location) %>% summarise(Count=n()) %>%
        right_join(map_df, by="Location") %>% replace_na(list(Count=0))
    }
    
    p1_data <- get_loc_counts(df, "1st.*Pass", map_phase1)
    p2_data <- get_loc_counts(df, "2nd.*Pass", map_phase2)
    
    # Plot Function
    plot_map <- function(data, title) {
      ggplot(data, aes(x=x, y=y, fill=Count)) +
        geom_tile(color="black") +
        geom_text(aes(label=Count), color="white", fontface="bold", size=5) +
        geom_text(aes(label=Label), color="black", vjust=2, size=3) +
        scale_fill_gradient(low="white", high="#b30000") +
        coord_fixed() + theme_void() + labs(title=title) + theme(legend.position="none")
    }
    
    grid.arrange(plot_map(p1_data, "Phase 1"), plot_map(p2_data, "Phase 2"), ncol=2)
  })
  
  # Pass Flow Map
  output$pass_flow_map <- renderPlot({
    req(dataset())
    df <- dataset()
    
    # Find columns
    col_pass1 <- names(df)[str_detect(names(df), regex("1st.*Pass", ignore_case=T))][1]
    col_pass2 <- names(df)[str_detect(names(df), regex("2nd.*Pass", ignore_case=T))][1]
    
    if(!is.na(col_pass1) & !is.na(col_pass2)) {
      pass_flows <- df %>%
        filter(Row == "SGP CPA") %>%
        select(P1 = !!sym(col_pass1), P2 = !!sym(col_pass2)) %>%
        separate_rows(P1, sep=",\\s*") %>% separate_rows(P2, sep=",\\s*") %>%
        mutate(P1=str_trim(P1), P2=str_trim(P2)) %>%
        filter(P1 != "", P2 != "", P1 != P2) %>%
        count(P1, P2, name="Frequency") %>%
        arrange(desc(Frequency)) %>%
        mutate(Rank = row_number()) %>%
        left_join(zone_coords, by=c("P1"="zone_name")) %>% rename(x1=x, y1=y) %>%
        left_join(zone_coords, by=c("P2"="zone_name")) %>% rename(x2=x, y2=y)
      
      ggplot() +
        annotate("rect", xmin=0, xmax=100, ymin=0, ymax=200, fill="white", color="black") +
        annotate("segment", x=0, xend=100, y=66.6, yend=66.6, color="grey") +
        annotate("segment", x=0, xend=100, y=133.3, yend=133.3, color="grey") +
        geom_curve(data=pass_flows, aes(x=x1, y=y1, xend=x2, yend=y2, linewidth=Frequency, alpha=Frequency),
                   arrow=arrow(length=unit(0.3,"cm")), color="#800000", curvature=-0.2) +
        geom_text(data=zone_coords, aes(x=x, y=y, label=str_wrap(zone_name, 10)), size=3, color="grey60") +
        coord_fixed() + theme_void() + labs(title="Top CPA Links")
    }
  })
  
  # Top Combos Table
  output$cpa_combo_table <- renderDT({
    req(dataset())
    df <- dataset()
    # Find columns
    col_1 <- names(df)[str_detect(names(df), regex("1st.*Receiver", ignore_case=T))][1]
    col_2 <- names(df)[str_detect(names(df), regex("2nd.*Receiver", ignore_case=T))][1]
    
    if(!is.na(col_1) & !is.na(col_2)) {
      df %>%
        filter(Row == "SGP CPA") %>%
        select(R1 = !!sym(col_1), R2 = !!sym(col_2)) %>%
        separate_rows(R1, sep=",\\s*") %>% separate_rows(R2, sep=",\\s*") %>%
        mutate(Combo = paste(str_trim(R1), "-", str_trim(R2))) %>%
        count(Combo, name="Freq") %>%
        arrange(desc(Freq)) %>%
        head(5) %>%
        datatable(options = list(dom='t'))
    }
  })
  
  # ----------------------------------------------------------------------------
  # TAB 5: DEFENSE LOGIC
  # ----------------------------------------------------------------------------
  output$gnto_summary_table <- renderDT({
    req(dataset())
    df <- dataset()
    
    stats <- df %>%
      filter(Row %in% c("SGP Gains", "SGP Turnovers")) %>%
      group_by(Row) %>%
      summarise(Count = n())
    
    datatable(stats, options = list(dom='t'))
  })
  
  output$gnto_heatmap <- renderPlot({
    req(dataset())
    df <- dataset()
    
    # Helper for Heatmap
    gen_hm <- function(r_filter, title, low_c, high_c) {
      loc_data <- df %>%
        filter(Row == r_filter) %>%
        separate_rows(`Turnover Location`, sep=",\\s*") %>%
        mutate(Location = str_trim(`Turnover Location`)) %>%
        count(Location, name="Count") %>%
        right_join(court_map_gnto, by="Location") %>% replace_na(list(Count=0))
      
      ggplot(loc_data, aes(x=x, y=y, fill=Count)) +
        geom_tile(color="white") +
        geom_text(aes(label=ifelse(Count>0, Count, "")), fontface="bold") +
        geom_hline(yintercept = c(2.5, 4.5)) +
        scale_fill_gradient(low=low_c, high=high_c) +
        coord_fixed() + theme_void() + labs(title=title) + theme(legend.position="none")
    }
    
    p1 <- gen_hm("SGP Gains", "Gains", "#e5f5e0", "#31a354")
    p2 <- gen_hm("SGP Turnovers", "Turnovers", "#fee0d2", "#de2d26")
    
    grid.arrange(p1, p2, ncol=2)
  })
  
  output$gnto_reasons_plot <- renderPlot({
    req(dataset())
    df <- dataset()
    
    reasons <- df %>%
      filter(Row %in% c("SGP Gains", "SGP Turnovers")) %>%
      separate_rows(`Gains / Turnover Reason`, sep=",\\s*") %>%
      mutate(Reason = str_trim(`Gains / Turnover Reason`)) %>%
      filter(Reason != "", !is.na(Reason)) %>%
      count(Row, Reason)
    
    ggplot(reasons, aes(x=n, y=reorder(Reason, n), fill=Row)) +
      geom_col(position="dodge") +
      scale_fill_manual(values=c("SGP Gains"="#57BB8A", "SGP Turnovers"="#E67C73")) +
      theme_minimal() + labs(x="Count", y="", fill="")
  })
  
}

# Run the Application
shinyApp(ui = ui, server = server)