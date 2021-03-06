% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/densityPlot.R
\name{qqPlot}
\alias{qqPlot}
\title{Draw quantile-quantile plot}
\usage{
qqPlot(x, linecolor = "red", xlab = NULL, ylab = NULL, title = NULL, ...)
}
\arguments{
\item{x}{A numeric vector}

\item{linecolor}{character line color}

\item{xlab}{character label for x axis}

\item{ylab}{character label for y axis}

\item{title}{character label for plot title}

\item{...}{Further arguments to be passed to geom_qq()}
}
\description{
Draw quantile-quantile plot
}
\examples{
qqPlot(rnorm(200))
qqPlot(rt(200, df = 5))
}
