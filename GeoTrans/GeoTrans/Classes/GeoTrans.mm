//
//  GeoTrans.m
//  Pods
//
//  Created by Chuyen Trung Tran on 2/20/17.
//
//

#include <iostream>
#include <string>

#import "GeoTrans.h"
#include "CoordinateConversionService.h"
#include "CoordinateSystemParameters.h"
#include "GeodeticParameters.h"
#include "CoordinateTuple.h"
#include "GeodeticCoordinates.h"
#include "CartesianCoordinates.h"
#include "Accuracy.h"
#include "MGRSorUSNGCoordinates.h"
#include "UTMParameters.h"
#include "UTMCoordinates.h"
#include "CoordinateType.h"
#include "HeightType.h"
#include "CoordinateConversionException.h"
#include "DatumLibrary.h"

//#include "TestCppClass.hpp"

using namespace MSP::CCS;


/**
 * Sample code to demontrate how to use the MSP Coordinate Conversion Service.
 *
 * Includes the following conversions:
 *
 * |=============================|=============================|
 * | Source                      | Target                      |
 * |=============================+=============================|
 * | Geodetic (Ellipsoid Height) | Geocentric                  |
 * | Geocentric                  | Geodetic (Ellipsoid Height) |
 * |-----------------------------+-----------------------------|
 * | Geocentric                  | Geodetic (MSL EGM 96 15M)   |
 * |-----------------------------+-----------------------------|
 * | Geodetic (Ellipsoid Height) | Geodetic (MSL EGM 96 15M)   |
 * | Geodetic (MSL EGM 96 15M)   | Geodetic (Ellipsoid Height) |
 * |-----------------------------+-----------------------------|
 * | Geocentric                  | UTM                         |
 * |-----------------------------+-----------------------------|
 * | Geocentric                  | MGRS                        |
 * |-----------------------------+-----------------------------|
 *
 **/


/**
 * Function which uses the given Geodetic (Ellipsoid Height) to Geocentric
 * Coordinate Conversion Service, 'ccsGeodeticEllipsoidToGeocentric', to
 * convert the given lat, lon, and height to x, y, z coordinates.
 **/
void convertGeodeticEllipsoidToGeocentric(
                                          CoordinateConversionService& ccsGeodeticEllipsoidToGeocentric,
                                          double lat,
                                          double lon,
                                          double height,
                                          double& x,
                                          double& y,
                                          double& z)
{
    Accuracy sourceAccuracy;
    Accuracy targetAccuracy;
    GeodeticCoordinates sourceCoordinates(
                                                    CoordinateType::geodetic, lon, lat, height);
    CartesianCoordinates targetCoordinates(
                                                     CoordinateType::geocentric);
    
    ccsGeodeticEllipsoidToGeocentric.convertSourceToTarget(
                                                           &sourceCoordinates,
                                                           &sourceAccuracy,
                                                           targetCoordinates,
                                                           targetAccuracy);
    
    x = targetCoordinates.x();
    y = targetCoordinates.y();
    z = targetCoordinates.z();
}


/**
 * Function which uses the given Geodetic (Ellipsoid Height) to Geocentric
 * Coordinate Conversion Service, 'ccsGeodeticEllipsoidToGeocentric', to
 * convert the given x, y, z coordinates to a lat, lon, and height.
 **/
void convertGeocentricToGeodeticEllipsoid(
                                          CoordinateConversionService& ccsGeodeticEllipsoidToGeocentric,
                                          double x,
                                          double y,
                                          double z,
                                          double& lat,
                                          double& lon,
                                          double& height)
{
    Accuracy geocentricAccuracy;
    Accuracy geodeticAccuracy;
    CartesianCoordinates geocentricCoordinates(
                                                         CoordinateType::geocentric, x, y, z);
    GeodeticCoordinates geodeticCoordinates;
    
    // Note that the Geodetic (Ellipsoid Height) to Geocentric Coordinate
    // Conversion Service is used here in conjunction with the
    // convertTargetToSource() method (as opposed to a Geocentric to
    // Geodetic (Ellipsoid Height) Coordinate Conversion Service in
    // conjunction with the convertSourceToTarget() method)
    ccsGeodeticEllipsoidToGeocentric.convertTargetToSource(
                                                           &geocentricCoordinates,
                                                           &geocentricAccuracy,
                                                           geodeticCoordinates,
                                                           geodeticAccuracy);
    
    lat = geodeticCoordinates.latitude();
    lon = geodeticCoordinates.longitude();
    height = geodeticCoordinates.height();
}


/**
 * Function which uses the given Geocentric to Geodetic (MSL EGM 96 15M)
 * Coordinate Conversion Service, 'ccsGeocentricToGeodeticMslEgm96', to
 * convert the given x, y, z coordinates to a lat, lon, and height.
 **/
void convertGeocentricToGeodeticMslEgm96(
                                         CoordinateConversionService& ccsGeocentricToGeodeticMslEgm96,
                                         double x,
                                         double y,
                                         double z,
                                         double& lat,
                                         double& lon,
                                         double& height)
{
    Accuracy sourceAccuracy;
    Accuracy targetAccuracy;
    CartesianCoordinates sourceCoordinates(
                                                     CoordinateType::geocentric, x, y, z);
    GeodeticCoordinates targetCoordinates(
                                                    CoordinateType::geodetic, lon, lat, height);
    
    ccsGeocentricToGeodeticMslEgm96.convertSourceToTarget(
                                                          &sourceCoordinates,
                                                          &sourceAccuracy,
                                                          targetCoordinates,
                                                          targetAccuracy );
    
    lat = targetCoordinates.latitude();
    lon = targetCoordinates.longitude();
    height = targetCoordinates.height();
}

