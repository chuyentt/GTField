//
//  GeoJSONStyle.h
//  GTField
//
//  Created by Chuyen Trung Tran on 1/16/18.
//  Copyright © 2018 Tran Trung Chuyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIColor.h>

NS_ASSUME_NONNULL_BEGIN

@interface GeoJSONStyle : NSObject

/**
 * The color for the stroke of a LineString or Polygon.
 */
@property(nonatomic, nullable, readonly) UIColor *strokeColor;

/**
 * The stroke-width of a LineString or Polygon.
 */
@property(nonatomic, readonly) CGFloat strokeWidth;

/**
 * The stroke-opacity of a LineString, Polygon.
 */
@property(nonatomic, readonly) CGFloat strokeOpacity;

/**
 * The color for the fill of a Polygon.
 */
@property(nonatomic, nullable, readonly) UIColor *fillColor;

/**
 * The fill-opacity of a Polygon.
 */
@property(nonatomic, readonly) CGFloat fillOpacity;

/**
 * The marker-color of a Point.
 */
@property(nonatomic, nullable, readonly) UIColor *markerColor;

/**
 * The marker-size of a Point.
 */
@property(nonatomic, nullable, readonly) NSString *markerSize;

/**
 * The marker-symbol of a Point.
 */
@property(nonatomic, nullable, readonly) NSString *markerSymbol;

/**
 * @param strokeColor The color for the stroke of a LineString or Polygon.
 * @param strokeWidth The stroke-width of a LineString or Polygon.
 * @param strokeOpacity The stroke-opacity of a LineString, Polygon.
 * @param fillColor The color for the fill of a Polygon.
 * @param fillOpacity The fill-opacity of a Polygon.
 * @param markerColor The marker-color of a Point.
 * @param markerSize The marker-size of a Point.
 * @param markerSymbol The marker-symbol of a Point.
 */
- (instancetype)initWithStroke:(UIColor *_Nullable)strokeColor
                   strokeWidth:(CGFloat)strokeWidth
                 strokeOpacity:(CGFloat)strokeOpacity
                          fill:(UIColor *_Nullable)fillColor
                   fillOpacity:(CGFloat)fillOpacity
                   markerColor:(UIColor *_Nullable)markerColor
                    markerSize:(NSString *_Nullable)markerSize
                  markerSymbol:(NSString *_Nullable)markerSymbol;

- (instancetype)initWithProperties:(nullable NSDictionary *)properties;

@end

NS_ASSUME_NONNULL_END
