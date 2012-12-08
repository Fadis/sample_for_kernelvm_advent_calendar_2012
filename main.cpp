/*****************************************************************************
 * Copyright (C) 2012, Naomasa Matsubayashi                                  *
 * All rights reserved.                                                      *
 *                                                                           *
 * Redistribution and use in source and binary forms, with or without        *
 * modification, are permitted provided that the following conditions        *
 * are met:                                                                  *
 *                                                                           *
 * 1. Redistributions of source code must retain the above copyright         *
 *    notice, this list of conditions and the following disclaimer.          *
 * 2. Redistributions in binary form must reproduce the above copyright      *
 *    notice, this list of conditions and the following disclaimer in the    *
 *    documentation and/or other materials provided with the distribution.   *
 *                                                                           *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR      *
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES *
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.   *
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,          *
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT  *
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, *
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY     *
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT       *
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF  *
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.         *
 *                                                                           *
 *****************************************************************************/

#include <cstdlib>
#include <memory>
#include <array>
#include <boost/range/algorithm.hpp>
#include <libopencm3/stm32/f4/rcc.h>
#include <libopencm3/stm32/f4/gpio.h>
#include "kissfft/kissfft.hh"

int main() {
  constexpr size_t fft_size = 2048;
  std::unique_ptr< std::array< kissfft< float >::cpx_type, fft_size > > src(
    new std::array< kissfft< float >::cpx_type, fft_size >
  );
  std::unique_ptr< std::array< kissfft< float >::cpx_type, fft_size > > dest(
    new std::array< kissfft< float >::cpx_type, fft_size >
  );
  static kissfft< float > fft( fft_size, false );
  static kissfft< float > ifft( fft_size, true );
  for( int count = 0; count != 10; ++count ) {
    boost::transform( *dest, src->begin(), [&]( const kissfft< float >::cpx_type& ) {
      return static_cast< float >( rand() ) / RAND_MAX;
    } );
    fft.transform( src->data(), dest->data() );
    ifft.transform( dest->data(), src->data() );
  }

  rcc_peripheral_enable_clock(&RCC_AHB1ENR, RCC_AHB1ENR_IOPDEN);
  gpio_mode_setup(GPIOD, GPIO_MODE_OUTPUT, GPIO_PUPD_NONE, GPIO12);
  gpio_mode_setup(GPIOD, GPIO_MODE_OUTPUT, GPIO_PUPD_NONE, GPIO13);
  gpio_mode_setup(GPIOD, GPIO_MODE_OUTPUT, GPIO_PUPD_NONE, GPIO14);
  gpio_mode_setup(GPIOD, GPIO_MODE_OUTPUT, GPIO_PUPD_NONE, GPIO15);
  GPIO_ODR(GPIOD) ^= GPIO12|GPIO14;

  while( 1 ) {
    GPIO_ODR(GPIOD) ^= GPIO12|GPIO13|GPIO14|GPIO15;
    for ( int i = 0; i < 1000000; i++)
      __asm__("nop");
  }

}
