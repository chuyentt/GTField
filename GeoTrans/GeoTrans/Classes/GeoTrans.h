//
//  GeoTrans.h
//  Pods
//
//  Created by Chuyen Trung Tran on 2/20/17.
//
//

#import <Foundation/Foundation.h>

@interface GeoTrans : NSObject

- (instancetype)init;
- (instancetype)init:(NSString *)sourceDatumCode :(NSString *)targetDatumCode;
- (void)setSourceDatumCode:(NSString *)sourceDatumCode;
- (void)setTargetDatumCode:(NSString *)targetDatumCode;

- (void)setSourceCoordinateType:(NSInteger)index;
- (void)setTargetCoordinateType:(NSInteger)index;
- (void)setSourceHeightType:(NSInteger)index;
- (void)setTargetHeightType:(NSInteger)index;

- (void)setLat:(double)latitude lng:(double)longitude alt:(double)altitude;

- (int)testCoordinateConversion:(NSString *)sourceDatumCode :(NSString *)targetDatumCode;

- (int)llh2XYZ:(double)lat :(double)lon :(double)h :(double *)x :(double *)y :(double *)z;
- (int)getUTM:(long *)zone :(NSString **)hemi :(double *)easting :(double *)northing;

- (int)geocentric2MGRS:(double)x :(double)y :(double)z :(NSString **)mgrsStr;
- (int)geocentric2UTM:(double)x :(double)y :(double)z :(long *)zone :(NSString **)hemi :(double *)easting :(double *)northing;

@end
