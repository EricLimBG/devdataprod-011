
# Load R Libraries
library(shiny)
library(ggplot2)
library(dplyr)
library(mapproj)
library(maps)

# Load Dataset (one-time)
states_map<-map_data("state")
rawdata<-read.csv('data/usstormdata.csv') %>% mutate(EVTYPE=tolower(EVTYPE))
evtypes<-sort(unique(rawdata$EVTYPE))

# Code for Shiny Server
shinyServer(function(input, output, session) {
    
    # Define and Initialize Reactive Values
    selections<-reactiveValues()
    selections$evtypes<-evtypes
    
    # Define Storm Type Control
    output$stormtypes <- renderUI({
        checkboxGroupInput('evtypes','Event Types', 
                           evtypes,selected=selections$evtypes)
    })
    
    # Set Observers for Selection Buttons
    observe({if(input$select_all==0) return() 
             else selections$evtypes<-evtypes})

    observe({if(input$clear_all==0) return()
             else selections$evtypes<-c()})
    
    # Prepare and Aggregate Dataset
    filterdata <- reactive({
        replace_na <- function(x) ifelse(is.na(x), 0, x)
        round_2 <- function(x) round(x, 2)
        aggregated <- rawdata %>% filter(YEAR>=input$period[1],
                                         YEAR<=input$period[2],
                                         EVTYPE %in% input$evtypes) %>%
            group_by(STATE) %>%
            summarise_each(funs(sum), FATALITIES:CROPDMG) %>%
            mutate_each(funs(replace_na),FATALITIES:CROPDMG) %>%
            mutate_each(funs(round_2),PROPDMG,CROPDMG)
        
    })
    
    # Compute Data and Output Plot
    output$PlotImpact <- renderPlot({
        # Compute Plot Variables
        pCategory<-input$impactCategory
        ptitle<-{if(pCategory=='injuries') 
                    {"Population Injuries %d - %d (number affected)"} 
                else if(pCategory=='fatalities') 
                    {"Population Fatalities %d - %d (number affected)"} 
                else
                    {"Economic Damages (USD) %d - %d ('Million)"}
                }
        ptitle<-sprintf(ptitle,input$period[1],input$period[2])
        # Compute Plot Data
        plotdata<-filterdata() %>% 
            mutate(Impact={
                if(pCategory=='injuries') {INJURIES} 
                else if(pCategory=='fatalities') {FATALITIES} 
                else {PROPDMG+CROPDMG}
            })
        
        #Print/Output Plot
        p <- ggplot(plotdata,aes(map_id=STATE))
        p <- p + geom_map(aes_string(fill="Impact"),map=states_map,colour='black')
        p <- p + expand_limits(x=states_map$long,y=states_map$lat)
        p <- p + coord_map() + theme_bw()
        p <- p + labs(x="Long",y="Lat",title=ptitle)
        print(p)     
    })
    
})
