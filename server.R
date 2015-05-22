# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://www.rstudio.com/shiny/
#

# needed libraries:
library(shiny)
library(ggplot2)

fit <- NULL   # will contain the multivariate regression model

shinyServer(function(input, output) {
    ##
    ## "global" objects:
    ##
    # the name of the dataset
    dataset_name <- reactive({
        if (input$DS == "") "nothing selected" else input$DS
    })
    # NOTE: this is where the dataset gets loaded!
    # this is a "hidden" widget whose purpose is to just get the selected dataset
    output$selectedDS <- renderUI({
        if (input$DS=="") myDS <<- NULL
        else
            myDS <<- get(input$DS)
        NULL # always return nothing to display
    })

    ##
    ## objects for the panel datasetOverview:
    ##
    # quick summary of the dataset:
    output$summary <- renderDataTable({
        if (input$DS=="") NULL
        else summary(myDS)
    }, options=list(pageLength=10, paging=FALSE, searching=FALSE))

    output$myDS  <- renderText(dataset_name())

    ##
    ## objects for the panel datasetNavigation:
    ##
    # interactive table, to allow for dataset navigation:
    output$dataset <- renderDataTable({
        if (input$DS == "") NULL else myDS
    }, options=list(pageLength=10))

    # simple HTML table with dataset info:
    output$tableinfo <- renderTable({
        if (input$DS == "") NULL
        else {
            myInfo<-as.data.frame(col.names = c('var','value'),x=NULL)
            myInfo<-rbind(myInfo,
                          list(var='cols', value=ncol(myDS)),
                          list(var='rows', value=nrow(myDS)),
                          list(var='rows with NA',
                               value=sum(!complete.cases(myDS)))
                          )

            myInfo
        }
    }, include.rownames=FALSE) # do not print the first column (with row names)

    ##
    ## objects for the panel exploratoryAnalysis1:
    ##
    # the name of the dataset variable being analysed:
    var_name <- reactive({
        if (input$DS=="") "select a dataset first!"
        else if (is.null(input$var)) "select a variable first!"
        else {
            t <- paste(input$DS,input$var,sep=':')
            if (!is.null(input$facet) && input$facet != '(none)')
                t <- paste(t, 'by', input$facet)
            t
        }
    })
    output$myVar <- renderText(var_name())

    # the selection box with the dataset variables - this has to be built
    # "reactively" because myDS changes!
    output$varSelector <- renderUI({
        if (input$DS=="") NULL
        else
            selectInput(inputId = 'var', label = paste(input$DS, 'variables:'),
                        choices = sort(colnames(myDS)),
                        multiple = FALSE, size=5, selectize = FALSE, selected=NULL)
    })

    # and the same for the facet chooser:
    output$facetSelector <- renderUI({
        if (input$DS=="") NULL
        else
            selectInput(inputId = 'facet', label = paste(input$DS, 'facets:'),
                        choices = c('(none)', sort(colnames(myDS))),
                        multiple = FALSE, size=5, selectize = FALSE, selected=NULL)
    })

    # and eventually the multi-variable color:
    output$colorSelector <- renderUI({
        if (input$DS=="") NULL
        else
            selectInput(inputId = 'color', label = paste(input$DS, 'color:'),
                        choices = c('(none)', sort(colnames(myDS))),
                        multiple = FALSE, size=5, selectize = FALSE, selected=NULL)
    })

    # the exploratory plots:
    myVar   <- reactive(input$var)
    myFacet <- reactive(input$facet)
    myColor <- reactive({
        if (is.null(input$color) || input$color=='(none)') NULL
        else
            if (input$isCOLORfactor) paste0('factor(',input$color,')')
            else input$color
    })

    output$expPlot <- renderPlot({
        if (input$DS=="" || is.null(input$var)) NULL
        else {
            s=paste0('mean(',input$var,')') # string used later in geom_vline()
            G1<-ggplot(myDS, aes_string(x=myVar())) +
                geom_density(color='blue') +
                geom_vline(aes_string(xintercept=s), color='red') +
                ggtitle(label = paste('Density function of',input$var))

            G2<-ggplot(myDS, aes_string(x=myVar(),fill=myColor())) +
                geom_histogram() +
                geom_vline(aes_string(xintercept=s), color='red') +
                ggtitle(label = paste('Histogram of',input$var))

            if (!is.null(input$facet) && input$facet != '(none)') {
                G1 = G1 + facet_grid(as.formula(paste('. ~',myFacet())))
                G2 = G2 + facet_grid(as.formula(paste('. ~',myFacet())))
            }

            multiplot(G1, G2, cols=2)
        }
    })

    ##
    ## objects for the panel exploratoryAnalysis2:
    ##
    # other reactive UIs:
    # the name of the datasets variable being correlated:
    xy_name <- reactive({
            if (input$DS=="") "select a dataset first!"
            else if (is.null(input$xvar) || is.null(input$yvar))
                    "select both X and Y variables first!"
            else {
                t <- paste0(input$DS,':',input$yvar,' vs ',input$xvar)
                if (!is.null(input$xyfacet) && input$xyfacet != '(none)')
                    t <- paste(t, 'by', input$xyfacet)
                t
            }
    })
    output$XYvars <- renderText(xy_name())

    output$var1Selector <- renderUI({
        if (input$DS=="") NULL
        else
            selectInput(inputId = 'xvar', label = paste(input$DS, 'X-variable:'),
                        choices = sort(colnames(myDS)),
                        multiple = FALSE, size=5, selectize = FALSE, selected=NULL)
    })

    output$var2Selector <- renderUI({
        if (input$DS=="") NULL
        else
            selectInput(inputId = 'yvar', label = paste(input$DS, 'Y-variable:'),
                        choices = sort(colnames(myDS)),
                        multiple = FALSE, size=5, selectize = FALSE, selected=NULL)
    })

    # again, facet and color choosers:
    output$xyfacetSelector <- renderUI({
        if (input$DS=="") NULL
        else
            selectInput(inputId = 'xyfacet', label = paste(input$DS, 'facets:'),
                        choices = c('(none)', sort(colnames(myDS))),
                        multiple = FALSE, size=5, selectize = FALSE, selected=NULL)
    })

    output$xycolorSelector <- renderUI({
        if (input$DS=="") NULL
        else
            selectInput(inputId = 'xycolor', label = paste(input$DS, 'color:'),
                        choices = c('(none)', sort(colnames(myDS))),
                        multiple = FALSE, size=5, selectize = FALSE, selected=NULL)
    })

    myXvar <- reactive(input$xvar)
    myYvar <- reactive(input$yvar)
    myXYFacet <- reactive(input$xyfacet)
    myXYColor <- reactive({
        if (is.null(input$xycolor) || input$xycolor=='(none)') NULL
        else
            if (input$isXYCOLORfactor) paste0('factor(',input$xycolor,')')
            else input$xycolor
    })

    # the regression plots:
    output$regPlot <- renderPlot({
        if (input$DS=="" || is.null(input$xvar) || is.null(input$yvar)) NULL
        else {
            G1<-ggplot(myDS, aes_string(x=myXvar(),y=myYvar())) +
                geom_smooth()
            # + ggtitle(label = paste(input$yvar,'vs',input$xvar))

            G2<-ggplot(myDS, aes_string(x=myXvar(),y=myYvar(),fill=myXYColor())) +
                geom_boxplot()
            # + ggtitle(label = paste(input$yvar,'vs',input$xvar))

            if (!is.null(input$xyfacet) && input$xyfacet != '(none)') {
                G1 = G1 + facet_grid(as.formula(paste('. ~',myXYFacet())))
                G2 = G2 + facet_grid(as.formula(paste('. ~',myXYFacet())))
            }

            multiplot(G1, G2, cols=2)
        }
    })

    ##
    ## objects for the panel regressionAnalysis:
    ##
    # other reactive UIs:
    # the name of the datasets variable being approximated:
    regY_name <- reactive({
        if (input$DS=="") "select a dataset first!"
        else if (is.null(input$regY) || is.null(input$regY))
            "select Y variable first!"
        else if (is.null(input$regXvars) || is.null(input$regXvars))
            "select the X-variables first!"
        else {
            t <- paste0(input$DS,':',input$regY,' vs (',
                        paste0(input$regXvars, collapse=','), ')')
            t
        }
    })
    output$YvsVars <- renderText(regY_name())

    output$regYselector <- renderUI({
        if (input$DS=="") NULL
        else
            selectInput(inputId = 'regY', label = paste(input$DS, 'Y-variable:'),
                        choices = sort(colnames(myDS)),
                        multiple = FALSE, size=5, selectize = FALSE, selected=NULL)
    })

    output$regXvarsSelector <- renderUI({
        if (input$DS=="") NULL
        else
            selectInput(inputId = 'regXvars', label = paste(input$DS, 'X-variables:'),
                        choices = sort(colnames(myDS)[-which(colnames(myDS)==input$regY)]),
                        multiple = TRUE, size=10, selectize = FALSE, selected=NULL)
    })

    # the multilinear regression plot:
    output$multiLinearPlot <- renderPlot({
        if (input$DS=="" || is.null(input$regXvars)) NULL
        else {
            fit <<- lm(formula = as.formula(paste(input$regY, '~',
                                                  paste0(input$regXvars,collapse='+'))),
                       data = myDS)

            # plot the residuals:
            par(mfrow=c(2,2))
            plot(fit)
        }
    })

    # the model summary:
    output$fitSummary <- renderPrint({
        if (input$DS=="" || is.null(input$regXvars)) 'No model defined yet'
        else {
            summary(fit)
        }
    })

    # and the analysis of the variance table:
    output$anova <- renderPrint({
        if (input$DS=="" || is.null(input$regXvars)) 'No model defined yet'
        else {
            anova(fit)
        }
    })
})

