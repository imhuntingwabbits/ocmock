//---------------------------------------------------------------------------------------
//  $Id$
//  Copyright (c) 2013 by Mulle Kybernetik. See License file for details.
//---------------------------------------------------------------------------------------

#import "OCMArg.h"
#import "OCMArgTests.h"

#if TARGET_OS_IPHONE
#define NSRect CGRect
#define NSZeroRect CGRectZero
#define NSMakeRect CGRectMake
#define valueWithRect valueWithCGRect
#endif


@implementation OCMArgTests

- (void)testValueMacroCreatesCorrectValueObjects
{
    NSRange range = NSMakeRange(5, 5);
    XCTAssertEqualObjects(OCMOCK_VALUE(range), [NSValue valueWithRange:range]);
#if defined(__GNUC__) && !defined(__STRICT_ANSI__)
    /* Should work with constant values and some expressions */
  NSValue *ocmockValue = OCMOCK_VALUE(YES);
  NSValue *numberValue = @YES;
  int mockInt = 0;
  int numberInt = 0;
  [ocmockValue getValue:&mockInt];
  [numberValue getValue:&numberInt];
  XCTAssertEqual(mockInt, numberInt);
  
    XCTAssertEqualObjects(OCMOCK_VALUE(42), @42);
    XCTAssertEqualObjects(OCMOCK_VALUE(NSZeroRect), [NSValue valueWithRect:NSZeroRect]);
    XCTAssertEqualObjects(OCMOCK_VALUE([@"0123456789" rangeOfString:@"56789"]), [NSValue valueWithRange:range]);
#endif
}

@end