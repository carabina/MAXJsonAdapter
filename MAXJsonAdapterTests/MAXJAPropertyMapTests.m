//
//  MAXJAPropertyMapTests.m
//  MAXJsonAdapter
//
//  Created by Mathieu Skulason on 27/12/16.
//  Copyright © 2016 Konta ehf. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MAXJsonAdapterPropertyMapper.h"
#import "MAXJsonAdapterRuntimeUtilities.h"
#import "MAXJsonAdapterPropertyMapInfo.h"
#import "MAXJsonAdapterNSArraryUtilities.h"

#pragma mark - Ignored Properties Object

@interface MAXJAIgnoredPropertiesObject : NSObject <MAXJsonAdapterDelegate>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *age;

@end

@implementation MAXJAIgnoredPropertiesObject

-(NSArray <NSString *> *)MAXJAPropertiesToIgnoreObjectCreation {
    
    return @[@"name"];
}

-(NSArray <NSString *> *)MAXJAPropertiesToIgnoreDictionaryCreation {
    
    return @[@"title"];
}

@end

#pragma mark - Explicit Properties Object

@interface MAXJAExplicitPropertiesObject : NSObject <MAXJsonAdapterDelegate>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *timeStamp;
@property (nonatomic, strong) NSString *birthYear;
@property (nonatomic, strong) NSNumber *balance;

@end

@implementation MAXJAExplicitPropertiesObject

-(NSArray <NSString *> *)MAXJAPropertiesForObjectCreation {
    
    return @[@"title", @"balance"];
}

-(NSArray <NSString *> *)MAXJAPropertiesForDictionaryCreation {
    
    return @[@"name", @"timeStamp"];
}

@end

#pragma mark - Property Map Object

@interface MAXJAPropertyMapObject : NSObject <MAXJsonAdapterDelegate>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *age;

@end

@implementation MAXJAPropertyMapObject

-(NSArray <MAXJsonAdapterPropertyMap *> *)MAXJAPropertiesToMapObjectCreation {
    
    MAXJsonAdapterPropertyMap *firstMap = [MAXJsonAdapterPropertyMap MAXJACreateMapWithNewKey: @"age" nextPropertyMap: [MAXJsonAdapterPropertyMap MAXJACreateMapWithNewKey: @"fullAge" nextPropertyMap: nil] ];
    
    MAXJsonAdapterPropertyMap *secondMap = [MAXJsonAdapterPropertyMap MAXJACreateMapWithNewKey: @"title" nextPropertyMap: nil];
    
    
    return @[firstMap, secondMap];
}

-(NSArray <MAXJsonAdapterPropertyMap *> *)MAXJAPropertiesToMapDictionaryCreation {
    
    MAXJsonAdapterPropertyMap *firstMap = [MAXJsonAdapterPropertyMap MAXJACreateMapWithNewKey: @"name" nextPropertyMap: [MAXJsonAdapterPropertyMap MAXJACreateMapWithIndex: 2 nextPropertyMap: nil]];
    
    return @[firstMap];
}

@end

@interface MAXJAPropertyMapTests : XCTestCase

@end

@implementation MAXJAPropertyMapTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - PROPERTY MAP

-(void)testPropertyMapSingleLevelObjectCreation {
    
    NSArray <NSString *> *propertyList = [MAXJsonAdapterRuntimeUtilities MAXJACreatePropertyNameListWithouthNSObjectPropertiesWithClass: [MAXJAPropertyMapObject class] ];
    
    NSArray <MAXJsonAdapterProperty *> *properties = [MAXJsonAdapterPropertyMapper MAXJAMapPropertyListForObjectCreation: propertyList delegate: [[MAXJAPropertyMapObject alloc] init] ];
    
    XCTAssertNotNil( properties );
    XCTAssertEqualObjects( @(properties.count), @3);
    XCTAssertNil( [self findPropertyWithKey: @"title" inProperties: properties].propertyMap );
    XCTAssertNil( [self findPropertyWithKey: @"name" inProperties: properties].propertyMap );
    XCTAssertEqualObjects( [self findPropertyWithKey: @"age" inProperties: properties].propertyMap.key , @"fullAge");
    
}

