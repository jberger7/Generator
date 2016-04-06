//____________________________________________________________________________
/*!

\class    genie::GRV89LO

\brief    GRV98LO parton density functions (pdf).
          Concrete implementation of the PDFModelI interface.

\ref      This is a straighforward adaptation of the fortran code in
          http://hepdata.cedar.ac.uk//hepdata/pdflib/grv/grv98/grv98.f

          The original code contains NLO (MSbar and DIS schemes) and LO pdf
          implementations. Only the LO pdfs are implemented here.

          Reference listed in original code:
          M. Glueck, E. Reya, A. Vogt,
          Eur. Phys. J. C5 (1998) 461-470; hep-ph/9806404

\author   Costas Andreopoulos <costas.andreopoulos \at stfc.ac.uk>
          University of Liverpool & STFC, Rutherford Appleton Laboratory

\created  Ocrober 29, 2014

\cpright  Copyright (c) 2003-2016, GENIE Neutrino MC Generator Collaboration
          For the full text of the license visit http://copyright.genie-mc.org
          or see $GENIE/LICENSE
*/
//____________________________________________________________________________

#ifndef _GRV98LO_H_
#define _GRV98LO_H_

#include <TGraph2D.h>

#include "PDF/PDFModelI.h"
//#include "Numerical/BLI2D.h"

namespace genie {

class GRV98LO: public PDFModelI {

public:
  GRV98LO();
  GRV98LO(string config);
 ~GRV98LO();

  // implement the PDFModelI interface

  double UpValence   (double x, double q2) const;
  double DownValence (double x, double q2) const;
  double UpSea       (double x, double q2) const;
  double DownSea     (double x, double q2) const;
  double Strange     (double x, double q2) const;
  double Charm       (double x, double q2) const;
  double Bottom      (double x, double q2) const;
  double Top         (double x, double q2) const;
  double Gluon       (double x, double q2) const;
  PDF_t  AllPDFs     (double x, double q2) const;

  // override the default "Configure" implementation 
  // of the Algorithm interface

  void Configure (const Registry & config);
  void Configure (string config);

private:

  void Initialize   (void);

  bool fInitialized;

  // >> Information about the PDF grid

  static const int kNQ2     = 27; 
  static const int kNXBj    = 68; 
  static const int kNParton = 6;

  // >> Information read from the PDF grid file
  //
  // grid points
  //
  double fGridQ2    [kNQ2];  // Q^2 (GeV^2)    values in grid; between 0.8 and 1E6
  double fGridLogQ2 [kNQ2];  // log(Q^2/GeV^2) values in grid
  double fGridXbj   [kNXBj]; // Bjorken-x      values in grid; between 1E-9 and 1
  double fGridLogXbj[kNXBj]; // log(Bjorken-x) values in grid
  double fParton    [kNParton][kNQ2][kNXBj-1]; // PARTON (NPART,NQ,NX-1) array in original code
  //
  // arrays for the interpolation routine
  //
  mutable TGraph2D fXUVF; // = f(logx,logQ2)
  mutable TGraph2D fXDVF;
  mutable TGraph2D fXDEF;
  mutable TGraph2D fXUDF;
  mutable TGraph2D fXSF;
  mutable TGraph2D fXGF;
};

}         // genie namespace
#endif    // _GRV98LO_H_