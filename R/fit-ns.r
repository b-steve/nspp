#' Fitting a Neyman-Scott point process model
#'
#' Estimates parameters for a Neyman-Scott point process by maximising
#' the Palm likelihood. This approach was first proposed by Tanaka et
#' al. (2008) for two-dimensional Thomas processes. Further
#' generalisations were made by Stevenson, Borchers, and Fewster (in
#' prep) and Jones-Todd (2017).
#' 
#' The parameter \code{D} is the density of parent points, which is
#' always estimated. Possible additional parameters are
#' \itemize{
#'   \item \code{lambda}, the expected number of children generated per
#'         parent (when \code{child.dist = "pois"}).
#' 
#'   \item \code{p}, the proportion of the \code{x} possible children
#'         are generated (when \code{child.dist = "binomx"}).
#'
#'   \item \code{kappa}, the average length of the surface phase of a
#'         diving cetacean (when \code{child.dist = "twoplane"}; see
#'         Stevenson, Borchers, and Fewster, in prep).
#'
#'   \item \code{sigma}, the standard deviation of dispersion along
#'         each dimension (when \code{disp} = "gaussian").
#'
#'   \item \code{tau}, the maximum distance a child can be from its
#'         parent (when \code{disp} = "uniform").
#'
#' }
#'
#' The \code{"child.info"} argument is required when \code{child.dist}
#' is set to \code{"twoplane"}. It must be a list that comprises (i) a
#' component named \code{w}, providing the halfwidth of the detection
#' zone; (ii) a component named \code{b}, providing the halfwidth of
#' the survey area; (iii) a component named \code{l}, providing the
#' time lag between planes (in seconds); and (iv) a component named
#' \code{tau}, providing the mean dive-cycle duration. See Stevenson,
#' Borchers, and Fewster (in prep) for details.
#'
#' @references Tanaka, U., Ogata, Y., and Stoyan, D. (2008) Parameter
#'     estimation and model selection for Neyman-Scott point
#'     processes. \emph{Biometrical Journal}, \strong{50}: 43--57.
#' @references Stevenson, B. C., Borchers, D. L., and Fewster,
#'     R. M. (in prep) Trace-contrast methods to account for
#'     identification uncertainty on aerial surveys of cetacean
#'     populations.
#' @references Jones-Todd, C. M. (2017) \emph{Modelling complex
#'     dependencies inherent in spatial and spatio-temporal point
#'     pattern data}. PhD thesis, University of St Andrews.
#'
#' @param points A matrix containing locations of observed points,
#'     where each row corresponds to a point and each column
#'     corresponds to a dimension.
#' @param lims A matrix with two columns, corresponding to the upper
#'     and lower limits of each dimension, respectively.
#' @param disp A character string indicating the distribution of
#'     children around their parents. Use \code{"gaussian"} for
#'     multivariate normal dispersion with standard deviation
#'     \code{sigma}, or \code{"uniform"} for uniform dispersion within
#'     distance \code{tau} of the parent.
#' @param R Truncation distance for the difference process.
#' @param child.dist The distribution of the number of children
#'     generated by a randomly selected parent. For a Poisson
#'     distribution, use \code{"pois"}; for a binomial distribution,
#'     use \code{"binomx"}, where \code{"x"} is replaced by the fixed
#'     value of the number of independent trials (e.g.,
#'     \code{"binom5"} for a Binomial(5, p) distribution, and
#'     \code{"binom50"} for a Binomial(50, p) distribution); and
#'     \code{"twoplane"} for a child distribution appropriate for a
#'     two-plane aerial survey.
#' @param child.info A list of further information that is required
#'     about the distribution for the number of children generated by
#'     parents. See `Details'.
#' @param sibling.list An optional list that comprises (i) a component
#'     named \code{sibling.mat}, containing a matrix such that the jth
#'     entry in the ith row is \code{TRUE} if the ith and jth points
#'     are known siblings, \code{FALSE} if they are known nonsiblings,
#'     and \code{NA} if their sibling status is not known; (ii) alpha,
#'     providing the probability that a sibling is successfully
#'     identified as a sibling; and (iii) beta, providing the
#'     probability that a nonsibling is successfully identified as a
#'     nonsibling.
#' @param edge.correction The method used for the correction of edge
#'     effects. Either \code{"pbc"} for periodic boundary conditions,
#'     or \code{"buffer"} for a buffer-zone correction.
#' @param start A named vector of starting values for the model
#'     parameters.
#' @param bounds A list with named components. Each component should
#'     be a vector of length two, giving the upper and lower bounds
#'     for the named parameter.
#' @param trace Logical; if \code{TRUE}, parameter values are printed
#'     to the screen for each iteration of the optimisation procedure.
#'
#' @inheritParams fit.ns
#' 
#' @return An R6 reference class object. Extraction of the information
#'     held within is best handled by functions \link{coef.nspp},
#'     \link{confint.nspp}, \link{summary.nspp}, and \link{plot.nspp}.
#'
#' @examples
#' ## Fit model.
#' fit <- fit.ns(example.2D, lims = rbind(c(0, 1), c(0, 1)), R = 0.5)
#' ## Print estimates.
#' coef(fit)
#' ## Plot the estimated Palm intensity.
#' plot(fit)
#' 
#' @export
fit.ns <- function(points, lims, R, disp = "gaussian", child.dist = "pois", child.info = NULL,
                      sibling.list = NULL, edge.correction = "pbc", start = NULL, bounds = NULL, trace = FALSE){
    classes.list <- setup.classes(fit = TRUE, family = "ns", family.info = list(child.dist = child.dist,
                                                                                child.info = child.info,
                                                                                disp = disp,
                                                                                sibling.list = sibling.list),
                                  edge.correction = edge.correction)
    obj <- create.obj(classes = classes.list$classes, points = points, lims = lims, R = R,
                      child.list = classes.list$child.list, sibling.list = sibling.list, trace = trace,
                      start = start, bounds = bounds)
    obj$fit()
    obj
}

