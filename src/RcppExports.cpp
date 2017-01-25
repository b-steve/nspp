// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

// buffer_keep
LogicalMatrix buffer_keep(const NumericMatrix& points, const NumericMatrix& lims, const double& R);
RcppExport SEXP nspp_buffer_keep(SEXP pointsSEXP, SEXP limsSEXP, SEXP RSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const NumericMatrix& >::type points(pointsSEXP);
    Rcpp::traits::input_parameter< const NumericMatrix& >::type lims(limsSEXP);
    Rcpp::traits::input_parameter< const double& >::type R(RSEXP);
    rcpp_result_gen = Rcpp::wrap(buffer_keep(points, lims, R));
    return rcpp_result_gen;
END_RCPP
}
// pbc_distances
NumericVector pbc_distances(const NumericMatrix& points, const NumericMatrix& lims);
RcppExport SEXP nspp_pbc_distances(SEXP pointsSEXP, SEXP limsSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const NumericMatrix& >::type points(pointsSEXP);
    Rcpp::traits::input_parameter< const NumericMatrix& >::type lims(limsSEXP);
    rcpp_result_gen = Rcpp::wrap(pbc_distances(points, lims));
    return rcpp_result_gen;
END_RCPP
}
