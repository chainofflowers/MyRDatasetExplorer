# Global variable visible to both ui.R and server.R

# set here the datasets to display.
# "unique" is there just because I'm forward-looking... ;-)
availableDS <- unique(sort(c('mtcars','iris','ToothGrowth')))

myDS  <- NULL          # the dataset being currently explored


# multiplot function, in the flavour available here.
# http://www.peterhaschke.com/r/2013/04/24/MultiPlot.html
multiplot <- function(..., plotlist = NULL, file, cols = 1, layout = NULL) {
    require(grid)

    plots <- c(list(...), plotlist)

    numPlots = length(plots)

    if (is.null(layout)) {
        layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                         ncol = cols, nrow = ceiling(numPlots/cols))
    }

    if (numPlots == 1) {
        print(plots[[1]])

    } else {
        grid.newpage()
        pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))

        for (i in 1:numPlots) {
            matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))

            print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                            layout.pos.col = matchidx$col))
        }
    }
}