#' Simulating points from a Neyman-Scott point process
#'
#' Generates points from a Neyman-Scott point process using parameters
#' provided by the user.
#'
#' For a list of possible parameter names, see \link{fit.ns}.
#' 
#' The \code{"child.info"} argument is required when \code{child.dist}
#' is set to \code{"twoplane"}. It must be a list that comprises (i) a
#' component named \code{w}, providing the halfwidth of the detection
#' zone; (ii) a component named \code{b}, providing the halfwidth of
#' the survey area; (iii) a component named \code{l}, providing the
#' time lag between planes (in seconds); and (iv) a component named
#' \code{tau}, providing the mean dive-cycle duration. See Stevenson,
#' Borchers, and Fewster (in prep) for details.
#'
#' @param pars A named vector containing the values of the parameters
#'     of the process that generates the points.
#' 
#' @inheritParams fit.ns
#'
#' @return A list. The first component gives the Cartesian coordinates
#'     of the generated points. A second component may provide sibling
#'     information.
#'
#' @examples
#' set.seed(1234)
#' ## One-dimensional Thomas process.
#' data.thomas <- sim.ns(c(D = 10, lambda = 5, sigma = 0.025), lims = rbind(c(0, 1)))
#' ## Fitting a model to these data.
#' fit.thomas <- fit.ns(data.thomas$points, lims = rbind(c(0, 1)), R = 0.5)
#' ## Three-dimensional Matern process.
#' data.matern <- sim.ns(c(D = 10, lambda = 10, tau = 0.1), disp = "uniform", lims = rbind(c(0, 1), c(0, 2), c(0, 3)))
#' ## Fitting a model to these data.
#' fit.matern <- fit.ns(data.matern$points, lims = rbind(c(0, 1), c(0, 2), c(0, 3)), R = 0.5, disp = "uniform")
#' 
#' @export
sim.ns <- function(pars, lims, disp = "gaussian", child.dist = "pois", child.info = NULL){
    classes.list <- setup.classes(fit = FALSE, family = "ns", family.info = list(child.dist = child.dist,
                                                                                 child.info = child.info,
                                                                                 disp = disp),
                                  edge.correction = NULL)
    obj <- create.obj(classes = classes.list$classes, points = NULL, lims = lims, R = NULL,
                      child.list = classes.list$child.list, sibling.list = NULL, trace = NULL,
                      start = NULL, bounds = NULL)
    obj$simulate(pars)
}

