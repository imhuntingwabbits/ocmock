//---------------------------------------------------------------------------------------
//  $Id$
//  Copyright (c) 2004-2009 by Mulle Kybernetik. See License file for details.
//---------------------------------------------------------------------------------------

#import "OCMockRecorderTests.h"
#import <OCMock/OCMockRecorder.h>
#import "OCMReturnValueProvider.h"
#import "OCMExceptionReturnValueProvider.h"
#import "OCMArg.h"

@interface TestClassForRecorder : NSObject

- (void)methodWithInt:(int)i andObject:(id)o;

@end

@implementation TestClassForRecorder

- (void)methodWithInt:(int)i andObject:(id)o
{
}

@end


@implementation OCMockRecorderTests


- (NSInvocation *)invocationForTargetClass:(Class)aClass selector:(SEL)aSelector
{
    NSMethodSignature *signature = [aClass instanceMethodSignatureForSelector:aSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:aSelector];
    return invocation;
}


- (void)testStoresAndMatchesInvocation
{
    NSString *arg = @"I love mocks.";

    OCMockRecorder *recorder = [[OCMockRecorder alloc] initWithSignatureResolver:[NSString string]];
	(void)[(id)recorder initWithString:arg];

    NSInvocation *testInvocation = [self invocationForTargetClass:[NSString class] selector:@selector(initWithString:)];
    [testInvocation setArgument:&arg atIndex:2];
	XCTAssertTrue([recorder matchesInvocation:testInvocation], @"Should match.");
}


- (void)testOnlyMatchesInvocationWithRightArguments
{
    NSString *arg = @"I love mocks.";

    OCMockRecorder *recorder = [[OCMockRecorder alloc] initWithSignatureResolver:[NSString string]];
	(void)[(id)recorder initWithString:@"whatever"];

    NSInvocation *testInvocation = [self invocationForTargetClass:[NSString class] selector:@selector(initWithString:)];
    [testInvocation setArgument:&arg atIndex:2];
	XCTAssertFalse([recorder matchesInvocation:testInvocation], @"Should not match.");
}

-(void)testSelectivelyIgnoresNonObjectArguments
{
    NSString *arg1 = @"I (.*) mocks.";
    NSUInteger arg2 = NSRegularExpressionSearch;

    OCMockRecorder *recorder = [[OCMockRecorder alloc] initWithSignatureResolver:[NSString string]];
    [(id)recorder rangeOfString:[OCMArg any] options:0];
    [recorder ignoringNonObjectArgs];

    NSInvocation *testInvocation = [self invocationForTargetClass:[NSString class] selector:@selector(rangeOfString:options:)];
    [testInvocation setArgument:&arg1 atIndex:2];
    [testInvocation setArgument:&arg2 atIndex:3];
    XCTAssertTrue([recorder matchesInvocation:testInvocation], @"Should match.");
}

-(void)testSelectivelyIgnoresNonObjectArgumentsAndStillFailsWhenFollowingObjectArgsDontMatch
{
    int arg1 = 17;
    NSString *arg2 = @"foo";

    OCMockRecorder *recorder = [[OCMockRecorder alloc] initWithSignatureResolver:[[TestClassForRecorder alloc] init]];
    [(id)recorder methodWithInt:12 andObject:@"bar"];
    [recorder ignoringNonObjectArgs];

    NSInvocation *testInvocation = [self invocationForTargetClass:[TestClassForRecorder class] selector:@selector(methodWithInt:andObject:)];
    [testInvocation setArgument:&arg1 atIndex:2];
    [testInvocation setArgument:&arg2 atIndex:3];
    XCTAssertFalse([recorder matchesInvocation:testInvocation], @"Should not match.");
}

- (void)testAddsReturnValueProvider
{
    OCMockRecorder *recorder = [[OCMockRecorder alloc] initWithSignatureResolver:[NSString string]];
	[recorder andReturn:@"foo"];
    NSArray *handlerList = [recorder invocationHandlers];
	
	XCTAssertEqual((NSUInteger)1, [handlerList count], @"Should have added one handler.");
	XCTAssertEqualObjects([OCMReturnValueProvider class], [[handlerList objectAtIndex:0] class], @"Should have added correct handler.");
}

- (void)testAddsExceptionReturnValueProvider
{
    OCMockRecorder *recorder = [[OCMockRecorder alloc] initWithSignatureResolver:[NSString string]];
	[recorder andThrow:[NSException exceptionWithName:@"TestException" reason:@"A reason" userInfo:nil]];
    NSArray *handlerList = [recorder invocationHandlers];

	XCTAssertEqual((NSUInteger)1, [handlerList count], @"Should have added one handler.");
	XCTAssertEqualObjects([OCMExceptionReturnValueProvider class], [[handlerList objectAtIndex:0] class], @"Should have added correct handler.");
	
}

@end
