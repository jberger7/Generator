//____________________________________________________________________________
/*!

\class   genie::SPPInteractionListGenerator

\brief   Generate a list of all the Interaction objects that can be generated 
         by the SPP EventGenerator.
         Concrete implementations of the InteractionListGeneratorI interface.

\author  Costas Andreopoulos <C.V.Andreopoulos@rl.ac.uk>
         CCLRC, Rutherford Appleton Laboratory

\created May 13, 2005

*/
//____________________________________________________________________________

#ifndef _SPP_INTERACTION_LIST_GENERATOR_H_
#define _SPP_INTERACTION_LIST_GENERATOR_H_

#include "EVGCore/InteractionListGeneratorI.h"
#include "Interaction/SppChannel.h"

namespace genie {

class SPPInteractionListGenerator : public InteractionListGeneratorI {

public :
  SPPInteractionListGenerator();
  SPPInteractionListGenerator(string config);
  ~SPPInteractionListGenerator();

  //-- implement the InteractionListGeneratorI interface
  InteractionList * CreateInteractionList(const InitialState & init) const;

  //-- overload the Algorithm::Configure() methods to load private data
  //   members from configuration options
  void Configure(const Registry & config);
  void Configure(string config);

private:

  void AddFinalStateInfo (Interaction * i, SppChannel_t chan) const;
  void LoadConfigData(void);

  bool          fIsCC;
  bool          fIsNC;
};

}      // genie namespace

#endif // _SPP_INTERACTION_LIST_GENERATOR_H_
