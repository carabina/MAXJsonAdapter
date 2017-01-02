//
//  MAXJsonAdapterPropertyMapper.m
//  MAXJsonAdapter
//
//  Created by Mathieu Skulason on 27/12/16.
//  Copyright © 2016 Konta ehf. All rights reserved.
//

#import "MAXJsonAdapterPropertyMapper.h"
#import "MAXJsonAdapterNSArraryUtilities.h"

@implementation MAXJsonAdapterPropertyMapper

#pragma mark - Property Name Map For Object Creation

+(NSArray <MAXJsonAdapterProperty *> *)MAXJAMapPropertyListForObjectCreation:(NSArray <NSString *> *)propertyList delegate:(id<MAXJsonAdapterDelegate>)delegate {
    
    NSArray <NSString *> *propertyListWithoutIgnoredProperties = [NSArray arrayWithArray: propertyList];
    
    // if the properties to be used have been declared explicitly we use those over the properties to ignore
    if ([delegate respondsToSelector: @selector(MAXJAPropertiesForObjectCreation)] == YES) {
        
        NSArray <NSString *> *propertiesForObject = [delegate MAXJAPropertiesForObjectCreation];
        
        propertyListWithoutIgnoredProperties = [self MAXJAPropertiesToUseFromPropertyList: propertyList propertiesToUse: propertiesForObject];
        
    }
    else if ([delegate respondsToSelector: @selector(MAXJAPropertiesToIgnoreObjectCreation)] == YES) {
        
        NSArray <NSString *> *ignoredProperties = [delegate MAXJAPropertiesToIgnoreObjectCreation];
        
        propertyListWithoutIgnoredProperties = [self MAXJARemoveIgnoredPropertiesFromPropertyList: propertyList ignoredProperties: ignoredProperties];
        
    }
    
    // after having removed all the properties which are supposed to be removed create the Adapter PropertyObject which contains all the information for serialization.
    NSArray <MAXJsonAdapterProperty *> *adapterProperties = [self MAXJACreatePropertyForPropertyList: propertyListWithoutIgnoredProperties];
    
    // next we need to add the map for properties
    if ([delegate respondsToSelector: @selector(MAXJAPropertiesToMapObjectCreation)] == YES) {
        
        NSArray <MAXJsonAdapterPropertyMap *> *propertyMaps = [delegate MAXJAPropertiesToMapObjectCreation];
        
        adapterProperties = [self MAXJAMapPropertyList: adapterProperties propertyMaps: propertyMaps];
        
    }
    
    return adapterProperties;
}

#pragma mark - Property Name Map For Dictionary Creation

+(NSArray <MAXJsonAdapterProperty *> *)MAXJAMapPropertyListForDictionaryCreation:(NSArray <NSString *> *)propertyList delegate:(id<MAXJsonAdapterDelegate>)delegate {
    
    NSArray <NSString *> *propertyListWithoutIgnoredProperties = [NSArray arrayWithArray: propertyList];
    
    if ([delegate respondsToSelector: @selector(MAXJAPropertiesForDictionaryCreation)] == YES) {
        
        NSArray <NSString *> *propertiesForDict = [delegate MAXJAPropertiesForDictionaryCreation];
        
        propertyListWithoutIgnoredProperties = [self MAXJAPropertiesToUseFromPropertyList:  propertyList propertiesToUse: propertiesForDict];
        
    }
    else if ([delegate respondsToSelector: @selector(MAXJAPropertiesToIgnoreDictionaryCreation)] == YES) {
        
        NSArray <NSString *> *ignoredProperties = [delegate MAXJAPropertiesToIgnoreDictionaryCreation];
        
        propertyListWithoutIgnoredProperties = [self MAXJARemoveIgnoredPropertiesFromPropertyList: propertyList ignoredProperties: ignoredProperties];
        
    }
    
    // after having removed all the properties which are supposed to be removed create the Adapter PropertyObject which contains all the information for serialization.
    NSArray <MAXJsonAdapterProperty *> *adapterProperties = [self MAXJACreatePropertyForPropertyList: propertyListWithoutIgnoredProperties];
    
    // next we need to add the map for properties
    if ([delegate respondsToSelector: @selector(MAXJAPropertiesToMapDictionaryCreation)] == YES) {
        
        NSArray <MAXJsonAdapterPropertyMap *> *propertyMaps = [delegate MAXJAPropertiesToMapDictionaryCreation];
        
        adapterProperties = [self MAXJAMapPropertyList: adapterProperties propertyMaps: propertyMaps];
        
    }
    
    return adapterProperties;
}

#pragma mark - Helper Methods

+(NSArray <NSString *> *)MAXJARemoveIgnoredPropertiesFromPropertyList:(NSArray <NSString *> *)propertyList ignoredProperties:(NSArray <NSString *> *)ignoredProperties {
    
     NSArray *newPropertyList = [MAXJsonAdapterNSArraryUtilities removeStrings: ignoredProperties fromArray: propertyList];
    
    return newPropertyList;
}

+(NSArray <NSString *> *)MAXJAPropertiesToUseFromPropertyList:(NSArray <NSString *> *)propertyList propertiesToUse:(NSArray <NSString *> *)propertiesToUse {
    
    NSMutableArray *properties = [NSMutableArray array];
    
    for (NSString *currentPropertyName in propertiesToUse) {
        
        if ([MAXJsonAdapterNSArraryUtilities array: propertyList containsString: currentPropertyName] == YES) {
            
            [properties addObject: currentPropertyName];
        }
        
    }
    
    return properties;
}

+(NSArray <MAXJsonAdapterProperty *> *)MAXJAMapPropertyList:(NSArray <MAXJsonAdapterProperty *> *)propertyList propertyMaps:(NSArray <MAXJsonAdapterPropertyMap *> *)propertyMaps {
    
    NSMutableArray *mappedPropertyList = [propertyList mutableCopy];
    
    for (MAXJsonAdapterPropertyMap *currentMap in propertyMaps) {
        
        for (MAXJsonAdapterProperty *currentProperty in mappedPropertyList) {
            
            // the base map property should reference the property you want to map, th enext property incorporates the hierarchy
            // needed to know the mapping.
            if ( [currentMap.key isEqualToString: currentProperty.propertyKey] == YES && currentMap.nextPropertyMap != nil ) {
                
                currentProperty.propertyMap = currentMap.nextPropertyMap;
                
            }
            
        }
        
        
    }
    
    return mappedPropertyList;
}

+(NSArray <MAXJsonAdapterProperty *> *)MAXJACreatePropertyForPropertyList:(NSArray<NSString *> *)propertyList {
    
    NSMutableArray <MAXJsonAdapterProperty *> *properties = [NSMutableArray array];
    
    for (NSString *currentPropertyKey in propertyList) {
        
        MAXJsonAdapterProperty *currentProperty = [[MAXJsonAdapterProperty alloc] init];
        currentProperty.propertyKey = currentPropertyKey;
        
        [properties addObject: currentProperty];
    }
    
    return properties;
}

@end