#' Fitting a model to a void point process
#'
#'  Estimates parameters for a void point process by maximising the
#' Palm likelihood. This approach was first proposed by Tanaka et
#' al. (2008) for two-dimensional Thomas processes. Generalisation to
#' d-dimensional void processes was made by Jones-Todd (2017).
#'
#' Parameters to estimate are as follows:
#' \itemize{
#'   \item \code{Dc}, the baseline density of observed points.
#'
#'   \item \code{Dp}, the density of unobserved parents that cause voids.
#'
#'   \item \code{tau}, the radius of the deletion process centred at each parent.
#' }
#'
#' @references Tanaka, U., Ogata, Y., and Stoyan, D. (2008) Parameter
#'     estimation and model selection for Neyman-Scott point
#'     processes. \emph{Biometrical Journal}, \strong{50}: 43--57.
#' @references Jones-Todd, C. M. (2017) \emph{Modelling complex
#'     dependencies inherent in spatial and spatio-temporal point
#'     pattern data}. PhD thesis, University of St Andrews.
#'
#' @inheritParams fit.ns
#'
#' @return An R6 reference class object. Extraction of the information
#'     held within is best handled by functions \link{coef.nspp},
#'     \link{confint.nspp}, \link{summary.nspp}, and \link{plot.nspp}.
#'
#' @export
fit.void <- function(points, lims, R, edge.correction = "pbc", start = NULL, bounds, trace = FALSE){
    classes.list <- setup.classes(fit = TRUE, family = "void", family.info = NULL,
                                  edge.correction = edge.correction)
    obj <- create.obj(classes = classes.list$classes, points = points, lims = lims, R = R,
                      child.list = NULL, sibling.list = NULL, trace = trace, start = start,
                      bounds = bounds)
    obj$fit()
    obj
}

#' Simulating points from a void point process.
#'
#' Generates points from a void point process using parameters provided by the user.
#'
#' @inheritParams fit.void
#' @inheritParams sim.ns
#'
#' @export
sim.void <- function(pars, lims){
    classes.list <- setup.classes(fit = FALSE, family = "void", family.info = NULL,
                                  edge.correction = NULL)
    obj <- create.obj(classes = classes.list$classes, points = NULL, lims = lims, R = NULL,
                      child.list = NULL, sibling.list = NULL, trace = NULL, start = NULL,
                      bounds = NULL)
    obj$simulate(pars)
}

