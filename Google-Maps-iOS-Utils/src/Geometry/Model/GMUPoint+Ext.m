//
//  GMUPoint+Ext.m
//  GTField
//
//  Created by Chuyen Trung Tran on 1/27/18.
//  Copyright © 2018 Tran Trung Chuyen. All rights reserved.
//

#import "GMUPoint+Ext.h"
#import <CoreLocation/CoreLocation.h>

@implementation GMUPoint (Ext)

- (NSDictionary *)geometryDict {
    CLLocationCoordinate2D coord = self.coordinate;
    NSValue *value = [[NSValue alloc] initWithBytes:&coord objCType:@encode(CLLocationCoordinate2D)];
    NSDictionary *geometry = [NSDictionary dictionaryWithObjectsAndKeys:
            value, @"coordinates",
            self.type, @"type", nil];
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"Feature", @"type",
            geometry, @"geometry", nil];
}

@end
