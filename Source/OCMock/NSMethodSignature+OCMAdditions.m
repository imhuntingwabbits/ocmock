//---------------------------------------------------------------------------------------
//  $Id$
//  Copyright (c) 2009 by Mulle Kybernetik. See License file for details.
//---------------------------------------------------------------------------------------

#import "NSMethodSignature+OCMAdditions.h"
#import <objc/runtime.h>


@implementation NSMethodSignature(OCMAdditions)

+ (NSMethodSignature *)signatureForDynamicPropertyMatchingSelector:(SEL)selector inClass:(Class)aClass
{
    BOOL isGetter = YES;
    BOOL isDynamic = NO;
    NSString *propertyName = NSStringFromSelector(selector);
    objc_property_t property = class_getProperty(aClass, [propertyName cStringUsingEncoding:NSASCIIStringEncoding]);
    if(property == NULL) {
        if ([propertyName hasPrefix:@"set"])
        {
            propertyName = [propertyName substringFromIndex:@"set".length];
            propertyName = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[propertyName substringToIndex:1] lowercaseString]];
            NSRange colonRange = [propertyName rangeOfString:@":"];
            if (colonRange.location != NSNotFound) {
                propertyName = [propertyName stringByReplacingCharactersInRange:colonRange withString:@""];
            }
            property = class_getProperty(aClass, [propertyName cStringUsingEncoding:NSASCIIStringEncoding]);
            isGetter = NO;
        }
        
        if (property == NULL) {
            unsigned int propertiesCount = 0;
            objc_property_t *allProperties = class_copyPropertyList(aClass, &propertiesCount);
            NSString *currentPropertyName = nil;
            NSArray *propertyAttributes = nil;
            if (allProperties != NULL) {
                for (unsigned int i=0 ; i < propertiesCount; i++) {
                    currentPropertyName = [NSString stringWithCString:property_getName(allProperties[i]) encoding:NSASCIIStringEncoding];
                    propertyAttributes = [[NSString stringWithCString:property_getAttributes(allProperties[i])
                                                             encoding:NSASCIIStringEncoding] componentsSeparatedByString:@","];
                    for (NSString *attribute in propertyAttributes) {
                        if ([attribute hasSuffix:propertyName]) {
                            if ([attribute hasPrefix:@"S"]) {
                                isGetter = NO;
                            }
                            propertyName = currentPropertyName;
                            property = allProperties[i];
                            i = propertiesCount;
                        }
                    }
                }
                
                free(allProperties);
            }
            
            if (property == NULL) {
                return nil;
            }
        }
    }


    const char *propertyAttributesString = property_getAttributes(property);
    if(propertyAttributesString == NULL)
        return nil;

    NSArray *propertyAttributes = [[NSString stringWithCString:propertyAttributesString
                                                      encoding:NSASCIIStringEncoding] componentsSeparatedByString:@","];
    NSString *typeStr = nil;
    for(NSString *attribute in propertyAttributes)
    {
        if([attribute isEqualToString:@"D"])
        {
            //property is @dynamic, but we can synthesize the signature
            isDynamic = YES;
        }
        else if([attribute hasPrefix:@"T"])
        {
            typeStr = [attribute substringFromIndex:1];
        }
    }

    if(!isDynamic)
        return nil;

    NSRange r = [typeStr rangeOfString:@"\""];
    if(r.location != NSNotFound)
    {
        typeStr = [typeStr substringToIndex:r.location];
    }
    
    const char *str;
    if (isGetter)
    {
        str = [[NSString stringWithFormat:@"%@@:", typeStr] cStringUsingEncoding:NSASCIIStringEncoding];
    } else
    {
        str = [[NSString stringWithFormat:@"v@:%@", typeStr] cStringUsingEncoding:NSASCIIStringEncoding];
    }
    return [NSMethodSignature signatureWithObjCTypes:str];
}

- (const char *)methodReturnTypeWithoutQualifiers
{
	const char *returnType = [self methodReturnType];
	while(strchr("rnNoORV", returnType[0]) != NULL)
		returnType += 1;
	return returnType;
}

- (BOOL)usesSpecialStructureReturn
{
    const char *types = [self methodReturnTypeWithoutQualifiers];

    if((types == NULL) || (types[0] != '{'))
        return NO;

    /* In some cases structures are returned by ref. The rules are complex and depend on the
       architecture, see:

       http://sealiesoftware.com/blog/archive/2008/10/30/objc_explain_objc_msgSend_stret.html
       http://developer.apple.com/library/mac/#documentation/DeveloperTools/Conceptual/LowLevelABI/000-Introduction/introduction.html
       https://github.com/atgreen/libffi/blob/master/src/x86/ffi64.c
       http://www.uclibc.org/docs/psABI-x86_64.pdf
       http://infocenter.arm.com/help/topic/com.arm.doc.ihi0042e/IHI0042E_aapcs.pdf

       NSMethodSignature knows the details but has no API to return it, though it is in
       the debugDescription. Horribly kludgy.
    */
    NSRange range = [[self debugDescription] rangeOfString:@"is special struct return? YES"];
    return range.length > 0;
}

- (NSString *)fullTypeString
{
    NSMutableString *typeString = [NSMutableString string];
    [typeString appendFormat:@"%s", [self methodReturnType]];
    for (NSUInteger i=0; i<[self numberOfArguments]; i++)
        [typeString appendFormat:@"%s", [self getArgumentTypeAtIndex:i]];
    return typeString;
}

- (const char *)fullObjCTypes
{
    return [[self fullTypeString] UTF8String];
}

@end