/////Mod
/**
 * Function which uses the given Geocentric to Geodetic (MSL EGM)
 * Coordinate Conversion Service, 'ccsGeocentricToGeodeticMsl', to
 * convert the given x, y, z coordinates to a lat, lon, and height.
 **/
void convertGeocentricToGeodeticMslEgm(
                                         CoordinateConversionService& ccsGeocentricToGeodeticMslEgm,
                                         double x,
                                         double y,
                                         double z,
                                         double& lat,
                                         double& lon,
                                         double& height)
{
    Accuracy sourceAccuracy;
    Accuracy targetAccuracy;
    CartesianCoordinates sourceCoordinates(
                                                     CoordinateType::geocentric, x, y, z);
    GeodeticCoordinates targetCoordinates(
                                                    CoordinateType::geodetic, lon, lat, height);
    
    ccsGeocentricToGeodeticMslEgm.convertSourceToTarget(
                                                          &sourceCoordinates,
                                                          &sourceAccuracy,
                                                          targetCoordinates,
                                                          targetAccuracy );
    
    lat = targetCoordinates.latitude();
    lon = targetCoordinates.longitude();
    height = targetCoordinates.height();
}


/**
 * Function which uses the given Geodetic (MSL EGM 96 15M) to Geodetic
 * (Ellipsoid Height) Coordinate Conversion Service,
 * 'ccsMslEgm96ToEllipsoidHeight', to convert the given MSL height at the
 * given lat, lon, to an Ellipsoid height.
 **/
void convertMslEgm96ToEllipsoidHeight(
                                      CoordinateConversionService& ccsMslEgm96ToEllipsoidHeight,
                                      double lat,
                                      double lon,
                                      double mslHeight,
                                      double& ellipsoidHeight)
{
    Accuracy sourceAccuracy;
    Accuracy targetAccuracy;
    GeodeticCoordinates sourceCoordinates(
                                                    CoordinateType::geodetic, lon, lat, mslHeight);
    GeodeticCoordinates targetCoordinates;
    
    ccsMslEgm96ToEllipsoidHeight.convertSourceToTarget(
                                                       &sourceCoordinates,
                                                       &sourceAccuracy,
                                                       targetCoordinates,
                                                       targetAccuracy);
    
    ellipsoidHeight = targetCoordinates.height();
}

/////Mod
/**
 * Function which uses the given Geodetic (MSL EGM) to Geodetic
 * (Ellipsoid Height) Coordinate Conversion Service,
 * 'ccsMslEgmToEllipsoidHeight', to convert the given MSL height at the
 * given lat, lon, to an Ellipsoid height.
 **/
void convertMslEgmToEllipsoidHeight(
                                      CoordinateConversionService& ccsMslEgmToEllipsoidHeight,
                                      double lat,
                                      double lon,
                                      double mslHeight,
                                      double& ellipsoidHeight)
{
    Accuracy sourceAccuracy;
    Accuracy targetAccuracy;
    GeodeticCoordinates sourceCoordinates(
                                                    CoordinateType::geodetic, lon, lat, mslHeight);
    GeodeticCoordinates targetCoordinates;
    
    ccsMslEgmToEllipsoidHeight.convertSourceToTarget(
                                                       &sourceCoordinates,
                                                       &sourceAccuracy,
                                                       targetCoordinates,
                                                       targetAccuracy);
    
    ellipsoidHeight = targetCoordinates.height();
}

/////Mod
/**
 * Function which uses the given Geodetic (Ellipsoid Height) to Geodetic
 * (MSL EGM 96 15M) Coordinate Conversion Service,
 * 'ccsEllipsoidHeightToMslEgm', to convert the given Ellipsoid height at
 * the given lat, lon, to an MSL height.
 **/
void convertEllipsoidHeightToMslEgm(
                                    CoordinateConversionService& ccsEllipsoidHeightToMslEgm,
                                    double lat,
                                    double lon,
                                    double ellipsoidHeight,
                                    double& mslHeight)
{
    Accuracy sourceAccuracy;
    Accuracy targetAccuracy;
    
    GeodeticCoordinates sourceCoordinates(
                                                    CoordinateType::geodetic, lon, lat, ellipsoidHeight);
    GeodeticCoordinates targetCoordinates;
    
    ccsEllipsoidHeightToMslEgm.convertSourceToTarget(
                                                     &sourceCoordinates,
                                                     &sourceAccuracy,
                                                     targetCoordinates,
                                                     targetAccuracy);
    
    mslHeight = targetCoordinates.height();
}

/**
 * Function which uses the given Geodetic (Ellipsoid Height) to Geodetic
 * (MSL EGM 96 15M) Coordinate Conversion Service,
 * 'ccsEllipsoidHeightToMslEgm96', to convert the given Ellipsoid height at
 * the given lat, lon, to an MSL height.
 **/
