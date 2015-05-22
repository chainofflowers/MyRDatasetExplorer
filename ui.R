# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://www.rstudio.com/shiny/
#

library(shiny)

datasetOverview <-pageWithSidebar(
    headerPanel(h2('Dataset Summary')),
    sidebarPanel(h5("Select a dataset from the list to begin your exploration!",
                    "You will immediately get a summary of the data contained."),
                 width=3),
    mainPanel(selectizeInput('DS', 'Input Dataset:', choices=availableDS,
                             options=list(placeholder = 'Select a dataset from the list below',
                                          onInitialize = I('function() { this.setValue(""); }'))),
              uiOutput('selectedDS'),dataTableOutput('summary'))
)

datasetNavigation <- pageWithSidebar(
    headerPanel(h2(textOutput('myDS'))),
    sidebarPanel(h5("Here you can get a quick look at the dataset.",
                    "You can navigate the dataset in the interactive table on the right,",
                    "and see quick info in the table below."),
                 tableOutput('tableinfo'),width=3),
    mainPanel(dataTableOutput('dataset'))
)

exploratoryAnalysis1 <- pageWithSidebar(
    headerPanel(h2(textOutput('myVar'))),
    sidebarPanel(h5('Here you can choose a variable',
                    'to explore its density function and histogram.'),
                 # reactive UIs: see comments in server.R!
                 uiOutput('varSelector'),
                 h5('You can also select a second variable to be used as facet,',
                    'so to identify some patterns between the two.'),
                 uiOutput('facetSelector'),
                 h5('Finally, you can choose a third variable whose values',
                    'will be used to colorize the plots, so that you can spot',
                    'even more relationships in your analysis.',
                    'If you want to use this variable as a factor, please check the box.'),
                 uiOutput('colorSelector'),checkboxInput('isCOLORfactor','as factor', F),
                 width=3),
    mainPanel(helpText("The vertical red intercept indicates the mean."),
              plotOutput('expPlot'))
)

exploratoryAnalysis2 <- pageWithSidebar(
    headerPanel(h2(textOutput('XYvars'))),
    sidebarPanel(h5('Choose a pair of variables to investigate their relationship:'),
                 # reactive UIs: see comments in server.R!
                 uiOutput('var2Selector'),
                 uiOutput('var1Selector'),
                 h5('You can also select a facet variable.'),
                 uiOutput('xyfacetSelector'),
                 h5('Finally, you can choose a variable for coloring the plots.',
                    'If you want to use this variable as a factor, please check the box.'),
                 uiOutput('xycolorSelector'), checkboxInput('isXYCOLORfactor','as factor', F),
                 width=3),
    mainPanel(plotOutput('regPlot'))
)

regressionAnalysis <- pageWithSidebar(
    headerPanel(h2(textOutput('YvsVars'))),
    sidebarPanel(h5('Choose a variable to investigate:'),
                 uiOutput('regYselector'),
                 h5('Choose the variables to be included in the regression model.',
                    'Drag the mouse or use CTRL or SHIFT to select multiple entries'),
                 uiOutput('regXvarsSelector'),
                 width=3),
    mainPanel(helpText('The residuals of your model are plotted here.'),
              plotOutput('multiLinearPlot'),
              helpText('Here follow some info about the model.'),
              verbatimTextOutput('fitSummary'),
              helpText('Here is the analysis of the variance table.'),
              verbatimTextOutput('anova'))
)


helpTab <- fluidPage(
    h2('Help'),
    hr(),
    helpText('This application aims to help you with the exploration of R datasets.',
             'It is part of the course project for the', tags$i('Developing Data Products'),
             'course on', tags$a(href='http://www.coursera.org','Coursera'),'.'),
    helpText('You start with the selection of the dataset in the first tab',
             tags$i('(Dataset Overview)'),'by selecting a dataset from the ones',
             'proposed in the drop-down box:'),
    img(src='img/select.jpg'),
    helpText('As soon as you select a dataset, a summary of its data is immediately displayed.'),
    helpText('Each tab has a side panel on the left with some explanatory text,',
             'that should provide enough guidance to use the function of that tab.'),
    img(src='img/sidePanel.jpg'),
    helpText('You can navigate the whole dataset in the',tags$i('Data Navigation'), 'tab.'),
    helpText('You can then move to other tabs, where you have the possibility to',
             'create some exploratory plots involving all of the variables in the',
             'dataset.'),
    img(src='img/histPlot.jpg'), img(src='img/vsPlot.jpg'),
    helpText('The', tags$i('Regression Analysis'), 'tab gives you the chance to',
             'experiment a bit with multivariate linear regression models and',
             'their residual plots.'),
    img(src='img/regModel.jpg'),
    helpText('Please refer to the explanatory text in the side panels',
             'to get further directions.'),
    hr(),
    h5('Note:'),
    helpText('This simple tool is intended to act as a quick browser for some of the',
             'standard datasets available in R. It is designed to provide a versatile',
             'means, like plot and facets, to explore the relationships between the',
             'dataset variables, but can run into problems when, for example, you try to',
             'use a combination of variables in a plot that causes illegal actions in R,',
             'like divisions by zero or some other unexpected behaviour in ggplot.'),
    helpText('Therefore,', tags$b('you should expect some errors'),
             'to occur when certain combinations of variables are selected.',
             'Actually, this is what would happen if you try to perform the same',
             'operations in R yourself! And that is exactly what the tool is intended',
             'to replicate - although an improved version could',
             'even provide some guidance in such situations and thus be used',
             'for training.'),
    helpText('Moreover, in some cases the application can crash: alhough the shiny',
             'framework is very robust and traps the most of the errors, under',
             'certain circumstances the application crashes and you need to refresh',
             'the browser page to restart. This is something that has to be fixed',
             'at application level, one cannot obviously expect the framework to take',
             'care of everything automatically. Please consider this as part of',
             'the improvements mentioned above ;-)'),
    helpText('Please consider this tool just as a', tags$i('simulator'),
             'of the standard operations for the exploratory actions that you would',
             'usually perform when looking at a dataset! ;-)')
)

mainPage <- navbarPage(
    title = 'The R Dataset Explorer',
    tabPanel('Dataset Overview', datasetOverview),
    tabPanel('Data Navigation', datasetNavigation),
    tabPanel('Exploratory Analysis I', exploratoryAnalysis1),
    tabPanel('Exploratory Analysis II', exploratoryAnalysis2),
    tabPanel('Regression Analysis', regressionAnalysis),
    tabPanel('Help me!', helpTab)
)

shinyUI(mainPage)
