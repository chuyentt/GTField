//
//  GeoJSONStyle.m
//  GTField
//
//  Created by Chuyen Trung Tran on 1/16/18.
//  Copyright © 2018 Tran Trung Chuyen. All rights reserved.
//

#import "GeoJSONStyle.h"

@implementation GeoJSONStyle

static NSString *const kGeoJSONStyleStrokeColor = @"stroke";
static NSString *const kGeoJSONStyleStrokeWidth = @"stroke-width";
static NSString *const kGeoJSONStyleStrokeOpacity = @"stroke-opacity";
static NSString *const kGeoJSONStyleFillColor = @"fill";
static NSString *const kGeoJSONStyleFillOpacity = @"fill-opacity";
static NSString *const kGeoJSONStyleMarkerColor = @"marker-color";
static NSString *const kGeoJSONStyleMarkerSize = @"marker-size";
static NSString *const kGeoJSONStyleMarkerSymbol = @"marker-symbol";

- (instancetype)initWithStroke:(UIColor *_Nullable)strokeColor
                   strokeWidth:(CGFloat)strokeWidth
                 strokeOpacity:(CGFloat)strokeOpacity
                          fill:(UIColor *_Nullable)fillColor
                   fillOpacity:(CGFloat)fillOpacity
                   markerColor:(UIColor *_Nullable)markerColor
                    markerSize:(NSString *_Nullable)markerSize
                  markerSymbol:(NSString *_Nullable)markerSymbol {
    if (self = [super init]) {
        _strokeColor = strokeColor;
        _strokeWidth = strokeWidth;
        _strokeOpacity = strokeOpacity;
        _fillColor = fillColor;
        _fillOpacity = fillOpacity;
        _markerColor = markerColor;
        _markerSize = [markerSize copy];
        _markerSymbol = [markerSymbol copy];
    }
    return self;
}

- (instancetype)initWithProperties:(nullable NSDictionary *)properties {
    if (self = [super init]) {
        if ([properties objectForKey:kGeoJSONStyleStrokeColor]) {
            _strokeColor = [self colorFromString:[properties objectForKey:kGeoJSONStyleStrokeColor]];
        } else {
            _strokeColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.1 alpha:1];
        }
        if ([properties objectForKey:kGeoJSONStyleStrokeWidth]) {
            _strokeWidth = [[properties objectForKey:kGeoJSONStyleStrokeWidth] floatValue];
        } else {
            _strokeWidth = 1;
        }
        if ([properties objectForKey:kGeoJSONStyleStrokeOpacity]) {
            _strokeOpacity = [[properties objectForKey:kGeoJSONStyleStrokeOpacity] floatValue];
        } else {
            _strokeOpacity = 1;
        }
        if ([properties objectForKey:kGeoJSONStyleFillColor]) {
            _fillColor = [self colorFromString:[properties objectForKey:kGeoJSONStyleFillColor]];
        } else {
            _fillColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.1 alpha:0.4];
        }
        if ([properties objectForKey:kGeoJSONStyleFillOpacity]) {
            _fillOpacity = [[properties objectForKey:kGeoJSONStyleFillOpacity] floatValue];
        } else {
            _fillOpacity = 0.5;
        }
        if ([properties objectForKey:kGeoJSONStyleMarkerColor]) {
            _markerColor = [self colorFromString:[properties objectForKey:kGeoJSONStyleMarkerColor]];
        } else {
            _markerColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.1 alpha:0.4];
        }
        if ([properties objectForKey:kGeoJSONStyleMarkerSize]) {
            _markerSize = [properties objectForKey:kGeoJSONStyleMarkerSize];
        } else {
            _markerSize = @"medium";
        }
        if ([properties objectForKey:kGeoJSONStyleMarkerSymbol]) {
            _strokeColor = [properties objectForKey:kGeoJSONStyleMarkerSymbol];
        }
    }
    return self;
}

- (UIColor *)colorFromString:(NSString *)string {
    unsigned long long color;
    NSScanner *scanner = [NSScanner scannerWithString:string];
    [scanner scanHexLongLong:&color];
    CGFloat alpha = ((CGFloat) ((color >> 24) & 0xff)) / 255;
    CGFloat blue = ((CGFloat) ((color >> 16) & 0xff)) / 255;
    CGFloat green = ((CGFloat) ((color >> 8) & 0xff)) / 255;
    CGFloat red = ((CGFloat) (color & 0xff)) / 255;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