void convertEllipsoidHeightToMslEgm96(
                                      CoordinateConversionService& ccsEllipsoidHeightToMslEgm96,
                                      double lat,
                                      double lon,
                                      double ellipsoidHeight,
                                      double& mslHeight)
{
    Accuracy sourceAccuracy;
    Accuracy targetAccuracy;
    
    GeodeticCoordinates sourceCoordinates(
                                                    CoordinateType::geodetic, lon, lat, ellipsoidHeight);
    GeodeticCoordinates targetCoordinates;
    
    ccsEllipsoidHeightToMslEgm96.convertSourceToTarget(
                                                       &sourceCoordinates, 
                                                       &sourceAccuracy, 
                                                       targetCoordinates, 
                                                       targetAccuracy);
    
    mslHeight = targetCoordinates.height();
}



/**
 * Function which uses the given Geocentric to UTM Coordinate Conversion
 * Service, 'ccsGeocentricToUtm', to convert the given x, y, z coordinates
 * a UTM zone, hemisphere, Easting and Northing.
 **/
void convertGeocentricToUtm(
                            CoordinateConversionService& ccsGeocentricToUtm,
                            double x,
                            double y,
                            double z, 
                            long& zone,
                            char& hemisphere, 
                            double& easting,
                            double& northing)
{
    Accuracy sourceAccuracy;
    Accuracy targetAccuracy;
    CartesianCoordinates sourceCoordinates(
                                                     CoordinateType::geocentric, x, y, z);
    UTMCoordinates targetCoordinates;
    
    ccsGeocentricToUtm.convertSourceToTarget(
                                             &sourceCoordinates, 
                                             &sourceAccuracy, 
                                             targetCoordinates, 
                                             targetAccuracy);
    
    zone = targetCoordinates.zone();
    hemisphere = targetCoordinates.hemisphere();
    easting = targetCoordinates.easting();
    northing = targetCoordinates.northing();
}

/**
 * Function which uses the given Geocentric to MGRS Coordinate Conversion
 * Service, 'ccsGeocentricToMgrs', to convert the given x, y, z coordinates
 * to an MGRS string and precision.
 **/
std::string convertGeocentricToMgrs(
                                    CoordinateConversionService& ccsGeocentricToMgrs,
                                    double x,
                                    double y,
                                    double z, 
                                    Precision::Enum& precision)
{
    char* p;
    std::string mgrsString;
    
    Accuracy sourceAccuracy;
    Accuracy targetAccuracy;
    CartesianCoordinates sourceCoordinates(
                                                     CoordinateType::geocentric, x, y, z);
    MGRSorUSNGCoordinates targetCoordinates;
    
    ccsGeocentricToMgrs.convertSourceToTarget(
                                              &sourceCoordinates, 
                                              &sourceAccuracy, 
                                              targetCoordinates, 
                                              targetAccuracy );
    
    // Returned value, 'p', points to targetCoordinate's internal character
    // array so assign/copy the character array to mgrsString to avoid
    // introducing memory management issues
    p = targetCoordinates.MGRSString();
    mgrsString = p;
    
    precision = targetCoordinates.precision();
    
    return mgrsString;
}


@interface GeoTrans() {
    //
    // Coordinate System Parameters
    //
    GeodeticParameters ellipsoidParameters;
    
    CoordinateSystemParameters geocentricParameters;
    
    GeodeticParameters mslEgm84TenDegBilinearParameters;
    
    GeodeticParameters mslEgm84ThirtyMinBiLinearParameters;
    
    GeodeticParameters mslEgm84TenDegNaturalSplineParameters;
    
    GeodeticParameters mslEgm96FifteenMinBilinearParameters;
    
    GeodeticParameters mslEgm96VariableNaturalSplineParameters;
    
    GeodeticParameters mslEgm2008TwoPtFiveMinBicubicSplineParameters;
    
    UTMParameters utmParameters;
    
    CoordinateSystemParameters mgrsParameters;
    
    const char* srcCode;
    const char* targetCode;
    HeightType::Enum sourceHeightType;
    HeightType::Enum targetHeightType;
    CoordinateType::Enum sourceCoordinateType;
    CoordinateType::Enum targetCoordinateType;
    
    double _lat;
    double _lng;
    double _alt;
}

//@property TestCppClass *cppItem;

@end

@implementation GeoTrans

- (instancetype)init {
    if (self = [super init]) {
        //
        // Coordinate System Parameters
        //
        ellipsoidParameters = GeodeticParameters(CoordinateType::geodetic, HeightType::ellipsoidHeight);
        
        geocentricParameters = CoordinateSystemParameters(CoordinateType::geocentric);
        
        mslEgm84TenDegBilinearParameters = GeodeticParameters(CoordinateType::geodetic, HeightType::EGM84TenDegBilinear);
        
        mslEgm84ThirtyMinBiLinearParameters = GeodeticParameters(CoordinateType::geodetic, HeightType::EGM84ThirtyMinBiLinear);
        
        mslEgm84TenDegNaturalSplineParameters = GeodeticParameters(CoordinateType::geodetic, HeightType::EGM84TenDegNaturalSpline);
        
        mslEgm96FifteenMinBilinearParameters = GeodeticParameters(CoordinateType::geodetic, HeightType::EGM96FifteenMinBilinear);
        
        mslEgm96VariableNaturalSplineParameters = GeodeticParameters(CoordinateType::geodetic, HeightType::EGM96VariableNaturalSpline);
        
        mslEgm2008TwoPtFiveMinBicubicSplineParameters = GeodeticParameters(CoordinateType::geodetic, HeightType::EGM2008TwoPtFiveMinBicubicSpline);
        
        utmParameters = UTMParameters(CoordinateType::universalTransverseMercator, 1, 0);
        
        mgrsParameters = CoordinateSystemParameters(CoordinateType::militaryGridReferenceSystem);
        
        srcCode = [@"WGE" cStringUsingEncoding:NSASCIIStringEncoding];
        targetCode = [@"WGE" cStringUsingEncoding:NSASCIIStringEncoding];
        
        sourceHeightType = HeightType::noHeight;
        targetHeightType = HeightType::noHeight;
        
        sourceCoordinateType = CoordinateType::geodetic;
        targetCoordinateType = CoordinateType::usNationalGrid;
    }
    return self;
}

