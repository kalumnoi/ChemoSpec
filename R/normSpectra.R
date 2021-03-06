#'
#'
#' Normalize a Spectra Object
#' 
#' This function carries out normalization of the spectra in a
#' \code{\link{Spectra}} object.  There are currently four options:
#' \code{"PQN"} carries out "Probabalistic Quotient Normalization" as described
#' in the reference.  \code{"TotInt"} normalizes by total intensity.  In this
#' case, the y-data of a \code{\link{Spectra}} object is normalized by dividing
#' each y-value by the sum of the y-values in a given spectrum.  Thus each
#' spectrum sums to 1.  This method assumes that the total concentration of
#' substances giving peaks does not vary across samples which may not be true.
#' \code{"Range"} allows one to do something similar but rather than using the
#' sum of the entire spectrum as the denominator, only the sum of the given
#' range is used.  This would be appropriate if there was an internal standard
#' in the spectrum which was free of interferance. \code{"zero2one"} scales
#' each spectrum separately to a [0 \ldots{} 1] scale.
#' 
#' 
#' @param spectra An object of S3 class \code{\link{Spectra}} to be normalized.
#'
#' @param method One of \code{c("PQN", "TotInt", "Range", "zero2one")} giving
#' the method for normalization.
#'
#' @param RangeExpress A logical expression giving the frequency range over
#' which to sum intensities, before dividing the entire spectrum by the summed
#' values.  For examples of constructing these expressions, see the examples in
#' \code{\link{removeFreq}}.
#'
#' @return An object of S3 class \code{\link{Spectra}}.
#'
#' @author Bryan A. Hanson, DePauw University.
#'
#' @references Probabalistic Quotient Normalization is reported in F. Dieterle
#' et. al. Analytical Chemistry vol. 78 pages 4281-4290 (2006).  The exact same
#' mathematics are called "median fold change normalization" by Nicholson's
#' group, reported in K. A. Veselkov et. al. Analytical Chemistry vol. 83 pages
#' 5864-5872 (2011).
#' 
#' \url{https://github.com/bryanhanson/ChemoSpec}
#'
#' @keywords utilities manip
#'
#' @examples
#' 
#' data(SrE.IR)
#' res <- normSpectra(SrE.IR)
#' sumSpectra(res)
#' 
#' @export normSpectra
#'
#' @importFrom stats median
#'
normSpectra <- function(spectra, method = "PQN", RangeExpress = NULL) {
	
# Function to Normalize the data in a Spectra object
# Part of the ChemoSpec package
# Bryan Hanson, DePauw University, Nov 2009

	if (missing(spectra)) stop("No spectral data provided")
	chkSpectra(spectra)

# normalize using the probablistic quotient normalization (PQN)

	if (method == "PQN") {
		
		# Do a standard TotInt normalization
		S <- normSpectra(spectra, method = "TotInt")$data
		if (any(S < 0)) S <- S - min(S)
		
		# Compute the median spectrum for reference
		M <- apply(S, 2, median)

		# Divide each normed spectrum by the reference column medians (the ref spectrum)
		F <- S
		for (i in 1:nrow(F)) F[i,] <- F[i,]/M
		
		# Get the row medians (per spectrum median) of the ratioed spectra
		# These are the apparent 'fold' dilution factors
		# for each spectrum/sample
		F <- apply(F, 1, median)
		
		# Divide each row of the original data by it's median
		for (i in 1:nrow(S)) S[i,] <- S[i,]/F[i]
		
		spectra$data <- S
		}

# normalize a row by the sum of its entries:

	if (method == "TotInt") {
		for (n in 1:length(spectra$names)) {
			S <- sum(as.numeric(spectra$data[n,]))
			spectra$data[n,] <- spectra$data[n,]/S
			}
		}

# normalize by a range of specified values:

	if (method == "Range") {
		if (is.null(RangeExpress)) stop("No range expression given")
		rfi <- which(RangeExpress)
		for (n in 1:length(spectra$names)) {
			S <- sum(as.numeric(spectra$data[n,rfi]))
			spectra$data[n,] <- spectra$data[n,]/S
			}
		}

# normalize each spectrum to a [0...1] range:

	if (method == "zero2one") {
		for (i in 1:length(spectra$names)) {
			rMin <- min(spectra$data[i,])
			spectra$data[i,] <- spectra$data[i,] - rMin
			rMax <- max(spectra$data[i,])
			spectra$data[i,] <- spectra$data[i,]/rMax
			}
		}

	chkSpectra(spectra)
	spectra
	}