-(void)testPropertyMapSingleLevelDictionaryCreation {
    
    NSArray <NSString *> *propertyList = [MAXJsonAdapterRuntimeUtilities MAXJACreatePropertyNameListWithouthNSObjectPropertiesWithClass: [MAXJAPropertyMapObject class] ];
    
    NSArray <MAXJsonAdapterProperty *> *properties = [MAXJsonAdapterPropertyMapper MAXJAMapPropertyListForDictionaryCreation: propertyList delegate: [[MAXJAPropertyMapObject alloc] init] ];
    
    XCTAssertNotNil( properties );
    XCTAssertEqualObjects( @(properties.count), @3);
    XCTAssertEqualObjects( [self findPropertyWithKey: @"name" inProperties: properties].propertyMap.index, @2);
    
}

#pragma mark - Without delegate

-(void)testPropertyMapWithoutDelegate {
    
    MAXJsonAdapterProperty *propertyOne = [[MAXJsonAdapterProperty alloc] init];
    propertyOne.propertyKey = @"age";
    
    MAXJsonAdapterProperty *propertyTwo = [[MAXJsonAdapterProperty alloc] init];
    propertyTwo.propertyKey = @"title";
    
    NSArray <MAXJsonAdapterProperty *> *properties = @[propertyOne, propertyTwo];
    
    MAXJsonAdapterPropertyMap *mapOne = [MAXJsonAdapterPropertyMap MAXJACreateMapWithNewKey: @"age" nextPropertyMap: nil];
    MAXJsonAdapterPropertyMap *mapTwo = [MAXJsonAdapterPropertyMap MAXJACreateMapWithNewKey: @"title" nextPropertyMap: [MAXJsonAdapterPropertyMap MAXJACreateMapWithNewKey: @"fullName" nextPropertyMap: nil] ];
    
    NSArray <MAXJsonAdapterPropertyMap *> *propertyMaps = @[mapOne, mapTwo];
    
    NSArray <MAXJsonAdapterProperty *> *mappedProperties = [MAXJsonAdapterPropertyMapper MAXJAMapPropertyList: properties propertyMaps: propertyMaps];
    
    XCTAssertNotNil( mappedProperties );
    XCTAssertEqualObjects( @(mappedProperties.count), @2);
    XCTAssertNil( [self findPropertyWithKey: @"age" inProperties: mappedProperties].propertyMap );
    XCTAssertEqualObjects( [self findPropertyWithKey: @"title" inProperties: mappedProperties].propertyMap.key, @"fullName");
    
}


#pragma mark - PROPERTY CREATION

-(void)testSinglePropertyCreation {
    
    NSString *singleProperty = @"singleProperty";
    
    NSArray <MAXJsonAdapterProperty *> *properties = [MAXJsonAdapterPropertyMapper MAXJACreatePropertyForPropertyList: @[singleProperty] ];
    
    XCTAssertNotNil(properties);
    XCTAssertEqualObjects(@(properties.count), @1);
    XCTAssertEqualObjects(properties.firstObject.propertyKey, @"singleProperty");
    XCTAssertFalse( [self properties: properties containKey: @"doubleProperty"] );
}

-(void)testMultiplePropertyCreation {
    
    NSArray <NSString *> *multipleProperties = [MAXJsonAdapterRuntimeUtilities MAXJACreatePropertyNameListWithouthNSObjectPropertiesWithClass: [MAXJAIgnoredPropertiesObject class] ];
    
    NSArray <MAXJsonAdapterProperty *> *properties = [MAXJsonAdapterPropertyMapper MAXJACreatePropertyForPropertyList: multipleProperties];
    
    XCTAssertTrue(multipleProperties != nil);
    XCTAssertEqualObjects(@(multipleProperties.count) , @3);
    XCTAssertTrue( [self properties: properties containKey: @"title"] );
    XCTAssertTrue( [self properties: properties containKey: @"name"] );
    XCTAssertTrue( [self properties: properties containKey: @"age"] );
    XCTAssertFalse( [self properties: properties containKey: @"doubleProperty"] );

    
}

