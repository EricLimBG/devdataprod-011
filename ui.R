
# Load R Libraries
library(shiny)
library(markdown)

# Code for Shiny UI
shinyUI(
    navbarPage("Severe Weather Events in USA",
        tabPanel("Dashboard",
                mainPanel(
                    column(6,wellPanel(
                        sliderInput("period","Period",min=1950,max=2011,
                                    sep="",value=c(2001,2011))
                    )),
                    column(6,wellPanel(
                        radioButtons(inputId="impactCategory",
                                     label="Impact category",
                                     choices=c("Injuries"="injuries",
                                               "Fatalities"="fatalities",
                                               "Damages"="damages"))
                    )),
                    column(12,plotOutput("PlotImpact"))
                ),               
                sidebarPanel(
                    actionButton(inputId="select_all",label="Select All"),
                    actionButton(inputId="clear_all",label="Clear All"),
                    uiOutput("stormtypes")
                )
        ),
        tabPanel("About",mainPanel(includeMarkdown("README.md"))),
        tabPanel("Help",mainPanel(includeMarkdown("HELP.md")))
    )
)
