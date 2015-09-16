//
//  OCMockObjectDynamicPropertyMockingTests.m
//  OCMock
//
//  Copyright © 2015 Mulle Kybernetik. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#pragma mark   Helper classes

@interface TestClassWithDynamicProperties : NSObject
@property(nonatomic, retain) NSDictionary *anObject;
@property(nonatomic, assign) NSUInteger aUInt;
@property(nonatomic, assign) NSInteger __aPrivateInt;
@property(nonatomic, retain, getter=customGetter, setter=customSetter:) NSDictionary *aCustomProperty;

@end

@implementation TestClassWithDynamicProperties
@dynamic anObject;
@dynamic aUInt;
@dynamic __aPrivateInt;
@dynamic aCustomProperty;

@end


@interface OCMockObjectDynamicPropertyMockingTests : XCTestCase

@end

@implementation OCMockObjectDynamicPropertyMockingTests

#pragma mark   Tests stubbing dynamic properties

- (void)testCanStubDynamicPropertiesWithIdType
{
  id mock = [OCMockObject mockForClass:[TestClassWithDynamicProperties class]];
  NSDictionary *testDict = @{@"test-key" : @"test-value"};
  [[[mock stub] andReturn:testDict] anObject];
  XCTAssertEqualObjects(testDict, [mock anObject]);
  
  [[mock stub] setAnObject:testDict];
}

- (void)testCanStubDynamicPropertiesWithUIntType
{
  id mock = [OCMockObject mockForClass:[TestClassWithDynamicProperties class]];
  NSUInteger someUInt = 5;
  [[[mock stub] andReturnValue:OCMOCK_VALUE(someUInt)] aUInt];
  XCTAssertEqual(5, [mock aUInt]);
  
  [[mock stub] setAUInt:5];
}

- (void)testCanStubDynamicPropertiesWithIntType
{
  id mock = [OCMockObject mockForClass:[TestClassWithDynamicProperties class]];
  NSInteger someInt = -10;
  [[[mock stub] andReturnValue:OCMOCK_VALUE(someInt)] __aPrivateInt];
  XCTAssertEqual(-10, [mock __aPrivateInt]);
  
  [[mock stub] set__aPrivateInt:10];
}

- (void)testCanStubDynamicPropertiesWithCustomGetterAndSetter {
  id mock = [OCMockObject mockForClass:[TestClassWithDynamicProperties class]];
  NSDictionary *testDict = @{@"test-key" : @"test-value"};
  [[[mock stub] andReturn:testDict] customGetter];
  XCTAssertEqualObjects(testDict, [mock customGetter]);
  
  [[mock stub] customSetter:testDict];
}

@end