#pragma mark - EXPLICITLY USED PROPERTIES

#pragma mark - With delegate

-(void)testExplicitPropertiesObjectCreation {
    
    NSArray <NSString *> *propertyList = [MAXJsonAdapterRuntimeUtilities MAXJACreatePropertyNameListWithouthNSObjectPropertiesWithClass: [MAXJAExplicitPropertiesObject class] ];
    
    NSArray <MAXJsonAdapterProperty *> *properties = [MAXJsonAdapterPropertyMapper MAXJAMapPropertyListForObjectCreation: propertyList delegate: [[MAXJAExplicitPropertiesObject alloc] init] ];
    
    XCTAssertTrue( properties.count == 2 );
    XCTAssertTrue( [self properties: properties containKey: @"title"] );
    XCTAssertTrue( [self properties: properties containKey: @"balance"] );
    XCTAssertFalse( [self properties: properties containKey: @"name"] );
    XCTAssertFalse( [self properties: properties containKey: @"timeStamp"] );
    XCTAssertFalse( [self properties: properties containKey: @"birthYear"] );
    
}

-(void)testExplicitPropertiesDictionaryCreation {
    
    NSArray <NSString *> *propertyList = [MAXJsonAdapterRuntimeUtilities MAXJACreatePropertyNameListWithouthNSObjectPropertiesWithClass: [MAXJAExplicitPropertiesObject class] ];
    
    NSArray <MAXJsonAdapterProperty *> *properties = [MAXJsonAdapterPropertyMapper MAXJAMapPropertyListForDictionaryCreation: propertyList delegate: [[MAXJAExplicitPropertiesObject alloc] init] ];
    
    XCTAssertTrue( properties.count == 2 );
    XCTAssertTrue( [self properties: properties containKey: @"name"] );
    XCTAssertTrue( [self properties: properties containKey: @"timeStamp"] );
    XCTAssertFalse( [self properties: properties containKey: @"title"] );
    XCTAssertFalse( [self properties: properties containKey: @"balance"] );
    XCTAssertFalse( [self properties: properties containKey: @"birthYear"] );

    
}

#pragma mark - Without delegate

-(void)testExplicitSingleProperty {
    
    NSArray <NSString *> *propertyList = [MAXJsonAdapterRuntimeUtilities MAXJACreatePropertyNameListWithouthNSObjectPropertiesWithClass: [MAXJAIgnoredPropertiesObject class] ];
    
    NSArray <NSString *> *propertyListWithExplicitProperties = [MAXJsonAdapterPropertyMapper MAXJAPropertiesToUseFromPropertyList: propertyList propertiesToUse: @[@"title"]];
    
    XCTAssertNotNil( propertyListWithExplicitProperties );
    XCTAssertTrue( propertyListWithExplicitProperties.count == 1 );
    XCTAssertTrue( [MAXJsonAdapterNSArraryUtilities array: propertyListWithExplicitProperties containsString: @"title"] );
    XCTAssertFalse( [MAXJsonAdapterNSArraryUtilities array: propertyListWithExplicitProperties containsString: @"age"] );
    XCTAssertFalse( [MAXJsonAdapterNSArraryUtilities array: propertyListWithExplicitProperties containsString: @"name"] );

    
}

#pragma mark - IGNORED PROPERTIES

#pragma mark - Remove Ignored Properties With Delegate

-(void)testRemoveIgnoredPropertiesObjectCreation {
    
    NSArray <NSString *> *propertyList = [MAXJsonAdapterRuntimeUtilities MAXJACreatePropertyNameListWithouthNSObjectPropertiesWithClass: [MAXJAIgnoredPropertiesObject class] ];
    
    NSArray <MAXJsonAdapterProperty *> *properties = [MAXJsonAdapterPropertyMapper MAXJAMapPropertyListForObjectCreation: propertyList delegate: [[MAXJAIgnoredPropertiesObject alloc] init] ];
    
    XCTAssertTrue( properties.count == 2 );
    XCTAssertTrue( [self properties: properties containKey: @"title"] );
    XCTAssertTrue( [self properties: properties containKey: @"age"] );
    XCTAssertFalse( [self properties: properties containKey: @"name"] );
    
}