- (instancetype)init:(NSString *)sourceDatumCode :(NSString *)targetDatumCode {
    if (self = [self init]) {
        srcCode = [sourceDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
        targetCode = [targetDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    }
    return self;
}

- (void)setSourceDatumCode:(NSString *)sourceDatumCode {
    srcCode = [sourceDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
}

- (void)setTargetDatumCode:(NSString *)targetDatumCode {
    targetCode = [targetDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
}

- (void)setSourceCoordinateType:(NSInteger)index {
    switch (index) {
        case 0:
            sourceCoordinateType = CoordinateType::albersEqualAreaConic;
            break;
        case 1:
            sourceCoordinateType = CoordinateType::azimuthalEquidistant;
            break;
        case 2:
            sourceCoordinateType = CoordinateType::bonne;
            break;
        case 3:
            sourceCoordinateType = CoordinateType::britishNationalGrid;
            break;
        case 4:
            sourceCoordinateType = CoordinateType::cassini;
            break;
        case 5:
            sourceCoordinateType = CoordinateType::cylindricalEqualArea;
            break;
        case 6:
            sourceCoordinateType = CoordinateType::eckert4;
            break;
        case 7:
            sourceCoordinateType = CoordinateType::eckert6;
            break;
        case 8:
            sourceCoordinateType = CoordinateType::equidistantCylindrical;
            break;
        case 9:
            sourceCoordinateType = CoordinateType::geocentric;
            break;
        case 10:
            sourceCoordinateType = CoordinateType::geodetic;
            break;
        case 11:
            sourceCoordinateType = CoordinateType::georef;
            break;
        case 12:
            sourceCoordinateType = CoordinateType::globalAreaReferenceSystem;
            break;
        case 13:
            sourceCoordinateType = CoordinateType::gnomonic;
            break;
        case 14:
            sourceCoordinateType = CoordinateType::lambertConformalConic1Parallel;
            break;
        case 15:
            sourceCoordinateType = CoordinateType::lambertConformalConic2Parallels;
            break;
        case 16:
            sourceCoordinateType = CoordinateType::localCartesian;
            break;
        case 17:
            sourceCoordinateType = CoordinateType::mercatorStandardParallel;
            break;
        case 18:
            sourceCoordinateType = CoordinateType::mercatorScaleFactor;
            break;
        case 19:
            sourceCoordinateType = CoordinateType::militaryGridReferenceSystem;
            break;
        case 20:
            sourceCoordinateType = CoordinateType::millerCylindrical;
            break;
        case 21:
            sourceCoordinateType = CoordinateType::mollweide;
            break;
        case 22:
            sourceCoordinateType = CoordinateType::newZealandMapGrid;
            break;
        case 23:
            sourceCoordinateType = CoordinateType::neys;
            break;
        case 24:
            sourceCoordinateType = CoordinateType::obliqueMercator;
            break;
        case 25:
            sourceCoordinateType = CoordinateType::orthographic;
            break;
        case 26:
            sourceCoordinateType = CoordinateType::polarStereographicStandardParallel;
            break;
        case 27:
            sourceCoordinateType = CoordinateType::polarStereographicScaleFactor;
            break;
        case 28:
            sourceCoordinateType = CoordinateType::polyconic;
            break;
        case 29:
            sourceCoordinateType = CoordinateType::sinusoidal;
            break;
        case 30:
            sourceCoordinateType = CoordinateType::stereographic;
            break;
        case 31:
            sourceCoordinateType = CoordinateType::transverseCylindricalEqualArea;
            break;
        case 32:
            sourceCoordinateType = CoordinateType::transverseMercator;
            break;
        case 33:
            sourceCoordinateType = CoordinateType::universalPolarStereographic;
            break;
        case 34:
            sourceCoordinateType = CoordinateType::universalTransverseMercator;
            break;
        case 35:
            sourceCoordinateType = CoordinateType::usNationalGrid;
            break;
        case 36:
            sourceCoordinateType = CoordinateType::vanDerGrinten;
            break;
        case 37:
            sourceCoordinateType = CoordinateType::webMercator;
            break;
        default:
            break;
    }
}

- (void)setTargetCoordinateType:(NSInteger)index {
    switch (index) {
        case 0:
            targetCoordinateType = CoordinateType::albersEqualAreaConic;
            break;
        case 1:
            targetCoordinateType = CoordinateType::azimuthalEquidistant;
            break;
        case 2:
            targetCoordinateType = CoordinateType::bonne;
            break;
        case 3:
            targetCoordinateType = CoordinateType::britishNationalGrid;
            break;
        case 4:
            targetCoordinateType = CoordinateType::cassini;
            break;
        case 5:
            targetCoordinateType = CoordinateType::cylindricalEqualArea;
            break;
        case 6:
            targetCoordinateType = CoordinateType::eckert4;
            break;
        case 7:
            targetCoordinateType = CoordinateType::eckert6;
            break;
        case 8:
            targetCoordinateType = CoordinateType::equidistantCylindrical;
            break;
        case 9:
            targetCoordinateType = CoordinateType::geocentric;
            break;
        case 10:
            targetCoordinateType = CoordinateType::geodetic;
            break;
        case 11:
            targetCoordinateType = CoordinateType::georef;
            break;
        case 12:
            targetCoordinateType = CoordinateType::globalAreaReferenceSystem;
            break;
        case 13:
            targetCoordinateType = CoordinateType::gnomonic;
            break;
        case 14:
            targetCoordinateType = CoordinateType::lambertConformalConic1Parallel;
            break;
        case 15:
            targetCoordinateType = CoordinateType::lambertConformalConic2Parallels;
            break;
        case 16:
            targetCoordinateType = CoordinateType::localCartesian;
            break;
        case 17:
            targetCoordinateType = CoordinateType::mercatorStandardParallel;
            break;
        case 18:
            targetCoordinateType = CoordinateType::mercatorScaleFactor;
            break;
        case 19:
            targetCoordinateType = CoordinateType::militaryGridReferenceSystem;
            break;
        case 20:
            targetCoordinateType = CoordinateType::millerCylindrical;
            break;
        case 21:
            targetCoordinateType = CoordinateType::mollweide;
            break;
        case 22:
            targetCoordinateType = CoordinateType::newZealandMapGrid;
            break;
        case 23:
            targetCoordinateType = CoordinateType::neys;
            break;
        case 24:
            targetCoordinateType = CoordinateType::obliqueMercator;
            break;
        case 25:
            targetCoordinateType = CoordinateType::orthographic;
            break;
        case 26:
            targetCoordinateType = CoordinateType::polarStereographicStandardParallel;
            break;
        case 27:
            targetCoordinateType = CoordinateType::polarStereographicScaleFactor;
            break;
        case 28:
            targetCoordinateType = CoordinateType::polyconic;
            break;
        case 29:
            targetCoordinateType = CoordinateType::sinusoidal;
            break;
        case 30:
            targetCoordinateType = CoordinateType::stereographic;
            break;
        case 31:
            targetCoordinateType = CoordinateType::transverseCylindricalEqualArea;
            break;
        case 32:
            targetCoordinateType = CoordinateType::transverseMercator;
            break;
        case 33:
            targetCoordinateType = CoordinateType::universalPolarStereographic;
            break;
        case 34:
            targetCoordinateType = CoordinateType::universalTransverseMercator;
            break;
        case 35:
            targetCoordinateType = CoordinateType::usNationalGrid;
            break;
        case 36:
            targetCoordinateType = CoordinateType::vanDerGrinten;
            break;
        case 37:
            targetCoordinateType = CoordinateType::webMercator;
            break;
        default:
            break;
    }
}

- (void)setSourceHeightType:(NSInteger)index {
    switch (index) {
        case 0:
            sourceHeightType = HeightType::noHeight;
            break;
        case 1:
            sourceHeightType = HeightType::ellipsoidHeight;
            break;
        case 2:
            sourceHeightType = HeightType::EGM96FifteenMinBilinear;
            break;
        case 3:
            sourceHeightType = HeightType::EGM96VariableNaturalSpline;
            break;
        case 4:
            sourceHeightType = HeightType::EGM84TenDegBilinear;
            break;
        case 5:
            sourceHeightType = HeightType::EGM84TenDegNaturalSpline;
            break;
        case 6:
            sourceHeightType = HeightType::EGM84ThirtyMinBiLinear;
            break;
        case 7:
            sourceHeightType = HeightType::EGM2008TwoPtFiveMinBicubicSpline;
            break;
            
        default:
            break;
    }
}

- (void)setTargetHeightType:(NSInteger)index {
    switch (index) {
        case 0:
            targetHeightType = HeightType::noHeight;
            break;
        case 1:
            targetHeightType = HeightType::ellipsoidHeight;
            break;
        case 2:
            targetHeightType = HeightType::EGM96FifteenMinBilinear;
            break;
        case 3:
            targetHeightType = HeightType::EGM96VariableNaturalSpline;
            break;
        case 4:
            targetHeightType = HeightType::EGM84TenDegBilinear;
            break;
        case 5:
            targetHeightType = HeightType::EGM84TenDegNaturalSpline;
            break;
        case 6:
            targetHeightType = HeightType::EGM84ThirtyMinBiLinear;
            break;
        case 7:
            targetHeightType = HeightType::EGM2008TwoPtFiveMinBicubicSpline;
            break;
            
        default:
            break;
    }
}

- (void)setLat:(double)latitude lng:(double)longitude alt:(double)altitude {
    _lat = latitude;
    _lng = longitude;
    _alt = altitude;
}

- (int)getUTM:(long *)zone :(NSString **)hemi :(double *)easting :(double *)northing {
    int status = 1;
    try {
        // Chuyển từ lat,lng,alt sang xyz
        double x;
        double y;
        double z;
        try {
            GeodeticParameters ellipsoidParams(CoordinateType::geodetic, HeightType::EGM2008TwoPtFiveMinBicubicSpline);
            CoordinateSystemParameters geocentricParams(CoordinateType::geocentric);
            CoordinateConversionService ccsGeodeticEllipsoidToGeocentric(srcCode, &ellipsoidParams, targetCode, &geocentricParams);
            convertGeodeticEllipsoidToGeocentric(ccsGeodeticEllipsoidToGeocentric,
                                                 _lat, _lng, _alt,
                                                 x, y, z);
            
            UTMParameters utmParams = UTMParameters(CoordinateType::universalTransverseMercator, 1, 0);
            CoordinateConversionService ccsGeodeticToUtm(srcCode, &geocentricParams, targetCode, &utmParams);
            
            char _hemi;
            convertGeocentricToUtm(ccsGeodeticToUtm,
                                   x, y, z,
                                   *zone, _hemi, *easting, *northing);
            
            *hemi = [NSString stringWithFormat:@"%c" , _hemi];
            status = 0;
        } catch(CoordinateConversionException& e) {
            // catch and report any exceptions thrown by the Coordinate
            // Conversion Service
            NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
        } catch(std::exception& e) {
            // catch and report any unexpected exceptions thrown
            NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
        }
        
    } catch(CoordinateConversionException& e) {
        // catch and report any exceptions thrown by the Coordinate
        // Conversion Service
        NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
    } catch(std::exception& e) {
        // catch and report any unexpected exceptions thrown
        NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
    }
    return status;
}

- (int)llh2XYZ:(double)lat :(double)lon :(double)h :(double *)x :(double *)y :(double *)z {
    int status = 1;
    
    try {
        GeodeticParameters ellipsoidParams(CoordinateType::geodetic, HeightType::ellipsoidHeight);
        CoordinateSystemParameters geocentricParams(CoordinateType::geocentric);
        CoordinateConversionService ccsGeodeticEllipsoidToGeocentric(srcCode, &ellipsoidParams, targetCode, &geocentricParams);
        convertGeodeticEllipsoidToGeocentric(ccsGeodeticEllipsoidToGeocentric,
                                             lat, lon, h,
                                             *x, *y, *z);
        status = 0;
    } catch(CoordinateConversionException& e) {
        // catch and report any exceptions thrown by the Coordinate
        // Conversion Service
        NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
    } catch(std::exception& e) {
        // catch and report any unexpected exceptions thrown
        NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
    }
    return status;
}

//
// Geocentric to UTM
//
- (int)geocentric2UTM:(double)x :(double)y :(double)z :(long *)zone :(NSString **)hemi :(double *)easting :(double *)northing {
    int status = 1;
    try {
        CoordinateConversionService ccsGeocentricToUtm(srcCode, &geocentricParameters, targetCode, &utmParameters);
        char _hemi;
        convertGeocentricToUtm(ccsGeocentricToUtm,
                               x, y, z,
                               *zone, _hemi, *easting, *northing);

        *hemi = [NSString stringWithFormat:@"%c" , _hemi];
        
        NSLog(@"Convert Geocentric To UTM");
        NSLog(@"Input:");
        NSLog(@"x: %f", x);
        NSLog(@"y: %f", y);
        NSLog(@"z: %f", z);
        NSLog(@"Output:");
        NSLog(@"Zone: %ld", *zone);
        NSLog(@"Hemisphere: %@", *hemi);
        NSLog(@"Easting: %f", *easting);
        NSLog(@"Northing: %f", *northing);
        status = 0;
    } catch(CoordinateConversionException& e) {
        // catch and report any exceptions thrown by the Coordinate
        // Conversion Service
        NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
    } catch(std::exception& e) {
        // catch and report any unexpected exceptions thrown
        NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
    }
    return status;
}
//
// Geocentric to MGRS
//
- (int)geocentric2MGRS:(double)x :(double)y :(double)z :(NSString **)mgrsStr {
    int status = 1;
    try {
        std::string mgrsString;
        Precision::Enum precision = Precision::second;
        CoordinateConversionService ccsGeocentricToMgrs(srcCode, &geocentricParameters, targetCode, &mgrsParameters);
        mgrsString = convertGeocentricToMgrs(ccsGeocentricToMgrs,
                                             x, y, z,
                                             precision);
        
        NSLog(@"Convert Geocentric To MGRS");
        NSLog(@"Input:");
        NSLog(@"x: %f", x);
        NSLog(@"y: %f", y);
        NSLog(@"z: %f", z);
        NSLog(@"Output:");
        NSLog(@"MGRS: %@", [NSString stringWithUTF8String:mgrsString.c_str()]);
        NSLog(@"Precision: %d", precision);
        *mgrsStr = [NSString stringWithUTF8String:mgrsString.c_str()];
        
        status = 0;
    } catch(CoordinateConversionException& e) {
        // catch and report any exceptions thrown by the Coordinate
        // Conversion Service
        NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
    } catch(std::exception& e) {
        // catch and report any unexpected exceptions thrown
        NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
    }
    return status;
}

- (int)testCoordinateConversion:(NSString *)sourceDatumCode :(NSString *)targetDatumCode {
    // initialize status value to one, indicating an error condition
    int status = 1;
    
    //
    // Coordinate Conversion Services
    //
    CoordinateConversionService ccsGeodeticEllipsoidToGeocentric(srcCode, &ellipsoidParameters, targetCode, &geocentricParameters);
    
    CoordinateConversionService ccsGeocentricToGeodeticMslEgm96(srcCode, &geocentricParameters, targetCode, &mslEgm96FifteenMinBilinearParameters);
    
    CoordinateConversionService ccsMslEgm96ToEllipsoidHeight(srcCode, &mslEgm96FifteenMinBilinearParameters, targetCode, &ellipsoidParameters);
    
    CoordinateConversionService ccsEllipsoidHeightToMslEgm96(srcCode, &ellipsoidParameters, targetCode, &mslEgm96FifteenMinBilinearParameters);
    
    CoordinateConversionService ccsGeocentricToGeodeticMslEgm2008(srcCode, &geocentricParameters, targetCode, &mslEgm2008TwoPtFiveMinBicubicSplineParameters);
    
    CoordinateConversionService ccsMslEgm2008ToEllipsoidHeight(srcCode, &mslEgm2008TwoPtFiveMinBicubicSplineParameters, targetCode, &ellipsoidParameters);
    
    CoordinateConversionService ccsEllipsoidHeightToMslEgm2008(srcCode, &ellipsoidParameters, targetCode, &mslEgm2008TwoPtFiveMinBicubicSplineParameters);
    
    CoordinateConversionService ccsGeocentricToUtm(srcCode, &geocentricParameters, targetCode, &utmParameters);
    
    CoordinateConversionService ccsGeocentricToMgrs(srcCode, &geocentricParameters, targetCode, &mgrsParameters);

    try {
        
        //
        // Geodetic (Ellipsoid Height) to Geocentric
        //
        // Input VN2000 21.0893345504,105.7099585996; 2332898.930,573764.701 #Hanoi (0.3680783249581649,1.8449868297053373)
        // Output WGS84 21.0883504096,105.7118423545; 2332090.939,573938.728 #UTM Zone 48 (0.3680611484609018,1.8450197074306429)
        double lat = 0.3680611484609018;
        double lon = 1.8450197074306429;
        double height = -16.0;
        
        double x, y, z;
        
        convertGeodeticEllipsoidToGeocentric(ccsGeodeticEllipsoidToGeocentric,
                                             lat, lon, height,
                                             x, y, z);
        
        NSLog(@"Convert Geodetic (Ellipsoid Height) to Geocentric");
        NSLog(@"Input:");
        NSLog(@"Lat (radians): %f", lat);
        NSLog(@"Lon (radians): %f", lon);
        NSLog(@"Height(m): %f", height);
        NSLog(@"Output:");
        NSLog(@"x: %f", x);
        NSLog(@"y: %f", y);
        NSLog(@"z: %f", z);
        
        
        //
        // Geocentric to Geodetic (Ellipsoid Height)
        //
        
        // function convertGeocentricToGeodeticEllipsoid() reuses the
        // ccsGeodeticEllipsoidToGeocentric instance to perform the reverse
        // conversion
        convertGeocentricToGeodeticEllipsoid(ccsGeodeticEllipsoidToGeocentric,
                                             x, y, z,
                                             lat, lon, height);
        
        NSLog(@"Revert Geocentric To Geodetic (Ellipsoid Height)");
        NSLog(@"Intput:");
        NSLog(@"x: %f", x);
        NSLog(@"y: %f", y);
        NSLog(@"z: %f", z);
        NSLog(@"Output:");
        NSLog(@"Lat (radians): %f", lat);
        NSLog(@"Lon (radians): %f", lon);
        NSLog(@"Height(m): %f", height);
        
        
        // reuse ccsGeodeticEllipsoidToGeocentric instance to perform another
        // Geodetic (Ellipsoid Height) to Geocentric conversions
        lat = 0.76388;
        lon = 0.60566;
        height = 11.0;
        
        convertGeodeticEllipsoidToGeocentric(ccsGeodeticEllipsoidToGeocentric,
                                             lat, lon, height,
                                             x, y, z);
        
        NSLog(@"Convert Geodetic (Ellipsoid Height) to Geocentric");
        NSLog(@"Input:");
        NSLog(@"Lat (radians): %f", lat);
        NSLog(@"Lon (radians): %f", lon);
        NSLog(@"Height(m): %f", height);
        NSLog(@"Output:");
        NSLog(@"x: %f", x);
        NSLog(@"y: %f", y);
        NSLog(@"z: %f", z);
        
        // reuse ccsGeodeticEllipsoidToGeocentric instance to perform another
        // Geodetic (Ellipsoid Height) to Geocentric conversions
        lat = 0.71458;
        lon = 0.88791;
        height = 22.0;
        
        convertGeodeticEllipsoidToGeocentric(ccsGeodeticEllipsoidToGeocentric,
                                             lat, lon, height,
                                             x, y, z);
        
        NSLog(@"Revert Geocentric To Geodetic (Ellipsoid Height)");
        NSLog(@"Input:");
        NSLog(@"x: %f", x);
        NSLog(@"y: %f", y);
        NSLog(@"z: %f", z);
        NSLog(@"Output:");
        NSLog(@"Lat (radians): %f", lat);
        NSLog(@"Lon (radians): %f", lon);
        NSLog(@"Height(m): %f", height);

        //
        // Geocentric to Geodetic (MSL EGM96 15M)
        //
        x = -1612214.533495;
        y = 5731088.483803;
        z = 2280518.788741;
        
        double mslHeight;
        
        convertGeocentricToGeodeticMslEgm96(ccsGeocentricToGeodeticMslEgm96,
                                            x, y, z,
                                            lat, lon, mslHeight);
        
        NSLog(@"Convert Geocentric To Geodetic MSL EGM96");
        NSLog(@"Input:");
        NSLog(@"x: %f", x);
        NSLog(@"y: %f", y);
        NSLog(@"z: %f", z);
        NSLog(@"Output:");
        NSLog(@"Lat (radians): %f", lat);
        NSLog(@"Lon (radians): %f", lon);
        NSLog(@"MSL EGM96 15M Height: %f", mslHeight);
        
        //
        // Geodetic (MSL EGM96 15M) to Geodetic (Ellipsoid Height)
        //
        convertMslEgm96ToEllipsoidHeight(ccsMslEgm96ToEllipsoidHeight,
                                         lat, lon, mslHeight,
                                         height);
        
        NSLog(@"Convert Geodetic (MSL EMG96 15M Height) To Geodetic (Ellipsoid Height)");
        NSLog(@"Input:");
        NSLog(@"Lat (radians): %f", lat);
        NSLog(@"Lon (radians): %f", lon);
        NSLog(@"MSL EGM96 15M Height: %f", mslHeight);
        NSLog(@"Output:");
        NSLog(@"Height(m): %f", height);
        
        
        //
        // Geodetic (Ellipsoid Height) to Geodetic (MSL EMG96 15M)
        //
        convertEllipsoidHeightToMslEgm96(ccsEllipsoidHeightToMslEgm96,
                                         lat, lon, height,
                                         mslHeight);
        
        NSLog(@"Revert Geodetic (Ellipsoid Height) To Geodetic (MSL EGM96 15M) Height");
        NSLog(@"Input:");
        NSLog(@"Lat (radians): %f", lat);
        NSLog(@"Lon (radians): %f", lon);
        NSLog(@"Height(m): %f", height);
        NSLog(@"Output:");
        NSLog(@"MSL EGM96 15M Height: %f", mslHeight);

        
        
        //////////////////////////////////////////////////////////////
        
        //
        // Geocentric to Geodetic (MSL EGM2008)
        //
        x = -1612214.533495;
        y = 5731088.483803;
        z = 2280518.788741;
        
        convertGeocentricToGeodeticMslEgm(ccsGeocentricToGeodeticMslEgm2008,
                                            x, y, z,
                                            lat, lon, mslHeight);
        
        NSLog(@"Convert Geocentric To Geodetic MSL EGM2008");
        NSLog(@"Input:");
        NSLog(@"x: %f", x);
        NSLog(@"y: %f", y);
        NSLog(@"z: %f", z);
        NSLog(@"Output:");
        NSLog(@"Lat (radians): %f", lat);
        NSLog(@"Lon (radians): %f", lon);
        NSLog(@"MSL EGM2008 Height: %f", mslHeight);
        

        //
        // Geodetic (MSL EGM2008) to Geodetic (Ellipsoid Height)
        //
        convertMslEgmToEllipsoidHeight(ccsMslEgm2008ToEllipsoidHeight,
                                         lat, lon, mslHeight,
                                         height);
        
        NSLog(@"Convert Geodetic (MSL EMG2008 Height) To Geodetic (Ellipsoid Height)");
        NSLog(@"Input:");
        NSLog(@"Lat (radians): %f", lat);
        NSLog(@"Lon (radians): %f", lon);
        NSLog(@"MSL EGM2008 Height: %f", mslHeight);
        NSLog(@"Output:");
        NSLog(@"Height(m): %f", height);
        
        
        //
        // Geodetic (Ellipsoid Height) to Geodetic (MSL EMG2008)
        //
        convertEllipsoidHeightToMslEgm(ccsEllipsoidHeightToMslEgm2008,
                                         lat, lon, height,
                                         mslHeight);
        
        NSLog(@"Revert Geodetic (Ellipsoid Height) To Geodetic (MSL EGM2008) Height");
        NSLog(@"Input:");
        NSLog(@"Lat (radians): %f", lat);
        NSLog(@"Lon (radians): %f", lon);
        NSLog(@"Height(m): %f", height);
        NSLog(@"Output:");
        NSLog(@"MSL EGM2008 Height: %f", mslHeight);

        
        
        
        /////////////////////////////
        
        
        
        //
        // Geocentric to UTM
        //
        long zone;
        char hemi;
        double easting, northing;
        convertGeocentricToUtm(ccsGeocentricToUtm,
                               x, y, z, 
                               zone, hemi, easting, northing);
        
        NSLog(@"Convert Geocentric To UTM");
        NSLog(@"Input:");
        NSLog(@"x: %f", x);
        NSLog(@"y: %f", y);
        NSLog(@"z: %f", z);
        NSLog(@"Output:");
        NSLog(@"Zone: %ld", zone);
        NSLog(@"Hemisphere: %c", hemi);
        NSLog(@"Easting: %f", easting);
        NSLog(@"Northing: %f", northing);
        
        //
        // Geocentric to MGRS
        //
        std::string mgrsString;
        Precision::Enum precision;
        
        mgrsString = convertGeocentricToMgrs(ccsGeocentricToMgrs,
                                             x, y, z, 
                                             precision);
        
        NSLog(@"Convert Geocentric To MGRS");
        NSLog(@"Input:");
        NSLog(@"x: %f", x);
        NSLog(@"y: %f", y);
        NSLog(@"z: %f", z);
        NSLog(@"Output:");
        NSLog(@"MGRS: %@", [NSString stringWithUTF8String:mgrsString.c_str()]);
        NSLog(@"Precision: %d", precision);
        
        // set status value to zero to indicate successful completion
        status = 0;
        
    } catch(CoordinateConversionException& e) {
        // catch and report any exceptions thrown by the Coordinate
        // Conversion Service
        NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
    } catch(std::exception& e) {
        // catch and report any unexpected exceptions thrown
        NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
    }
    
    return status;
}

@end