setup.classes <- function(fit, family, family.info, edge.correction){
    ## Initialising all classes to FALSE.
    use.fit.class <- FALSE
    use.pbc.class <- FALSE
    use.buffer.class <- FALSE
    use.ns.class <- FALSE
    use.sibling.class <- FALSE
    use.poischild.class <- FALSE
    use.binomchild.class <- FALSE
    use.twoplanechild.class <- FALSE
    child.list <- NULL
    use.thomas.class <- FALSE
    use.matern.class <- FALSE
    use.void.class <- FALSE
    use.totaldeletion.class <- FALSE
    ## Sorting out fitting class.
    if (fit){
        use.fit.class <- TRUE
        ## Sorting out boundary condition class.
        if (edge.correction == "pbc"){
            use.pbc.class <- TRUE
        } else if (edge.correction == "buffer"){
            use.buffer.class <- TRUE
        } else {
            stop("Edge correction method not recognised; use either 'pbc' or 'buffer'.")
        }
    }
    ## Sorting out family (ns/void) class.
    if (family == "ns"){
        ## Stuff for ns class.
        use.ns.class <- TRUE
        if (!is.null(family.info$sibling.list)){
            use.sibling.class <- TRUE
        }
        ## Sorting out child distribution class.
        if (family.info$child.dist == "pois"){
            use.poischild.class <- TRUE
        } else if (substr(family.info$child.dist, 1, 5) == "binom"){
            use.binomchild.class <- TRUE
            n <- as.numeric(substr(family.info$child.dist, 6, nchar(family.info$child.dist)))
            child.list <- list(size = n)
        } else if (family.info$child.dist == "twoplane"){
            use.twoplanechild.class <- TRUE
            child.list <- list(twoplane.w = family.info$child.info$w,
                               twoplane.b = family.info$child.info$b,
                               twoplane.l = family.info$child.info$l,
                               twoplane.tau = family.info$child.info$tau)
        } else {
            stop("Only 'pois', 'binomx', or 'twoplane' can currently be used for 'child.dist'.")
        }
        ## Sorting out dispersion class.
        if (family.info$disp == "gaussian"){
            use.thomas.class <- TRUE
        } else if (family.info$disp == "uniform"){
            use.matern.class <- TRUE
        } else {
            stop("Dispersion type not recognised; use either 'gaussian' or 'uniform'.")
        }
    } else if (family == "void"){
        ## Stuff for void class.
        use.void.class <- TRUE
        use.totaldeletion.class <- TRUE
    }
    classes <- c("fit"[use.fit.class],
                 "pbc"[use.pbc.class],
                 "buffer"[use.buffer.class],
                 "ns"[use.ns.class],
                 "sibling"[use.sibling.class],
                 "poischild"[use.poischild.class],
                 "binomchild"[use.binomchild.class],
                 "twoplanechild"[use.twoplanechild.class],
                 "thomas"[use.thomas.class],
                 "matern"[use.matern.class],
                 "void"[use.void.class],
                 "totaldeletion"[use.totaldeletion.class])
    list(classes = classes, child.list = child.list)
}

#' Estimation of animal density from two-plane surveys.
#'
#' Estimates animal density (amongst other parameters) from two-plane
#' aerial surveys. This conceptualises sighting locations as a
#' Neyman-Scott point pattern---estimation is carried out via
#' \code{fit.ns()}.
#'
#' This function is simply a wrapper for \code{fit.ns}, and
#' facilitates the fitting of the model proposed by Stevenson,
#' Borchers, and Fewster (in prep). This function presents the
#' parameter \code{D.2D} (two-dimensional cetacean density in
#' cetaceans per square km) rather than \code{D} for enhanced
#' interpretability.
#'
#' @references Stevenson, B. C., Borchers, D. L., and Fewster,
#'     R. M. (in prep) Trace-contrast methods to account for
#'     identification uncertainty on aerial surveys of cetacean
#'     populations.
#'
#' @param points A vector (or single-column matrix) containing the
#'     distance along the transect that each detection was made.
#' @param planes An optional vector containing the plane ID (either
#'     \code{1} or \code{2}) that made the corresponding detection in
#'     \code{points}.
#' @param d The length of the transect flown (in km).
#' @param w The distance from the transect to which detection of
#'     individuals on the surface is certain. This is equivalent to
#'     the half-width of the detection zone.
#' @param b The distance from the transect to the edge of the area of
#'     interest. Conceptually, the distance between the transect and
#'     the furthest distance a whale could be on the passing on the
#'     first plane and plausibly move into the detection zone by the
#'     passing of the second plane.
#' @param l The lag between planes (in seconds).
#' @param tau Mean dive-cycle duration (in seconds).
#' @param R Truncation distance (see \link{fit.ns}).
#' @param edge.correction The method used for the correction of edge
#'     effects. Either \code{"pbc"} for periodic boundary conditions,
#'     or \code{"buffer"} for a buffer-zone correction.
#' @param trace Logical, if \code{TRUE}, parameter values are printed
#'     to the screen for each iteration of the optimisation procedure.
#' @inheritParams fit.ns
#'
#' @return An R6 reference class object. Extraction of the information
#'     held within is best handled by functions \link{coef.nspp},
#'     \link{confint.nspp}, \link{summary.nspp}, and \link{plot.nspp}.
#'
#' @examples
#' fit <- fit.twoplane(points = example.twoplane$points, planes = example.twoplane$planes,
#'                     d = 500, w = 0.175, b = 0.5, l = 20, tau = 110, R = 1)
#' 
#' @export
fit.twoplane <- function(points, planes = NULL, d, w, b, l, tau, R,
                         edge.correction = "pbc", start = NULL,
                         bounds = NULL, trace = FALSE){
    if (is.null(planes)){
        sibling.list <- NULL
    } else {
        sibling.list <- siblings.twoplane(planes)
    }
    bounds <- list(sigma = c(0, min(R, b/3)))
    fit.ns(points = points, lims = rbind(c(0, d)), R = R,
              child.dist = "twoplane",
              child.info = list(w = w, b = b, l = l, tau = tau),
              sibling.list = sibling.list, start = start, bounds = bounds, trace = trace)
}