-(void)testRemoveIgnoredPropertiesDictionaryCreation {
    
    NSArray <NSString *> *propertyList = [MAXJsonAdapterRuntimeUtilities MAXJACreatePropertyNameListWithouthNSObjectPropertiesWithClass: [MAXJAIgnoredPropertiesObject class] ];
    
    NSArray <MAXJsonAdapterProperty *> *properties = [MAXJsonAdapterPropertyMapper MAXJAMapPropertyListForDictionaryCreation: propertyList delegate: [[MAXJAIgnoredPropertiesObject alloc] init] ];
    
    XCTAssertTrue( properties.count == 2 );
    XCTAssertTrue( [self properties: properties containKey: @"name"] );
    XCTAssertTrue( [self properties: properties containKey: @"age"] );
    XCTAssertFalse( [self properties: properties containKey: @"title"] );
    
    
}

#pragma mark - Remove Ignored Properties Without Delegate

-(void)testRemoveSingleIgnoredProperty {
    
    NSArray <NSString *> *ignoredProperties = @[@"title"];
    
    NSArray <NSString *> *propertyList = [MAXJsonAdapterRuntimeUtilities MAXJACreatePropertyNameListWithouthNSObjectPropertiesWithClass: [MAXJAIgnoredPropertiesObject class] ];
    
    NSArray <NSString *> *propertyListWithRemovedProperties = [MAXJsonAdapterPropertyMapper MAXJARemoveIgnoredPropertiesFromPropertyList: propertyList ignoredProperties: ignoredProperties];
    
    XCTAssertTrue( propertyListWithRemovedProperties.count == 2 );
    XCTAssertTrue( [MAXJsonAdapterNSArraryUtilities array: propertyListWithRemovedProperties containsString: @"name"] );
    XCTAssertTrue( [MAXJsonAdapterNSArraryUtilities array: propertyListWithRemovedProperties containsString: @"age"] );
    XCTAssertFalse( [MAXJsonAdapterNSArraryUtilities array: propertyListWithRemovedProperties containsString: @"title"] );
    
}

-(void)testRemoveTwoIngoredProperties {
    
    NSArray <NSString *> *ignoredProperties = @[@"title", @"age"];
    
    NSArray <NSString *> *propertyList = [MAXJsonAdapterRuntimeUtilities MAXJACreatePropertyNameListWithouthNSObjectPropertiesWithClass: [MAXJAIgnoredPropertiesObject class] ];
    
    NSArray <NSString *> *propertyListWithRemovedProperties = [MAXJsonAdapterPropertyMapper MAXJARemoveIgnoredPropertiesFromPropertyList: propertyList ignoredProperties: ignoredProperties];
    
    XCTAssertTrue( propertyListWithRemovedProperties.count == 1 );
    XCTAssertTrue( [MAXJsonAdapterNSArraryUtilities array: propertyListWithRemovedProperties containsString: @"name"] );
    XCTAssertFalse( [MAXJsonAdapterNSArraryUtilities array: propertyListWithRemovedProperties containsString: @"title"] );
    XCTAssertFalse( [MAXJsonAdapterNSArraryUtilities array: propertyListWithRemovedProperties containsString: @"age"] );
    
}

#pragma mark - Helpers

-(BOOL)properties:(NSArray <MAXJsonAdapterProperty *> *)properties containKey:(NSString *)key {
    
    for (MAXJsonAdapterProperty *currentProperty in properties) {
        
        if ([currentProperty.propertyKey isEqualToString: key] == YES) {
            
            return YES;
        }
        
    }
    
    return NO;
}

-(nullable MAXJsonAdapterProperty *)findPropertyWithKey:(NSString *)key inProperties:(NSArray <MAXJsonAdapterProperty *> *)properties {
    
    for (MAXJsonAdapterProperty *currentProperty in properties) {
        
        if ([currentProperty.propertyKey isEqualToString: key] == YES) {
            
            return currentProperty;
        }
        
    }
    
    return nil;
}

@end
