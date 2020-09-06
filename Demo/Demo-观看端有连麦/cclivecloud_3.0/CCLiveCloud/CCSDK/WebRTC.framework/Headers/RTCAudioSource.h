/*
 *  Copyright 2016 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <Foundation/Foundation.h>

#import <WebRTC/RTCMacros.h>
#import <WebRTC/RTCMediaSource.h>

NS_ASSUME_NONNULL_BEGIN
@class RTCAudioSource;
RTC_EXPORT

@protocol RTCAudioSourceRenderDelegate
//int bits_per_sample, int sample_rate, size_t number_of_channels, size_t number_of_frames
- (void)audioSource:(RTCAudioSource *)source render:(void *)audio_data bits_per_sample:(int)bits_per_sample sample_rate:(int)sample_rate number_of_channel:(int)num_of_channel number_of_frames:(int)number_of_frames;
@end

RTC_EXPORT
@interface RTCAudioSource : RTCMediaSource

- (void)setObserVer:(id<RTCAudioSourceRenderDelegate>)observer;
- (instancetype)init NS_UNAVAILABLE;

@end
NS_ASSUME_NONNULL_END