#' Bootstrapping for fitted models
#'
#' Carries out a parametric bootstrap procedure for models fitted
#' using the \code{nspp} package.
#'
#' @return The original model object containing additional information
#'     from the boostrap procedure. These are accessed by functions
#'     such as \link{summary}.
#'
#' @param fit A fitted object.
#' @param N The number of bootstrap resamples.
#' @param prog Logical, if \code{TRUE}, a progress bar is printed to
#'     the console.
#'
#' @return The original R6 reference object, with additional bootstrap
#'     information attached.
#'
#' @examples
#' ## Fit model.
#' fit <- fit.ns(example.2D, lims = rbind(c(0, 1), c(0, 1)), R = 0.5)
#' ## Carry out bootstrap.
#' fit <- boot.palm(fit, N = 100)
#' ## Inspect standard errors and confidence intervals.
#' summary(fit)
#' confint(fit)
#' ## Estimates are very imprecise---these data were only used as
#' ## they can be fitted and bootstrapped quickly for example purposes.
#' 
#' @export
boot.palm <- function(fit, N, prog = TRUE){
    fit$boot(N, prog)
    fit
}



## Roxygen code for NAMESPACE.
#' @import methods Rcpp R6
#' @importFrom graphics abline axis box lines par plot.new plot.window title
#' @importFrom gsl hyperg_2F1
#' @importFrom mvtnorm rmvnorm
#' @importFrom spatstat crossdist
#' @importFrom stats coef dist integrate nlminb pbeta pgamma pnorm printCoefmat qnorm quantile rbinom rpois runif sd
#' @importFrom utils setTxtProgressBar txtProgressBar
#' @useDynLib nspp
NULL

## Data documentation.

#' 1-dimensional example data
#'
#' Simulated data, with children points generated from a Binomial(4,
#' 0.5) distribution.
#'
#' @name example.1D
#' @format A matrix.
#' @usage example.1D
#' @docType data
#' @keywords datasets
NULL

#' 2-dimensional example data
#'
#' Simulated data, with children points generated from a Binomial(2,
#' 0.5) distribution.
#'
#' @name example.2D
#' @format A matrix.
#' @usage example.2D
#' @docType data
#' @keywords datasets
NULL

#' Two-plane example data.
#'
#' Simulated data from a two-plane aerial survey.
#'
#' @name example.twoplane
#' @format A list.
#' @usage example.twoplane
#' @docType data
#' @keywords datasets
NULL
