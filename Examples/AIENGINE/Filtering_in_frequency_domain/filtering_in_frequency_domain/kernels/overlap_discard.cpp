// /**********
// © Copyright 2020 Xilinx, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// **********/

#include <adf.h>
#include <aie_api/aie.hpp>

#include "kernels_common.h"

void __attribute__ ((noinline)) overlap_discard(adf::input_buffer<cint16,adf::extents<FFT_SIZE> > & restrict win_i,
                       adf::output_buffer<cint16,adf::extents<WIN_SIZE> > & restrict win_o )
{
  auto wi = aie::begin_vector<8>( win_i );
  auto wo = aie::begin_vector<8>( win_o );
  // Advance window point to end of discard region:
  wi += (TAP_NUM/8);
  // buffer_incr( win_i, TAP_NUM );

  // Loop over outputs writing 8 at a time:
  for (unsigned ll=0; ll < WIN_SIZE / 8; ll++)
    chess_loop_range(4,)
    chess_prepare_for_pipelining
  {
    aie::vector<cint16,8> v = *wi++;
    *wo++ = v;
  }
}