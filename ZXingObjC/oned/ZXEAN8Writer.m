/*
 * Copyright 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZXBarcodeFormat.h"
#import "ZXBoolArray.h"
#import "ZXEAN8Writer.h"
#import "ZXUPCEANReader.h"
#import "ZXErrors.h"

const int ZX_EAN8_CODE_WIDTH = 3 + (7 * 4) + 5 + (7 * 4) + 3;

@implementation ZXEAN8Writer

- (ZXBitMatrix *)encode:(NSString *)contents format:(ZXBarcodeFormat)format width:(int)width height:(int)height hints:(ZXEncodeHints *)hints error:(NSError **)error {
  if (format != kBarcodeFormatEan8) {
      NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Can only encode EAN_8, but got %d", format]};
      
      *error = [[NSError alloc] initWithDomain:ZXErrorDomain code:ZXWriterError userInfo:userInfo];
      
      return nil;
  }
  return [super encode:contents format:format width:width height:height hints:hints error:error];
}

/**
 * Returns a byte array of horizontal pixels (FALSE = white, TRUE = black)
 */
- (ZXBoolArray *)encode:(NSString *)contents error:(NSError **)error {
  if ([contents length] != 8) {
      NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Requested contents should be 8 digits long, but got %d", (int)[contents length]]};
      
      *error = [[NSError alloc] initWithDomain:ZXErrorDomain code:ZXWriterError userInfo:userInfo];
      
      return nil;
  }

  ZXBoolArray *result = [[ZXBoolArray alloc] initWithLength:ZX_EAN8_CODE_WIDTH];
  int pos = 0;

  pos += [self appendPattern:result pos:pos pattern:ZX_UPC_EAN_START_END_PATTERN patternLen:ZX_UPC_EAN_START_END_PATTERN_LEN startColor:YES];

  for (int i = 0; i <= 3; i++) {
    int digit = [[contents substringWithRange:NSMakeRange(i, 1)] intValue];
    pos += [self appendPattern:result pos:pos pattern:ZX_UPC_EAN_L_PATTERNS[digit] patternLen:ZX_UPC_EAN_L_PATTERNS_SUB_LEN startColor:FALSE];
  }

  pos += [self appendPattern:result pos:pos pattern:ZX_UPC_EAN_MIDDLE_PATTERN patternLen:ZX_UPC_EAN_MIDDLE_PATTERN_LEN startColor:FALSE];

  for (int i = 4; i <= 7; i++) {
    int digit = [[contents substringWithRange:NSMakeRange(i, 1)] intValue];
    pos += [super appendPattern:result pos:pos pattern:ZX_UPC_EAN_L_PATTERNS[digit] patternLen:ZX_UPC_EAN_L_PATTERNS_SUB_LEN startColor:YES];
  }

  [self appendPattern:result pos:pos pattern:ZX_UPC_EAN_START_END_PATTERN patternLen:ZX_UPC_EAN_START_END_PATTERN_LEN startColor:YES];

  return result;
}

@end
