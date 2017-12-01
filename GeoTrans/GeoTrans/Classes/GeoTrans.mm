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
#include "CoordinateTuple.h"
#include "Accuracy.h"
#include "MGRSorUSNGCoordinates.h"
#include "CoordinateType.h"
#include "HeightType.h"
#include "CoordinateConversionException.h"
#include "EllipsoidLibraryImplementation.h"
#include "EllipsoidLibrary.h"
#include "DatumLibraryImplementation.h"
#include "DatumLibrary.h"

#include "CoordinateSystemParameters.h"
#include "EllipsoidParameters.h"
#include "EquidistantCylindricalParameters.h"
#include "GeodeticParameters.h"
#include "GeodeticCoordinates.h"

#include "LocalCartesianParameters.h"
#include "CartesianCoordinates.h"

#include "MercatorScaleFactorParameters.h"
#include "MercatorStandardParallelParameters.h"
#include "MapProjection3Parameters.h"
#include "MapProjection4Parameters.h"
#include "MapProjection5Parameters.h"
#include "MapProjection6Parameters.h"
#include "MapProjectionCoordinates.h"
#include "NeysParameters.h"
#include "ObliqueMercatorParameters.h"
#include "PolarStereographicScaleFactorParameters.h"
#include "PolarStereographicStandardParallelParameters.h"
#include "UTMParameters.h"

#include "BNGCoordinates.h"
#include "UTMCoordinates.h"
#include "UPSCoordinates.h"
#include "GEOREFCoordinates.h"
#include "GARSCoordinates.h"
#include "CartesianCoordinates.h"
#include "MapProjectionCoordinates.h"

#include "TransverseMercator.h"
#include "BritishNationalGrid.h"
#include "MGRS.h"
#include "GEOREF.h"
#include "USNG.h"
#include "UPS.h"
#include "UTM.h"
#include "GARS.h"
#include "LocalCartesian.h"
#include "NZMG.h"
#include "WebMercator.h"
#include "PolarStereographic.h"
#include "AlbersEqualAreaConic.h"
#include "AzimuthalEquidistant.h"
#include "Bonne.h"
#include "Cassini.h"
#include "CylindricalEqualArea.h"
#include "Eckert4.h"
#include "Eckert6.h"
#include "EquidistantCylindrical.h"
#include "Gnomonic.h"
#include "LambertConformalConic.h"
#include "Mercator.h"
#include "MillerCylindrical.h"
#include "Mollweide.h"
#include "Neys.h"
#include "NZMG.h"
#include "ObliqueMercator.h"
#include "Orthographic.h"
#include "Polyconic.h"
#include "PolarStereographic.h"
#include "Sinusoidal.h"
#include "Stereographic.h"
#include "TransverseMercator.h"
#include "TransverseCylindricalEqualArea.h"
#include "VanDerGrinten.h"
#include "WebMercator.h"

using namespace MSP::CCS;

//#include "TestCppClass.hpp"


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

void convertGeodeticMlsEgmToTm(
                               CoordinateConversionService& ccsGeodeticMlsEgmToTm,
                               double lat,
                               double lon,
                               double mslHeight,
                               double& easting,
                               double& northing)
{
    Accuracy sourceAccuracy;
    Accuracy targetAccuracy;
    GeodeticCoordinates sourceCoordinates(
                                          CoordinateType::geodetic, lon, lat, mslHeight);
    MapProjectionCoordinates targetCoordinates;
    
    ccsGeodeticMlsEgmToTm.convertSourceToTarget(
                                            &sourceCoordinates,
                                            &sourceAccuracy,
                                            targetCoordinates,
                                            targetAccuracy);
    
    easting = targetCoordinates.easting();
    northing = targetCoordinates.northing();
}

void convertGeodeticMlsEgmToMapProjection(CoordinateConversionService& ccsGeodeticMlsEgmToMapProjection,
                                          double lat,
                                          double lon,
                                          double mslHeight,
                                          double& easting,
                                          double& northing)
{
    Accuracy sourceAccuracy;
    Accuracy targetAccuracy;
    GeodeticCoordinates sourceCoordinates(CoordinateType::geodetic, lon, lat, mslHeight);
    MapProjectionCoordinates targetCoordinates;
    
    ccsGeodeticMlsEgmToMapProjection.convertSourceToTarget(&sourceCoordinates,
                                                           &sourceAccuracy,
                                                           targetCoordinates,
                                                           targetAccuracy);
    
    easting = targetCoordinates.easting();
    northing = targetCoordinates.northing();
}

void convertMapProjectionToGeodeticMlsEgm(CoordinateConversionService& ccsMapProjectionToGeodeticMlsEgm,
                                          CoordinateType::Enum type,
                                          double easting,
                                          double northing,
                                          double &lat,
                                          double &lon)
{
    Accuracy sourceAccuracy;
    Accuracy targetAccuracy;
    GeodeticCoordinates targetCoordinates;//(CoordinateType::geodetic, lon, lat, mslHeight);
    MapProjectionCoordinates sourceCoordinates(type, easting, northing);
    
    ccsMapProjectionToGeodeticMlsEgm.convertSourceToTarget(&sourceCoordinates,
                                                           &sourceAccuracy,
                                                           targetCoordinates,
                                                           targetAccuracy);
    lat = targetCoordinates.latitude();
    lon = targetCoordinates.longitude();
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

void convertGeocentricToTm(
                            CoordinateConversionService& ccsGeocentricToTm,
                            double x,
                            double y,
                            double z,
                            double& easting,
                            double& northing)
{
    Accuracy sourceAccuracy;
    Accuracy targetAccuracy;
    CartesianCoordinates sourceCoordinates(
                                           CoordinateType::geocentric, x, y, z);
    MapProjectionCoordinates targetCoordinates;
    
    ccsGeocentricToTm.convertSourceToTarget(
                                             &sourceCoordinates,
                                             &sourceAccuracy,
                                             targetCoordinates,
                                             targetAccuracy);
    
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

std::string convertGeodeticMlsEgmToMgrs(
                                    CoordinateConversionService& ccsGeodeticMlsEgmToMgrs,
                                    double lat,
                                    double lon,
                                    double mslHeight,
                                    Precision::Enum& precision)
{
    char* p;
    std::string mgrsString;
    
    Accuracy sourceAccuracy;
    Accuracy targetAccuracy;
    CartesianCoordinates sourceCoordinates(
                                           CoordinateType::geodetic, lon, lat, mslHeight);
    MGRSorUSNGCoordinates targetCoordinates;
    
    ccsGeodeticMlsEgmToMgrs.convertSourceToTarget(
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

std::string convertGeodeticMlsEgmToBNG(
                                        CoordinateConversionService& ccsGeodeticMlsEgmToBNG,
                                        double lat,
                                        double lon,
                                        double mslHeight,
                                        Precision::Enum& precision)
{
    char* p;
    std::string bngString;
    
    Accuracy sourceAccuracy;
    Accuracy targetAccuracy;
    CartesianCoordinates sourceCoordinates(
                                           CoordinateType::geodetic, lon, lat, mslHeight);
    BNGCoordinates targetCoordinates;
    
    ccsGeodeticMlsEgmToBNG.convertSourceToTarget(
                                                 &sourceCoordinates,
                                                 &sourceAccuracy,
                                                 targetCoordinates,
                                                 targetAccuracy );
    
    // Returned value, 'p', points to targetCoordinate's internal character
    // array so assign/copy the character array to mgrsString to avoid
    // introducing memory management issues
    p = targetCoordinates.BNGString();
    bngString = p;
    
    precision = targetCoordinates.precision();
    
    return bngString;
}


@interface GeoTrans() {
    //
    // Coordinate System Parameters
    //
    GeodeticParameters ellipsoidParameters;
    
    CoordinateSystemParameters geocentricParameters;
    
    UTMParameters utmParameters;
    
    CoordinateSystemParameters mgrsParameters;
    
    CoordinateSystemParameters tmParameters;
    
    
    HeightType::Enum sourceHeightType;
    HeightType::Enum targetHeightType;
    CoordinateType::Enum sourceCoordinateType;
    CoordinateType::Enum targetCoordinateType;
    
    
    
}
@property (nonatomic) MSP::CCS::DatumLibrary *datumLibrary;
@property (nonatomic, assign) double lat;
@property (nonatomic, assign) double lng;
@property (nonatomic, assign) double alt;
@property (nonatomic, assign) const char* srcCode;
@property (nonatomic, assign) const char* targetCode;

@end

@implementation GeoTrans
@synthesize srcCode = _srcCode;
@synthesize targetCode = _targetCode;
@synthesize srcDatumCode = _srcDatumCode;
@synthesize targetDatumCode = _targetDatumCode;
@synthesize datumLibrary = _datumLibrary;
@synthesize lat = _lat;
@synthesize lng = _lng;
@synthesize alt = _alt;

- (instancetype)init {
    if (self = [super init]) {
        _srcCode = [@"WGE" cStringUsingEncoding:NSASCIIStringEncoding];
        _targetCode = [getDatumCode() cStringUsingEncoding:NSASCIIStringEncoding];
        _srcDatumCode = @"WGE";
        _targetDatumCode = getDatumCode();
    }
    return self;
}

- (instancetype)init:(NSString *)sourceDatumCode :(NSString *)targetDatumCode {
    if (self = [self init]) {
        _srcCode = [sourceDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
        _targetCode = [targetDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
        _srcDatumCode = sourceDatumCode;
        _targetDatumCode = targetDatumCode;
    }
    return self;
}

// Thiết lập từ chuỗi proj4
- (void)setProj4Str:(NSString *)parameters {
    NSString *proj = @"";
    // Thiết lập lưới chiếu
    CoordinateType::Enum coordinateType;
    if ([proj isEqualToString:@"aea"]) {
        coordinateType = CoordinateType::albersEqualAreaConic;
    }
    if ([proj isEqualToString:@"aeqd"]) {
        coordinateType = CoordinateType::azimuthalEquidistant;
    }
    if ([proj isEqualToString:@"bonne"]) {
        coordinateType = CoordinateType::bonne;
    }
    if ([proj isEqualToString:@"cass"]) {
        coordinateType = CoordinateType::cassini;
    }
    if ([proj isEqualToString:@"cea"]) {
        coordinateType = CoordinateType::cylindricalEqualArea;
    }
    if ([proj isEqualToString:@"eck4"]) {
        coordinateType = CoordinateType::eckert4;
    }
    if ([proj isEqualToString:@"eck6"]) {
        coordinateType = CoordinateType::eckert6;
    }
    if ([proj isEqualToString:@"geocent"]) {
        coordinateType = CoordinateType::geocentric;
    }
    if ([proj isEqualToString:@"lcc"]) {
        coordinateType = CoordinateType::lambertConformalConic1Parallel;
    }
    if ([proj isEqualToString:@"longlat"]) {
        coordinateType = CoordinateType::geodetic;
    }
    if ([proj isEqualToString:@"merc"]) {
        coordinateType = CoordinateType::mercatorScaleFactor;
    }
    if ([proj isEqualToString:@"mill"]) {
        coordinateType = CoordinateType::millerCylindrical;
    }
    if ([proj isEqualToString:@"moll"]) {
        coordinateType = CoordinateType::mollweide;
    }
    if ([proj isEqualToString:@"nzmg"]) {
        coordinateType = CoordinateType::newZealandMapGrid;
    }
    if ([proj isEqualToString:@"omerc"]) {
        coordinateType = CoordinateType::obliqueMercator;
    }
    if ([proj isEqualToString:@"poly"]) {
        coordinateType = CoordinateType::polyconic;
    }
    if ([proj isEqualToString:@"sinu"]) {
        coordinateType = CoordinateType::sinusoidal;
    }
    if ([proj isEqualToString:@"stere"]) {
        coordinateType = CoordinateType::stereographic;
    }
    if ([proj isEqualToString:@"tmerc"]) {
        coordinateType = CoordinateType::transverseMercator;
    }
    if ([proj isEqualToString:@"utm"]) {
        coordinateType = CoordinateType::universalTransverseMercator;
    }
    if ([proj isEqualToString:@"vandg"]) {
        coordinateType = CoordinateType::vanDerGrinten;
    }
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
            sourceHeightType = HeightType::EGM96VariableNaturalSpline;
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
            targetHeightType = HeightType::EGM96VariableNaturalSpline;
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

- (void)defineDatum:(int)datumType dCode:(NSString *)datumCode name:(NSString *)datumName eCode:(NSString *)ellipsoidCode dx:(double)deltaX dy:(double)deltaY dz:(double)deltaZ rx:(double)rotationX ry:(double)rotationY rz:(double)rotationZ sf:(double)scaleFactor {
    const char* dCode = [datumCode cStringUsingEncoding:NSASCIIStringEncoding];
    const char* dName = [datumName cStringUsingEncoding:NSASCIIStringEncoding];
    const char* eCode = [ellipsoidCode cStringUsingEncoding:NSASCIIStringEncoding];
    _datumLibrary->defineDatum(datumType, dCode, dName, eCode, deltaX, deltaY, deltaZ, 0, 0, 0, 0, 0, 0, 0, rotationX, rotationY, rotationZ, scaleFactor);
}




/*
 * Thiết lập mã datum nguồn
 */
//- (void)setSourceDatumCode:(NSString *)code {
//    _srcCode = [code cStringUsingEncoding:NSASCIIStringEncoding];
//    _srcDatumCode = code;
//}

/*
 * Thiết lập mã datum đích, nếu datum chưa có trong file dat thì để là 9999
 * Tham số datum này sẽ được lưu vào một file riêng đồng thời lưu vào
 * USerDefault, hệ thống sẽ đọc từ đó để tính nếu như code là 9999
 * Nếu code khác 9999 thì sẽ đọc trong file dat
 * Cần thông báo cho những người muốn thêm datum vào danh sách chính thức,
 * khi đó sẽ đưa vào file dat
 */
//- (void)setTargetDatumCode:(NSString *)code {
//    _targetCode = [code cStringUsingEncoding:NSASCIIStringEncoding];
//    _targetDatumCode = code;
//}

/*
 * Hệ đặc thù, datum OGB-7, ellipsoid AA
 * Lưu ý: Khi chọn lưới chiếu này thì nhất định phải chọn datum 7 tham số OGB-7 "ORDNANCE GB 1936, Mean (7 Para)"
 * nghĩa là nếu chọn lưới chiếu này thì đặt mặc định tham số ellipsoid là AA vào hệ thống, đồng thời đặt 7 tham số
 * của hệ OGB-7 vào hệ thống
 * Global.swift:
 * 
 */
- (void)getBNGCoordinatesForLat:(double)lat lng:(double)lng alt:(double)alt type:(long)type warningMessage:(NSString **)warningMessage BNGString:(NSString **)BNGString precision:(long *)precision {
    _lat = lat; _lng = lng; _alt = alt;
    _srcCode = [_srcDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    _targetCode = [_targetDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    try {
        try {
            Precision::Enum precision = Precision::tenthOfSecond;
            
            // ========= DATUM TRANSFORMATION ========
            // Tạo tham số nguồn là geodetic (tọa độ trắc địa)
            GeodeticParameters geodeticMlsEgmParams(CoordinateType::geodetic, HeightType::EGM96VariableNaturalSpline);
            
            // Tính chuyển tọa độ sang hệ đích (tọa độ trắc địa)
            CoordinateConversionService ccsGeodeticMlsEgmToGeodetic(_srcCode, &geodeticMlsEgmParams, _targetCode, &geodeticMlsEgmParams);
            
            // Tính chuyển tọa độ trắc địa sang tọa độ trắc địa trên hệ cục bộ
            Accuracy sourceAccuracy;
            Accuracy targetAccuracy;
            GeodeticCoordinates sourceCoordinates(CoordinateType::geodetic, _lng, _lat, _alt);
            GeodeticCoordinates targetCoordinates;
            
            // Tính chuyển tọa độ trắc địa toàn cầu sang tọa độ trắc địa cục bộ có sử sụng datum
            ccsGeodeticMlsEgmToGeodetic.convertSourceToTarget(&sourceCoordinates, &sourceAccuracy, targetCoordinates, targetAccuracy);
            
            double __lat = targetCoordinates.latitude();
            double __lng = targetCoordinates.longitude();
            // ========= END DATUM TRANSFORMATION ========
            
            // Tính chuyển tọa độ trắc địa hệ cục bộ sang tọa độ phẳng lưới chiếu BNG
            // Hệ BNG chỉ sử dụng datum 7 tham số OGB-7 "ORDNANCE GB 1936, Mean (7 Para)"
            char *ellipsoidCode = (char*)"AA";
            BritishNationalGrid br = BritishNationalGrid(ellipsoidCode);
            BNGCoordinates *bngCoordinates = br.convertFromGeodetic(new GeodeticCoordinates(CoordinateType::geodetic, __lng, __lat), precision);
            
            std::string bngString = bngCoordinates->BNGString();
            *BNGString = [NSString stringWithUTF8String:bngString.c_str()];
        } catch(CoordinateConversionException& e) {
            // catch and report any exceptions thrown by the Coordinate
            // Conversion Service
            *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
            NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
        } catch(std::exception& e) {
            // catch and report any unexpected exceptions thrown
            *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
            NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
        }
        
    } catch(CoordinateConversionException& e) {
        // catch and report any exceptions thrown by the Coordinate
        // Conversion Service
        *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
        NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
    } catch(std::exception& e) {
        // catch and report any unexpected exceptions thrown
        *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
        NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
    }
}

- (void)getCartesianCoordinatesForLat:(double)lat lng:(double)lng alt:(double)alt type:(long)type warningMessage:(NSString **)warningMessage x:(double *)x y:(double *)y z:(double *)z {
    _lat = lat; _lng = lng; _alt = alt;
    _srcCode = [_srcDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    _targetCode = [_targetDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    try {
        try {
            
            // ========= DATUM TRANSFORMATION ========
            // Tạo tham số nguồn
            GeodeticParameters sourceParams(CoordinateType::geodetic, HeightType::EGM96VariableNaturalSpline);
            
            // Tính chuyển tọa độ sang hệ đích (tọa độ trắc địa)
            CoordinateConversionService ccsGeodeticMlsEgmToGeodetic(_srcCode, &sourceParams, _targetCode, &sourceParams);
            
            // Tính chuyển tọa độ trắc địa sang tọa trắc địa trên hệ cục bộ
            Accuracy sourceAccuracy;
            Accuracy targetAccuracy;
            GeodeticCoordinates sourceCoordinates(CoordinateType::geodetic, _lng, _lat, _alt);
            GeodeticCoordinates targetCoordinates;
            
            ccsGeodeticMlsEgmToGeodetic.convertSourceToTarget(&sourceCoordinates, &sourceAccuracy, targetCoordinates, targetAccuracy);
            double __lat = targetCoordinates.latitude();
            double __lng = targetCoordinates.longitude();
            // ========= END DATUM TRANSFORMATION ========
            
            // Các tham số cho lưới chiếu LocalCartesian
            double ellipsoidSemiMajorAxis;
            double ellipsoidFlattening;
            double originLongitude;
            double originLatitude;
            double originHeight;
            double orientation;
            
            // Lấy tham số ellipsoid
            getEllipsoidParameters(&ellipsoidSemiMajorAxis, &ellipsoidFlattening);
            
            // Lấy tham số lưới chiếu
            getLocalCartesianParameters(&originLongitude, &originLatitude, &originHeight, &orientation);
            
            // Khởi tạo phép chiếu LocalCartesian
            LocalCartesian lc = LocalCartesian(ellipsoidSemiMajorAxis, ellipsoidFlattening, originLongitude, originLatitude, originHeight, orientation);
            
            // Tính chuyển từ tọa độ trắc địa
            CartesianCoordinates *cartesianCoordinates = lc.convertFromGeodetic(new GeodeticCoordinates(CoordinateType::geodetic, __lng, __lat));
            
            *x = cartesianCoordinates->x();
            *y = cartesianCoordinates->y();
            *z = cartesianCoordinates->z();
        } catch(CoordinateConversionException& e) {
            // catch and report any exceptions thrown by the Coordinate
            // Conversion Service
            *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
            NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
        } catch(std::exception& e) {
            // catch and report any unexpected exceptions thrown
            *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
            NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
        }
    } catch(CoordinateConversionException& e) {
        // catch and report any exceptions thrown by the Coordinate
        // Conversion Service
        *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
        NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
    } catch(std::exception& e) {
        // catch and report any unexpected exceptions thrown
        *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
        NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
    }
}

- (void)getGARSCoordinatesForLat:(double)lat lng:(double)lng alt:(double)alt type:(long)type warningMessage:(NSString **)warningMessage GARSString:(NSString **)GARSString precision:(long *)precision {
    _lat = lat; _lng = lng; _alt = alt;
    _srcCode = [_srcDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    _targetCode = [_targetDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    try {
        try {
            // Tạo tham số nguồn
            GeodeticParameters sourceParams(CoordinateType::geodetic, HeightType::EGM96VariableNaturalSpline);
            
            // Tạo tham số đích
            CoordinateSystemParameters targetParams = CoordinateSystemParameters(CoordinateType::globalAreaReferenceSystem);
            
            CoordinateConversionService ccsGeodeticMlsEgmToMGRSorGARS(_srcCode, &sourceParams, _targetCode, &targetParams);
            
            Accuracy sourceAccuracy;
            Accuracy targetAccuracy;
            
            GeodeticCoordinates sourceCoordinates(CoordinateType::geodetic, _lng, _lat, _alt);
            GARSCoordinates targetCoordinates = GARSCoordinates(CoordinateType::globalAreaReferenceSystem, "361HN37", Precision::tenThousandthOfSecond);
            
            ccsGeodeticMlsEgmToMGRSorGARS.convertSourceToTarget(&sourceCoordinates, &sourceAccuracy, targetCoordinates, targetAccuracy);
            
            *GARSString = [NSString stringWithFormat:@"%s" , targetCoordinates.GARSString()];
            *precision = targetCoordinates.precision();
        } catch(CoordinateConversionException& e) {
            // catch and report any exceptions thrown by the Coordinate
            // Conversion Service
            *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
            NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
        } catch(std::exception& e) {
            // catch and report any unexpected exceptions thrown
            *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
            NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
        }
    } catch(CoordinateConversionException& e) {
        // catch and report any exceptions thrown by the Coordinate
        // Conversion Service
        *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
        NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
    } catch(std::exception& e) {
        // catch and report any unexpected exceptions thrown
        *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
        NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
    }
}

- (void)getGEOREFCoordinatesForLat:(double)lat lng:(double)lng alt:(double)alt type:(long)type warningMessage:(NSString **)warningMessage GEOREFString:(NSString **)GEOREFString precision:(long *)precision {
    _lat = lat; _lng = lng; _alt = alt;
    _srcCode = [_srcDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    _targetCode = [_targetDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    try {
        try {
            // Tạo tham số nguồn
            GeodeticParameters sourceParams(CoordinateType::geodetic, HeightType::EGM96VariableNaturalSpline);
            
            // Tạo tham số đích
            CoordinateSystemParameters targetParams = CoordinateSystemParameters(CoordinateType::georef);
            
            CoordinateConversionService ccsGeodeticMlsEgmToMGRSorGeoref(_srcCode, &sourceParams, _targetCode, &targetParams);
            
            Accuracy sourceAccuracy;
            Accuracy targetAccuracy;
            
            GeodeticCoordinates sourceCoordinates(CoordinateType::geodetic, _lng, _lat, _alt);
            GEOREFCoordinates targetCoordinates = GEOREFCoordinates(CoordinateType::georef, "NGAA0000000000", Precision::tenThousandthOfSecond);
            
            ccsGeodeticMlsEgmToMGRSorGeoref.convertSourceToTarget(&sourceCoordinates, &sourceAccuracy, targetCoordinates, targetAccuracy);
            
            *GEOREFString = [NSString stringWithFormat:@"%s" , targetCoordinates.GEOREFString()];
            *precision = targetCoordinates.precision();
        } catch(CoordinateConversionException& e) {
            // catch and report any exceptions thrown by the Coordinate
            // Conversion Service
            *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
            NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
        } catch(std::exception& e) {
            // catch and report any unexpected exceptions thrown
            *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
            NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
        }
    } catch(CoordinateConversionException& e) {
        // catch and report any exceptions thrown by the Coordinate
        // Conversion Service
        *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
        NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
    } catch(std::exception& e) {
        // catch and report any unexpected exceptions thrown
        *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
        NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
    }
}

- (void)getMGRSorUSNGCoordinatesForLat:(double)lat lng:(double)lng alt:(double)alt type:(long)type warningMessage:(NSString **)warningMessage MGRSString:(NSString **)MGRSString precision:(long *)precision {
    _lat = lat; _lng = lng; _alt = alt;
    _srcCode = [_srcDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    _targetCode = [_targetDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    try {
        try {
            // Tạo tham số nguồn
            GeodeticParameters sourceParams(CoordinateType::geodetic, HeightType::EGM96VariableNaturalSpline);
            
            // Tạo tham số đích
            CoordinateType::Enum coordinateType = (CoordinateType::Enum)type;
            CoordinateSystemParameters targetParams = CoordinateSystemParameters(coordinateType);
            
            CoordinateConversionService ccsGeodeticMlsEgmToMGRSorUSNG(_srcCode, &sourceParams, _targetCode, &targetParams);
            
            Accuracy sourceAccuracy;
            Accuracy targetAccuracy;
            
            GeodeticCoordinates sourceCoordinates(CoordinateType::geodetic, _lng, _lat, _alt);
            
            MGRSorUSNGCoordinates targetCoordinates;
            
            // = MGRSorUSNGCoordinates(CoordinateType::militaryGridReferenceSystem, "31NEA0000000000", Precision::tenThousandthOfSecond);
            
            ccsGeodeticMlsEgmToMGRSorUSNG.convertSourceToTarget(&sourceCoordinates, &sourceAccuracy, targetCoordinates, targetAccuracy);
            
            *MGRSString = [NSString stringWithFormat:@"%s" , targetCoordinates.MGRSString()];
            *precision = targetCoordinates.precision();
        } catch(CoordinateConversionException& e) {
            // catch and report any exceptions thrown by the Coordinate
            // Conversion Service
            *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
            NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
        } catch(std::exception& e) {
            // catch and report any unexpected exceptions thrown
            *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
            NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
        }
        
    } catch(CoordinateConversionException& e) {
        // catch and report any exceptions thrown by the Coordinate
        // Conversion Service
        *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
        NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
    } catch(std::exception& e) {
        // catch and report any unexpected exceptions thrown
        *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
        NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
    }
}

- (void)getMapProjectionCoordinatesForLat:(double)lat lng:(double)lng alt:(double)alt type:(long)type warningMessage:(NSString **)warningMessage easting:(double *)easting northing:(double *)northing {
    _lat = lat; _lng = lng; _alt = alt;
    _srcCode = [_srcDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    _targetCode = [_targetDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    try {
        try {
            // Tạo tham số nguồn
            GeodeticParameters sourceParams(CoordinateType::geodetic, HeightType::EGM96VariableNaturalSpline);
            
            // Các tham số chung cho các lưới chiếu
            double ellipsoidSemiMajorAxis = 6378137.0;
            double ellipsoidFlattening = 1/298.257223563;
            double centralMeridian;
            double standardParallel;
            double falseEasting;
            double falseNorthing;
            double originLatitude;
            double scaleFactor;
            double standardParallel1;
            double standardParallel2;
            double longitude1;
            double latitude1;
            double longitude2;
            double latitude2;
            
            // Lấy tham số ellipsoid
            getEllipsoidParameters(&ellipsoidSemiMajorAxis, &ellipsoidFlattening);
            
            CoordinateType::Enum coordinateType = (CoordinateType::Enum)type;
            switch (coordinateType) {
                    // =>MapProjection3Parameters
                    case CoordinateType::eckert4:
                    case CoordinateType::eckert6:
                    case CoordinateType::millerCylindrical:
                    case CoordinateType::mollweide:
                    case CoordinateType::sinusoidal:
                    case CoordinateType::vanDerGrinten: {
                        // Lấy tham số lưới chiếu đã lưu
                        getMapProjection3Parameters(&centralMeridian, &falseEasting, &falseNorthing);
                        
                        // Tạo tham số lưới chiếu đích
                        MapProjection3Parameters targetParams = MapProjection3Parameters(coordinateType, centralMeridian, falseEasting, falseNorthing);
                        
                        // Thiết lập chuyển đổi
                        CoordinateConversionService ccsGeodeticMlsEgmToMapProjection(_srcCode, &sourceParams, _targetCode, &targetParams);
                        convertGeodeticMlsEgmToMapProjection(ccsGeodeticMlsEgmToMapProjection, _lat, _lng, _alt, *easting, *northing);
                    }
                    break;
                    
                    //=>MapProjection4Parameters
                    case CoordinateType::azimuthalEquidistant:
                    case CoordinateType::bonne:
                    case CoordinateType::cassini:
                    case CoordinateType::cylindricalEqualArea:
                    case CoordinateType::gnomonic:
                    case CoordinateType::orthographic:
                    case CoordinateType::polyconic:
                    case CoordinateType::stereographic: {
                        // Lấy tham số lưới chiếu đã lưu
                        getMapProjection4Parameters(&centralMeridian, &originLatitude, &falseEasting, &falseNorthing);
                        
                        // Tạo tham số lưới chiếu đích
                        MapProjection4Parameters targetParams = MapProjection4Parameters(coordinateType, centralMeridian, originLatitude, falseEasting, falseNorthing);
                        
                        // Thiết lập chuyển đổi
                        CoordinateConversionService ccsGeodeticMlsEgmToMapProjection(_srcCode, &sourceParams, _targetCode, &targetParams);
                        convertGeodeticMlsEgmToMapProjection(ccsGeodeticMlsEgmToMapProjection, _lat, _lng, _alt, *easting, *northing);
                    }
                    break;
                    
                    //=>MapProjection5Parameters
                    case CoordinateType::transverseCylindricalEqualArea:
                    case CoordinateType::transverseMercator:
                    case CoordinateType::lambertConformalConic1Parallel: {
                        // Lấy tham số lưới chiếu đã lưu
                        getMapProjection5Parameters(&centralMeridian, &originLatitude, &scaleFactor, &falseEasting, &falseNorthing);
                        
                        // Tạo tham số lưới chiếu đích
                        MapProjection5Parameters targetParams = MapProjection5Parameters(coordinateType, centralMeridian, originLatitude, scaleFactor, falseEasting, falseNorthing);
                        
                        // Thiết lập chuyển đổi
                        CoordinateConversionService ccsGeodeticMlsEgmToMapProjection(_srcCode, &sourceParams, _targetCode, &targetParams);
                        convertGeodeticMlsEgmToMapProjection(ccsGeodeticMlsEgmToMapProjection, _lat, _lng, _alt, *easting, *northing);
                    }
                    break;
                    
                    //=>MapProjection6Parameters
                    case CoordinateType::lambertConformalConic2Parallels:
                    case CoordinateType::albersEqualAreaConic: {
                        // Lấy tham số lưới chiếu đã lưu
                        getMapProjection6Parameters(&centralMeridian, &originLatitude, &standardParallel1, &standardParallel2, &falseEasting, &falseNorthing);
                        
                        // Tạo tham số lưới chiếu đích
                        MapProjection6Parameters targetParams = MapProjection6Parameters(coordinateType, centralMeridian, originLatitude, standardParallel1, standardParallel2, falseEasting, falseNorthing);
                        
                        // Thiết lập chuyển đổi
                        CoordinateConversionService ccsGeodeticMlsEgmToMapProjection(_srcCode, &sourceParams, _targetCode, &targetParams);
                        convertGeodeticMlsEgmToMapProjection(ccsGeodeticMlsEgmToMapProjection, _lat, _lng, _alt, *easting, *northing);
                    }
                    break;
                    
                    //=>MercatorScaleFactorParameters
                    case CoordinateType::mercatorScaleFactor: {
                        // Lấy tham số lưới chiếu đã lưu
                        getMercatorScaleFactorParameters(&centralMeridian, &scaleFactor, &falseEasting, &falseNorthing);
                        
                        // Tạo tham số lưới chiếu đích
                        MercatorScaleFactorParameters targetParams = MercatorScaleFactorParameters(coordinateType, centralMeridian, scaleFactor, falseEasting, falseNorthing);
                        
                        // Thiết lập chuyển đổi
                        CoordinateConversionService ccsGeodeticMlsEgmToMapProjection(_srcCode, &sourceParams, _targetCode, &targetParams);
                        convertGeodeticMlsEgmToMapProjection(ccsGeodeticMlsEgmToMapProjection, _lat, _lng, _alt, *easting, *northing);
                    }
                    break;
                    
                    //=>MercatorStandardParallelParameters
                    case CoordinateType::mercatorStandardParallel: {
                        // Lấy tham số lưới chiếu đã lưu
                        getMercatorStandardParallelParameters(&centralMeridian, &standardParallel, &scaleFactor, &falseEasting, &falseNorthing);
                        
                        // Tạo tham số lưới chiếu đích
                        MercatorStandardParallelParameters targetParams = MercatorStandardParallelParameters(coordinateType, centralMeridian, standardParallel, scaleFactor, falseEasting, falseNorthing);
                        
                        // Thiết lập chuyển đổi
                        CoordinateConversionService ccsGeodeticMlsEgmToMapProjection(_srcCode, &sourceParams, _targetCode, &targetParams);
                        convertGeodeticMlsEgmToMapProjection(ccsGeodeticMlsEgmToMapProjection, _lat, _lng, _alt, *easting, *northing);
                    }
                    break;
                    
                    //=>EquidistantCylindricalParameters
                    case CoordinateType::equidistantCylindrical: {
                        // Lấy tham số lưới chiếu đã lưu
                        getEquidistantCylindricalParameters(&centralMeridian, &standardParallel, &falseEasting, &falseNorthing);
                        
                        // Tạo tham số lưới chiếu đích
                        EquidistantCylindricalParameters targetParams = EquidistantCylindricalParameters(coordinateType, centralMeridian, standardParallel, falseEasting, falseNorthing);
                        
                        // Thiết lập chuyển đổi
                        CoordinateConversionService ccsGeodeticMlsEgmToMapProjection(_srcCode, &sourceParams, _targetCode, &targetParams);
                        convertGeodeticMlsEgmToMapProjection(ccsGeodeticMlsEgmToMapProjection, _lat, _lng, _alt, *easting, *northing);
                    }
                    break;
                    
                    //=>NeysParameters
                    case CoordinateType::neys: {
                        // Lấy tham số lưới chiếu đã lưu
                        getNeysParameters(&centralMeridian, &originLatitude, &standardParallel, &falseEasting, &falseNorthing);
                        
                        // Tạo tham số lưới chiếu đích
                        NeysParameters targetParams = NeysParameters(coordinateType, centralMeridian, originLatitude, standardParallel, falseEasting, falseNorthing);
                        
                        // Thiết lập chuyển đổi
                        CoordinateConversionService ccsGeodeticMlsEgmToMapProjection(_srcCode, &sourceParams, _targetCode, &targetParams);
                        convertGeodeticMlsEgmToMapProjection(ccsGeodeticMlsEgmToMapProjection, _lat, _lng, _alt, *easting, *northing);
                    }
                    break;
                    
                    //=>
                    case CoordinateType::newZealandMapGrid: {
                        // ========= DATUM TRANSFORMATION ========
                        // Tạo tham số nguồn là geodetic (tọa độ trắc địa)
                        GeodeticParameters geodeticMlsEgmParams(CoordinateType::geodetic, HeightType::EGM96VariableNaturalSpline);
                        
                        // Tính chuyển tọa độ sang hệ đích (tọa độ trắc địa)
                        CoordinateConversionService ccsGeodeticMlsEgmToGeodetic(_srcCode, &geodeticMlsEgmParams, _targetCode, &geodeticMlsEgmParams);
                        
                        // Tính chuyển tọa độ trắc địa sang tọa độ trắc địa trên hệ cục bộ
                        Accuracy sourceAccuracy;
                        Accuracy targetAccuracy;
                        GeodeticCoordinates sourceCoordinates(CoordinateType::geodetic, _lng, _lat, _alt);
                        GeodeticCoordinates targetCoordinates;
                        
                        // Tính chuyển tọa độ trắc địa toàn cầu sang tọa độ trắc địa cục bộ có sử sụng datum
                        ccsGeodeticMlsEgmToGeodetic.convertSourceToTarget(&sourceCoordinates, &sourceAccuracy, targetCoordinates, targetAccuracy);
                        
                        double __lat = targetCoordinates.latitude();
                        double __lng = targetCoordinates.longitude();
                        // ========= END DATUM TRANSFORMATION ========
                        
                        NSString *ellipsoidCode = getEllipsoidCode();
                        char* eCode = (char *)[ellipsoidCode cStringUsingEncoding:NSASCIIStringEncoding];
                        NZMG nzmg = NZMG(eCode);
                        MapProjectionCoordinates *mapProjectionCoordinates = nzmg.convertFromGeodetic(new GeodeticCoordinates(CoordinateType::geodetic, __lng, __lat));
                        *easting = mapProjectionCoordinates->easting();
                        *northing = mapProjectionCoordinates->northing();
                    }
                    break;
                    
                    //=>ObliqueMercatorParameters
                    case CoordinateType::obliqueMercator: {
                        // Lấy tham số lưới chiếu đã lưu
                        getObliqueMercatorParameters(&originLatitude, &longitude1, &latitude1, &longitude2, &latitude2, &falseEasting, &falseNorthing, &scaleFactor);
                        
                        // Tạo tham số lưới chiếu đích
                        ObliqueMercatorParameters targetParams = ObliqueMercatorParameters(coordinateType, originLatitude, longitude1, latitude1, longitude2, latitude2, falseEasting, falseNorthing, scaleFactor);
                        
                        // Thiết lập chuyển đổi
                        CoordinateConversionService ccsGeodeticMlsEgmToMapProjection(_srcCode, &sourceParams, _targetCode, &targetParams);
                        convertGeodeticMlsEgmToMapProjection(ccsGeodeticMlsEgmToMapProjection, _lat, _lng, _alt, *easting, *northing);
                    }
                    break;
                    
                    //=>PolarStereographicScaleFactorParameters
                    case CoordinateType::polarStereographicScaleFactor: {
                        // Lấy tham số lưới chiếu đã lưu
                        getPolarStereographicScaleFactorParameters(&centralMeridian, &scaleFactor, &falseEasting, &falseNorthing);
                        
                        // Tạo tham số lưới chiếu đích
                        char hemisphere = 'N';
                        PolarStereographicScaleFactorParameters targetParams = PolarStereographicScaleFactorParameters(coordinateType, centralMeridian, scaleFactor, hemisphere, falseEasting, falseNorthing);
                        
                        // Thiết lập chuyển đổi
                        CoordinateConversionService ccsGeodeticMlsEgmToMapProjection(_srcCode, &sourceParams, _targetCode, &targetParams);
                        convertGeodeticMlsEgmToMapProjection(ccsGeodeticMlsEgmToMapProjection, _lat, _lng, _alt, *easting, *northing);
                    }
                    break;
                    
                    //=>PolarStereographicStandardParallelParameters
                    case CoordinateType::polarStereographicStandardParallel: {
                        // Lấy tham số lưới chiếu đã lưu
                        getPolarStereographicStandardParallelParameters(&centralMeridian, &standardParallel, &falseEasting, &falseNorthing);
                        
                        // Tạo tham số lưới chiếu đích
                        PolarStereographicStandardParallelParameters targetParams = PolarStereographicStandardParallelParameters(coordinateType, centralMeridian, standardParallel, falseEasting, falseNorthing);
                        
                        // Thiết lập chuyển đổi
                        CoordinateConversionService ccsGeodeticMlsEgmToMapProjection(_srcCode, &sourceParams, _targetCode, &targetParams);
                        convertGeodeticMlsEgmToMapProjection(ccsGeodeticMlsEgmToMapProjection, _lat, _lng, _alt, *easting, *northing);
                    }
                    break;
                    
                    //
                    case CoordinateType::webMercator: {
                        // ========= DATUM TRANSFORMATION ========
                        // Tạo tham số nguồn là geodetic (tọa độ trắc địa)
                        GeodeticParameters geodeticMlsEgmParams(CoordinateType::geodetic, HeightType::EGM96VariableNaturalSpline);
                        
                        // Tính chuyển tọa độ sang hệ đích (tọa độ trắc địa)
                        CoordinateConversionService ccsGeodeticMlsEgmToGeodetic(_srcCode, &geodeticMlsEgmParams, _targetCode, &geodeticMlsEgmParams);
                        
                        // Tính chuyển tọa độ trắc địa sang tọa độ trắc địa trên hệ cục bộ
                        Accuracy sourceAccuracy;
                        Accuracy targetAccuracy;
                        GeodeticCoordinates sourceCoordinates(CoordinateType::geodetic, _lng, _lat, _alt);
                        GeodeticCoordinates targetCoordinates;
                        
                        // Tính chuyển tọa độ trắc địa toàn cầu sang tọa độ trắc địa cục bộ có sử sụng datum
                        ccsGeodeticMlsEgmToGeodetic.convertSourceToTarget(&sourceCoordinates, &sourceAccuracy, targetCoordinates, targetAccuracy);
                        
                        double __lat = targetCoordinates.latitude();
                        double __lng = targetCoordinates.longitude();
                        // ========= END DATUM TRANSFORMATION ========
                        
                        NSString *ellipsoidCode = @"WE"; // Luôn luôn là WE
                        char* eCode = (char *)[ellipsoidCode cStringUsingEncoding:NSASCIIStringEncoding];
                        WebMercator webMercator = WebMercator(eCode);
                        MapProjectionCoordinates *mapProjectionCoordinates = webMercator.convertFromGeodetic(new GeodeticCoordinates(CoordinateType::geodetic, __lng, __lat));
                        *easting = mapProjectionCoordinates->easting();
                        *northing = mapProjectionCoordinates->northing();
                    }
                    break;
                    
                default:
                    break;
            }
        } catch(CoordinateConversionException& e) {
            // catch and report any exceptions thrown by the Coordinate
            // Conversion Service
            *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
            NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
        } catch(std::exception& e) {
            // catch and report any unexpected exceptions thrown
            *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
            NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
        }
        
    } catch(CoordinateConversionException& e) {
        // catch and report any exceptions thrown by the Coordinate
        // Conversion Service
        *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
        NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
    } catch(std::exception& e) {
        // catch and report any unexpected exceptions thrown
        *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
        NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
    }
}


/*
 *
 */
- (void)getUPSCoordinatesForLat:(double)lat lng:(double)lng alt:(double)alt type:(long)type warningMessage:(NSString **)warningMessage hemisphere:(NSString **)hemisphere easting:(double *)easting northing:(double *)northing {
    _lat = lat; _lng = lng; _alt = alt;
    _srcCode = [_srcDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    _targetCode = [_targetDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    try {
        try {
            // Tạo tham số nguồn là geodetic (tọa độ trắc địa)
            GeodeticParameters geodeticMlsEgmParams(CoordinateType::geodetic, HeightType::EGM96VariableNaturalSpline);
            
            // Tính chuyển tọa độ sang hệ đích (tọa độ trắc địa)
            CoordinateConversionService ccsGeodeticMlsEgmToGeodetic(_srcCode, &geodeticMlsEgmParams, _targetCode, &geodeticMlsEgmParams);
            
            // Tính chuyển tọa độ trắc địa sang tọa trắc địa trên hệ cục bộ
            Accuracy sourceAccuracy;
            Accuracy targetAccuracy;
            GeodeticCoordinates sourceCoordinates(CoordinateType::geodetic, _lng, _lat, _alt);
            GeodeticCoordinates targetCoordinates;
            
            ccsGeodeticMlsEgmToGeodetic.convertSourceToTarget(&sourceCoordinates, &sourceAccuracy, targetCoordinates, targetAccuracy);
            
            double __lat = targetCoordinates.latitude();
            double __lng = targetCoordinates.longitude();
            
            // Tính chuyển tọa độ trắc địa hệ cục bộ sang tọa độ phẳng theo lưới chiếu UPS
            // Đọc ellipsoid từ hệ thống: Khi chọn lưới chiếu này bắt buộc phải chọn datum và ellipsoid
            double ellipsoidSemiMajorAxis;
            double ellipsoidFlattening;
            getEllipsoidParameters(&ellipsoidSemiMajorAxis, &ellipsoidFlattening);
            UPS ups = UPS(ellipsoidSemiMajorAxis, ellipsoidFlattening);
            UPSCoordinates *upsCoordinates = ups.convertFromGeodetic(new GeodeticCoordinates(CoordinateType::geodetic, __lng, __lat));
            
            char _hemi = upsCoordinates->hemisphere();
            *hemisphere = [NSString stringWithFormat:@"%c" , _hemi];
            *easting = upsCoordinates->easting();
            *northing = upsCoordinates->northing();
        } catch(CoordinateConversionException& e) {
            // catch and report any exceptions thrown by the Coordinate
            // Conversion Service
            *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
            NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
        } catch(std::exception& e) {
            // catch and report any unexpected exceptions thrown
            *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
            NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
        }
        
    } catch(CoordinateConversionException& e) {
        // catch and report any exceptions thrown by the Coordinate
        // Conversion Service
        *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
        NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
    } catch(std::exception& e) {
        // catch and report any unexpected exceptions thrown
        *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
        NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
    }
}

- (void)getUTMCoordinatesForLat:(double)lat lng:(double)lng alt:(double)alt type:(long)type warningMessage:(NSString **)warningMessage zone:(long *)zone hemisphere:(NSString **)hemisphere easting:(double *)easting northing:(double *)northing {
    _lat = lat; _lng = lng; _alt = alt;
    _srcCode = [_srcDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    _targetCode = [_targetDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    try {
        try {
            // Tạo tham số nguồn
            GeodeticParameters sourceParams(CoordinateType::geodetic, HeightType::EGM96VariableNaturalSpline);
            
            // Tạo tham số đích
            UTMParameters targetParams = UTMParameters(CoordinateType::universalTransverseMercator, 1, 0);
            
            CoordinateConversionService ccsGeodeticMlsEgmToUTM(_srcCode, &sourceParams, _targetCode, &targetParams);
            
            Accuracy sourceAccuracy;
            Accuracy targetAccuracy;
            GeodeticCoordinates sourceCoordinates(CoordinateType::geodetic, _lng, _lat, _alt);
            UTMCoordinates targetCoordinates;
            
            ccsGeodeticMlsEgmToUTM.convertSourceToTarget(&sourceCoordinates,
                                                         &sourceAccuracy,
                                                         targetCoordinates,
                                                         targetAccuracy);
            
            *zone = targetCoordinates.zone();
            char _hemi = targetCoordinates.hemisphere();
            *hemisphere = [NSString stringWithFormat:@"%c" , _hemi];
            *easting = targetCoordinates.easting();
            *northing = targetCoordinates.northing();
        } catch(CoordinateConversionException& e) {
            // catch and report any exceptions thrown by the Coordinate
            // Conversion Service
            *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
            NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
        } catch(std::exception& e) {
            // catch and report any unexpected exceptions thrown
            *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
            NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
        }
        
    } catch(CoordinateConversionException& e) {
        // catch and report any exceptions thrown by the Coordinate
        // Conversion Service
        *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
        NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
    } catch(std::exception& e) {
        // catch and report any unexpected exceptions thrown
        *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
        NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
    }
}


//===============================
// Convert from local to geodetic
- (void)getGeodeticForBNGCoordinates:(double *)lat lng:(double *)lng alt:(double *)alt warningMessage:(NSString **)warningMessage type:(long)type BNGString:(NSString *)BNGString precision:(long)precision height:(double)height hType:(long)hType {
    _srcCode = [_srcDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    _targetCode = [_targetDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    try {
        try {
            Precision::Enum precision = Precision::tenthOfSecond;
            *warningMessage = @"";
            // 1. Tính chuyển từ tọa độ BNG sang tọa độ trắc địa trong cùng hệ
            // 2. Tính chuyển tọa độ trắc địa cục bộ sang tọa độ trắc địa WGS 84
            
            // Hệ BNG chỉ sử dụng datum 7 tham số OGB-7 "ORDNANCE GB 1936, Mean (7 Para)"
            
            BNGCoordinates *bngCoordinates = new BNGCoordinates(CoordinateType::britishNationalGrid, [BNGString cStringUsingEncoding:NSASCIIStringEncoding], precision);
            
            char *ellipsoidCode = (char*)"AA";
            BritishNationalGrid br = BritishNationalGrid(ellipsoidCode);
            
            GeodeticCoordinates *geodeticCoordinates = br.convertToGeodetic(bngCoordinates);
            double __lat = geodeticCoordinates->latitude();
            double __lng = geodeticCoordinates->longitude();
            double __alt = geodeticCoordinates->height();
            
            // ========= DATUM TRANSFORMATION ========
            // Tạo tham số nguồn là geodetic (tọa độ trắc địa)
            GeodeticParameters geodeticMlsEgmParams(CoordinateType::geodetic, HeightType::EGM96VariableNaturalSpline);
            
            // Thiết lập tính chuyển tọa độ sang hệ đích (tọa độ trắc địa)
            CoordinateConversionService ccsGeodeticMlsEgmToGeodetic(_srcCode, &geodeticMlsEgmParams, _targetCode, &geodeticMlsEgmParams);
            
            // Tính chuyển tọa độ trắc địa sang tọa độ trắc địa trên hệ cục bộ
            Accuracy sourceAccuracy;
            Accuracy targetAccuracy;
            
            GeodeticCoordinates sourceCoordinates(CoordinateType::geodetic, __lng, __lat, __alt);
            GeodeticCoordinates targetCoordinates;
            
            // Tính chuyển tọa độ trắc địa cục bộ sang tọa độ trắc địa toàn cầu có sử sụng datum
            ccsGeodeticMlsEgmToGeodetic.convertTargetToSource(&sourceCoordinates, &sourceAccuracy, targetCoordinates, targetAccuracy);
            
            *lat = targetCoordinates.latitude();
            *lng = targetCoordinates.longitude();
            *alt = targetCoordinates.height();
            
            // ========= END DATUM TRANSFORMATION ========
            
        } catch(CoordinateConversionException& e) {
            // catch and report any exceptions thrown by the Coordinate
            // Conversion Service
            *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
            NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
        } catch(std::exception& e) {
            // catch and report any unexpected exceptions thrown
            *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
            NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
        }
        
    } catch(CoordinateConversionException& e) {
        // catch and report any exceptions thrown by the Coordinate
        // Conversion Service
        *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
        NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
    } catch(std::exception& e) {
        // catch and report any unexpected exceptions thrown
        *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
        NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
    }
}

- (void)getGeodeticForMGRSorUSNGCoordinates:(double *)lat lng:(double *)lng alt:(double *)alt warningMessage:(NSString **)warningMessage type:(long)type MGRSString:(NSString *)MGRSString precision:(long)precision height:(double)height hType:(long)hType {
    _srcCode = [_srcDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    _targetCode = [_targetDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    try {
        try {
            Precision::Enum precision = Precision::tenthOfSecond;
            *warningMessage = @"";
            // 1. Tính chuyển từ tọa độ BNG sang tọa độ trắc địa trong cùng hệ
            // 2. Tính chuyển tọa độ trắc địa cục bộ sang tọa độ trắc địa WGS 84
            
            // Hệ BNG chỉ sử dụng datum 7 tham số OGB-7 "ORDNANCE GB 1936, Mean (7 Para)"
            CoordinateType::Enum coordinateType = (CoordinateType::Enum)type;
            MGRSorUSNGCoordinates *mgrsOrUSNGCoordinates = new MGRSorUSNGCoordinates(coordinateType, [MGRSString cStringUsingEncoding:NSASCIIStringEncoding], precision);
            
            NSString *eCode = getEllipsoidCode();
            double a;
            double f;
            getEllipsoidParameters(&a, &f);
            GeodeticCoordinates *geodeticCoordinates = nullptr;
            switch (coordinateType) {
                case CoordinateType::militaryGridReferenceSystem: {
                    MGRS mgrs = MGRS(a, f, (char *)[eCode cStringUsingEncoding:NSASCIIStringEncoding]);
                    geodeticCoordinates = mgrs.convertToGeodetic(mgrsOrUSNGCoordinates);
                    break;
                }
                case CoordinateType::Enum::usNationalGrid: {
                    USNG usng = USNG(a, f, (char *)[eCode cStringUsingEncoding:NSASCIIStringEncoding]);
                    geodeticCoordinates = usng.convertToGeodetic(mgrsOrUSNGCoordinates);
                    break;
                }
                default:
                    break;
            }
            
            double __lat = geodeticCoordinates->latitude();
            double __lng = geodeticCoordinates->longitude();
            double __alt = geodeticCoordinates->height();
            
            // ========= DATUM TRANSFORMATION ========
            // Tạo tham số nguồn là geodetic (tọa độ trắc địa)
            GeodeticParameters geodeticMlsEgmParams(CoordinateType::geodetic, HeightType::EGM96VariableNaturalSpline);
            
            // Thiết lập tính chuyển tọa độ sang hệ đích (tọa độ trắc địa)
            CoordinateConversionService ccsGeodeticMlsEgmToGeodetic(_srcCode, &geodeticMlsEgmParams, _targetCode, &geodeticMlsEgmParams);
            
            // Tính chuyển tọa độ trắc địa sang tọa độ trắc địa trên hệ cục bộ
            Accuracy sourceAccuracy;
            Accuracy targetAccuracy;
            
            GeodeticCoordinates sourceCoordinates(CoordinateType::geodetic, __lng, __lat, __alt);
            GeodeticCoordinates targetCoordinates;
            
            // Tính chuyển tọa độ trắc địa cục bộ sang tọa độ trắc địa toàn cầu có sử sụng datum
            ccsGeodeticMlsEgmToGeodetic.convertTargetToSource(&sourceCoordinates, &sourceAccuracy, targetCoordinates, targetAccuracy);
            
            *lat = targetCoordinates.latitude();
            *lng = targetCoordinates.longitude();
            *alt = targetCoordinates.height();
            
            // ========= END DATUM TRANSFORMATION ========
            
        } catch(CoordinateConversionException& e) {
            // catch and report any exceptions thrown by the Coordinate
            // Conversion Service
            *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
            NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
        } catch(std::exception& e) {
            // catch and report any unexpected exceptions thrown
            *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
            NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
        }
        
    } catch(CoordinateConversionException& e) {
        // catch and report any exceptions thrown by the Coordinate
        // Conversion Service
        *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
        NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
    } catch(std::exception& e) {
        // catch and report any unexpected exceptions thrown
        *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
        NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
    }
}

- (void)getGeodeticForCartesianCoordinates:(double *)lat lng:(double *)lng alt:(double *)alt warningMessage:(NSString **)warningMessage type:(long)type x:(double)x y:(double)y z:(double)z {
    _srcCode = [_srcDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    _targetCode = [_targetDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    try {
        try {
            *warningMessage = @"";
            // 1. Tính chuyển từ tọa độ hiện thời sang tọa độ trắc địa trong cùng hệ
            // 2. Tính chuyển tọa độ trắc địa cục bộ sang tọa độ trắc địa WGS 84
            
            CoordinateType::Enum coordinateType = (CoordinateType::Enum)type;
            CartesianCoordinates *coordinates = new CartesianCoordinates(coordinateType, x, y, z);
            
            double ellipsoidSemiMajorAxis;
            double ellipsoidFlattening;
            getEllipsoidParameters(&ellipsoidSemiMajorAxis, &ellipsoidFlattening);
            double originLongitude;
            double originLatitude;
            double originHeight;
            double orientation;
            getLocalCartesianParameters(&originLongitude, &originLatitude, &originHeight, &orientation);
            LocalCartesian local = LocalCartesian(ellipsoidSemiMajorAxis, ellipsoidFlattening, originLongitude, originLatitude, originHeight, orientation);
            GeodeticCoordinates *geodeticCoordinates = local.convertToGeodetic(coordinates);
            
            double __lat = geodeticCoordinates->latitude();
            double __lng = geodeticCoordinates->longitude();
            double __alt = geodeticCoordinates->height();
            
            // ========= DATUM TRANSFORMATION ========
            // Tạo tham số nguồn là geodetic (tọa độ trắc địa)
            GeodeticParameters geodeticMlsEgmParams(CoordinateType::geodetic, HeightType::EGM96VariableNaturalSpline);
            
            // Thiết lập tính chuyển tọa độ sang hệ đích (tọa độ trắc địa)
            CoordinateConversionService ccsGeodeticMlsEgmToGeodetic(_srcCode, &geodeticMlsEgmParams, _targetCode, &geodeticMlsEgmParams);
            
            // Tính chuyển tọa độ trắc địa sang tọa độ trắc địa trên hệ cục bộ
            Accuracy sourceAccuracy;
            Accuracy targetAccuracy;
            
            GeodeticCoordinates sourceCoordinates(CoordinateType::geodetic, __lng, __lat, __alt);
            GeodeticCoordinates targetCoordinates;
            
            // Tính chuyển tọa độ trắc địa cục bộ sang tọa độ trắc địa toàn cầu có sử sụng datum
            ccsGeodeticMlsEgmToGeodetic.convertTargetToSource(&sourceCoordinates, &sourceAccuracy, targetCoordinates, targetAccuracy);
            
            *lat = targetCoordinates.latitude();
            *lng = targetCoordinates.longitude();
            *alt = targetCoordinates.height();
            
            // ========= END DATUM TRANSFORMATION ========
            
        } catch(CoordinateConversionException& e) {
            // catch and report any exceptions thrown by the Coordinate
            // Conversion Service
            *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
            NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
        } catch(std::exception& e) {
            // catch and report any unexpected exceptions thrown
            *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
            NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
        }
        
    } catch(CoordinateConversionException& e) {
        // catch and report any exceptions thrown by the Coordinate
        // Conversion Service
        *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
        NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
    } catch(std::exception& e) {
        // catch and report any unexpected exceptions thrown
        *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
        NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
    }
}

- (void)getGeodeticForGARSCoordinates:(double *)lat lng:(double *)lng alt:(double *)alt warningMessage:(NSString **)warningMessage type:(long)type GARSString:(NSString *)GARSString precision:(long)precision height:(double)height hType:(long)hType {
    _srcCode = [_srcDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    _targetCode = [_targetDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    try {
        try {
            Precision::Enum precision = Precision::tenthOfSecond;
            *warningMessage = @"";
            // 1. Tính chuyển từ tọa độ hiện thời sang tọa độ trắc địa trong cùng hệ
            // 2. Tính chuyển tọa độ trắc địa cục bộ sang tọa độ trắc địa WGS 84
            
            CoordinateType::Enum coordinateType = (CoordinateType::Enum)type;
            GARSCoordinates *coordinates = new GARSCoordinates(coordinateType, [GARSString cStringUsingEncoding:NSASCIIStringEncoding], precision);
            
            double a;
            double f;
            getEllipsoidParameters(&a, &f);
            GARS gars = GARS();
            GeodeticCoordinates *geodeticCoordinates = gars.convertToGeodetic(coordinates);
            
            double __lat = geodeticCoordinates->latitude();
            double __lng = geodeticCoordinates->longitude();
            double __alt = geodeticCoordinates->height();
            
            // ========= DATUM TRANSFORMATION ========
            // Tạo tham số nguồn là geodetic (tọa độ trắc địa)
            GeodeticParameters geodeticMlsEgmParams(CoordinateType::geodetic, HeightType::EGM96VariableNaturalSpline);
            
            // Thiết lập tính chuyển tọa độ sang hệ đích (tọa độ trắc địa)
            CoordinateConversionService ccsGeodeticMlsEgmToGeodetic(_srcCode, &geodeticMlsEgmParams, _targetCode, &geodeticMlsEgmParams);
            
            // Tính chuyển tọa độ trắc địa sang tọa độ trắc địa trên hệ cục bộ
            Accuracy sourceAccuracy;
            Accuracy targetAccuracy;
            
            GeodeticCoordinates sourceCoordinates(CoordinateType::geodetic, __lng, __lat, __alt);
            GeodeticCoordinates targetCoordinates;
            
            // Tính chuyển tọa độ trắc địa cục bộ sang tọa độ trắc địa toàn cầu có sử sụng datum
            ccsGeodeticMlsEgmToGeodetic.convertTargetToSource(&sourceCoordinates, &sourceAccuracy, targetCoordinates, targetAccuracy);
            
            *lat = targetCoordinates.latitude();
            *lng = targetCoordinates.longitude();
            *alt = targetCoordinates.height();
            
            // ========= END DATUM TRANSFORMATION ========
            
        } catch(CoordinateConversionException& e) {
            // catch and report any exceptions thrown by the Coordinate
            // Conversion Service
            *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
            NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
        } catch(std::exception& e) {
            // catch and report any unexpected exceptions thrown
            *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
            NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
        }
        
    } catch(CoordinateConversionException& e) {
        // catch and report any exceptions thrown by the Coordinate
        // Conversion Service
        *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
        NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
    } catch(std::exception& e) {
        // catch and report any unexpected exceptions thrown
        *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
        NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
    }
}

- (void)getGeodeticForGEOREFCoordinates:(double *)lat lng:(double *)lng alt:(double *)alt warningMessage:(NSString **)warningMessage type:(long)type GEOREFString:(NSString *)GEOREFString precision:(long)precision height:(double)height hType:(long)hType {
    _srcCode = [_srcDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    _targetCode = [_targetDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    try {
        try {
            Precision::Enum precision = Precision::tenthOfSecond;
            *warningMessage = @"";
            // 1. Tính chuyển từ tọa độ GEOREFF sang tọa độ trắc địa trong cùng hệ
            // 2. Tính chuyển tọa độ trắc địa cục bộ sang tọa độ trắc địa WGS 84
            
            CoordinateType::Enum coordinateType = (CoordinateType::Enum)type;
            GEOREFCoordinates *coordinates = new GEOREFCoordinates(coordinateType, [GEOREFString cStringUsingEncoding:NSASCIIStringEncoding], precision);
            
            double a;
            double f;
            getEllipsoidParameters(&a, &f);
            GEOREF georef = GEOREF();
            GeodeticCoordinates *geodeticCoordinates = georef.convertToGeodetic(coordinates);
            
            double __lat = geodeticCoordinates->latitude();
            double __lng = geodeticCoordinates->longitude();
            double __alt = geodeticCoordinates->height();
            
            // ========= DATUM TRANSFORMATION ========
            // Tạo tham số nguồn là geodetic (tọa độ trắc địa)
            GeodeticParameters geodeticMlsEgmParams(CoordinateType::geodetic, HeightType::EGM96VariableNaturalSpline);
            
            // Thiết lập tính chuyển tọa độ sang hệ đích (tọa độ trắc địa)
            CoordinateConversionService ccsGeodeticMlsEgmToGeodetic(_srcCode, &geodeticMlsEgmParams, _targetCode, &geodeticMlsEgmParams);
            
            // Tính chuyển tọa độ trắc địa sang tọa độ trắc địa trên hệ cục bộ
            Accuracy sourceAccuracy;
            Accuracy targetAccuracy;
            
            GeodeticCoordinates sourceCoordinates(CoordinateType::geodetic, __lng, __lat, __alt);
            GeodeticCoordinates targetCoordinates;
            
            // Tính chuyển tọa độ trắc địa cục bộ sang tọa độ trắc địa toàn cầu có sử sụng datum
            ccsGeodeticMlsEgmToGeodetic.convertTargetToSource(&sourceCoordinates, &sourceAccuracy, targetCoordinates, targetAccuracy);
            
            *lat = targetCoordinates.latitude();
            *lng = targetCoordinates.longitude();
            *alt = targetCoordinates.height();
            
            // ========= END DATUM TRANSFORMATION ========
            
        } catch(CoordinateConversionException& e) {
            // catch and report any exceptions thrown by the Coordinate
            // Conversion Service
            *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
            NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
        } catch(std::exception& e) {
            // catch and report any unexpected exceptions thrown
            *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
            NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
        }
        
    } catch(CoordinateConversionException& e) {
        // catch and report any exceptions thrown by the Coordinate
        // Conversion Service
        *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
        NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
    } catch(std::exception& e) {
        // catch and report any unexpected exceptions thrown
        *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
        NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
    }
}

- (void)getGeodeticForMapProjectionCoordinates:(double *)lat lng:(double *)lng alt:(double *)alt warningMessage:(NSString **)warningMessage type:(long)type easting:(double)easting northing:(double)northing height:(double)height hType:(long)hType {
    _srcCode = [_srcDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    _targetCode = [_targetDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    try {
        try {
            *warningMessage = @"";
            // 1. Tính chuyển từ tọa độ hiện tại sang tọa độ trắc địa trong cùng hệ
            // 2. Tính chuyển tọa độ trắc địa cục bộ sang tọa độ trắc địa WGS 84
            
            // Các tham số chung cho các lưới chiếu
            double centralMeridian = 0;
            double standardParallel = 0;
            double falseEasting = 0;
            double falseNorthing = 0;
            double originLatitude = 0;
            double scaleFactor = 1.0;
            double standardParallel1 = 0;
            double standardParallel2 = 0;
            double longitude1 = 0;
            double latitude1 = 0;
            double longitude2 = 0;
            double latitude2 = 0;
            
            CoordinateType::Enum coordinateType = (CoordinateType::Enum)type;
            Accuracy sourceAccuracy;
            Accuracy targetAccuracy;
            MapProjectionCoordinates sourceCoordinates = MapProjectionCoordinates(coordinateType, easting, northing);
            GeodeticCoordinates targetCoordinates;
            
            // Tạo tham số nguồn
            GeodeticParameters sourceParams(CoordinateType::geodetic, HeightType::EGM96VariableNaturalSpline);
            
            switch (coordinateType) {
                case CoordinateType::eckert4:
                case CoordinateType::eckert6:
                case CoordinateType::millerCylindrical:
                case CoordinateType::mollweide:
                case CoordinateType::sinusoidal:
                case CoordinateType::vanDerGrinten: {
                    
                    // Lấy tham số lưới chiếu đã lưu
                    getMapProjection3Parameters(&centralMeridian, &falseEasting, &falseNorthing);
                    
                    // Tạo tham số lưới chiếu đích
                    MapProjection3Parameters targetParams = MapProjection3Parameters(coordinateType, centralMeridian, falseEasting, falseNorthing);
                    
                    // Thiết lập chuyển đổi
                    CoordinateConversionService ccsMapProjectionToGeodeticMlsEgm(_targetCode, &targetParams, _srcCode, &sourceParams);

                    ccsMapProjectionToGeodeticMlsEgm.convertSourceToTarget(&sourceCoordinates,
                                                                           &sourceAccuracy,
                                                                           targetCoordinates,
                                                                           targetAccuracy);
                    *lat = targetCoordinates.latitude();
                    *lng = targetCoordinates.longitude();
                    *alt = height;
                    return;
                }
                case CoordinateType::azimuthalEquidistant:
                case CoordinateType::bonne:
                case CoordinateType::cassini:
                case CoordinateType::cylindricalEqualArea:
                case CoordinateType::gnomonic:
                case CoordinateType::orthographic:
                case CoordinateType::polyconic:
                case CoordinateType::stereographic: {

                    // Lấy tham số lưới chiếu đã lưu
                    getMapProjection4Parameters(&centralMeridian, &originLatitude, &falseEasting, &falseNorthing);
                    
                    // Tạo tham số lưới chiếu đích
                    MapProjection4Parameters targetParams = MapProjection4Parameters(coordinateType, centralMeridian, originLatitude, falseEasting, falseNorthing);
                    
                    // Thiết lập chuyển đổi
                    CoordinateConversionService ccsMapProjectionToGeodeticMlsEgm(_targetCode, &targetParams, _srcCode, &sourceParams);
                    
                    ccsMapProjectionToGeodeticMlsEgm.convertSourceToTarget(&sourceCoordinates,
                                                                           &sourceAccuracy,
                                                                           targetCoordinates,
                                                                           targetAccuracy);
                    *lat = targetCoordinates.latitude();
                    *lng = targetCoordinates.longitude();
                    *alt = height;
                    return;
                }
                case CoordinateType::transverseCylindricalEqualArea:
                case CoordinateType::transverseMercator:
                case CoordinateType::lambertConformalConic1Parallel: {
                    
                    // Lấy tham số lưới chiếu đã lưu
                    getMapProjection5Parameters(&centralMeridian, &originLatitude, &scaleFactor, &falseEasting, &falseNorthing);
                    
                    // Tạo tham số lưới chiếu đích
                    MapProjection5Parameters targetParams = MapProjection5Parameters(coordinateType, centralMeridian, originLatitude, scaleFactor, falseEasting, falseNorthing);
                    
                    // Thiết lập chuyển đổi
                    CoordinateConversionService ccsMapProjectionToGeodeticMlsEgm(_targetCode, &targetParams, _srcCode, &sourceParams);
                    
                    ccsMapProjectionToGeodeticMlsEgm.convertSourceToTarget(&sourceCoordinates,
                                                                           &sourceAccuracy,
                                                                           targetCoordinates,
                                                                           targetAccuracy);
                    *lat = targetCoordinates.latitude();
                    *lng = targetCoordinates.longitude();
                    *alt = height;
                    return;
                }
                case CoordinateType::lambertConformalConic2Parallels:
                case CoordinateType::albersEqualAreaConic: {
                    
                    // Lấy tham số lưới chiếu đã lưu
                    getMapProjection6Parameters(&centralMeridian, &originLatitude, &standardParallel1, &standardParallel2, &falseEasting, &falseNorthing);
                    
                    // Tạo tham số lưới chiếu đích
                    MapProjection6Parameters targetParams = MapProjection6Parameters(coordinateType, centralMeridian, originLatitude, standardParallel1, standardParallel2, falseEasting, falseNorthing);
                    
                    // Thiết lập chuyển đổi
                    CoordinateConversionService ccsMapProjectionToGeodeticMlsEgm(_targetCode, &targetParams, _srcCode, &sourceParams);
                    
                    ccsMapProjectionToGeodeticMlsEgm.convertSourceToTarget(&sourceCoordinates,
                                                                           &sourceAccuracy,
                                                                           targetCoordinates,
                                                                           targetAccuracy);
                    *lat = targetCoordinates.latitude();
                    *lng = targetCoordinates.longitude();
                    *alt = height;
                    return;
                }
                case CoordinateType::mercatorScaleFactor: {
                    
                    // Lấy tham số lưới chiếu đã lưu
                    getMercatorScaleFactorParameters(&centralMeridian, &scaleFactor, &falseEasting, &falseNorthing);
                    
                    // Tạo tham số lưới chiếu đích
                    MercatorScaleFactorParameters targetParams = MercatorScaleFactorParameters(coordinateType, centralMeridian, scaleFactor, falseEasting, falseNorthing);
                    
                    // Thiết lập chuyển đổi
                    CoordinateConversionService ccsMapProjectionToGeodeticMlsEgm(_targetCode, &targetParams, _srcCode, &sourceParams);
                    
                    ccsMapProjectionToGeodeticMlsEgm.convertSourceToTarget(&sourceCoordinates,
                                                                           &sourceAccuracy,
                                                                           targetCoordinates,
                                                                           targetAccuracy);
                    *lat = targetCoordinates.latitude();
                    *lng = targetCoordinates.longitude();
                    *alt = height;
                    return;
                }
                case CoordinateType::mercatorStandardParallel: {
                    
                    // Lấy tham số lưới chiếu đã lưu
                    getMercatorStandardParallelParameters(&centralMeridian, &standardParallel, &scaleFactor, &falseEasting, &falseNorthing);
                    
                    // Tạo tham số lưới chiếu đích
                    MercatorStandardParallelParameters targetParams = MercatorStandardParallelParameters(coordinateType, centralMeridian, standardParallel, scaleFactor, falseEasting, falseNorthing);
                    
                    // Thiết lập chuyển đổi
                    CoordinateConversionService ccsMapProjectionToGeodeticMlsEgm(_targetCode, &targetParams, _srcCode, &sourceParams);
                    
                    ccsMapProjectionToGeodeticMlsEgm.convertSourceToTarget(&sourceCoordinates,
                                                                           &sourceAccuracy,
                                                                           targetCoordinates,
                                                                           targetAccuracy);
                    *lat = targetCoordinates.latitude();
                    *lng = targetCoordinates.longitude();
                    *alt = height;
                    return;
                }
                case CoordinateType::equidistantCylindrical: {
                    
                    // Lấy tham số lưới chiếu đã lưu
                    getEquidistantCylindricalParameters(&centralMeridian, &standardParallel, &falseEasting, &falseNorthing);
                    
                    // Tạo tham số lưới chiếu đích
                    EquidistantCylindricalParameters targetParams = EquidistantCylindricalParameters(coordinateType, centralMeridian, standardParallel, falseEasting, falseNorthing);
                    
                    // Thiết lập chuyển đổi
                    CoordinateConversionService ccsMapProjectionToGeodeticMlsEgm(_targetCode, &targetParams, _srcCode, &sourceParams);
                    
                    ccsMapProjectionToGeodeticMlsEgm.convertSourceToTarget(&sourceCoordinates,
                                                                           &sourceAccuracy,
                                                                           targetCoordinates,
                                                                           targetAccuracy);
                    *lat = targetCoordinates.latitude();
                    *lng = targetCoordinates.longitude();
                    *alt = height;
                    return;
                }
                case CoordinateType::neys: {
                    
                    // Lấy tham số lưới chiếu đã lưu
                    getNeysParameters(&centralMeridian, &originLatitude, &standardParallel, &falseEasting, &falseNorthing);
                    
                    // Tạo tham số lưới chiếu đích
                    NeysParameters targetParams = NeysParameters(coordinateType, centralMeridian, originLatitude, standardParallel, falseEasting, falseNorthing);
                    
                    // Thiết lập chuyển đổi
                    CoordinateConversionService ccsMapProjectionToGeodeticMlsEgm(_targetCode, &targetParams, _srcCode, &sourceParams);
                    
                    ccsMapProjectionToGeodeticMlsEgm.convertSourceToTarget(&sourceCoordinates,
                                                                           &sourceAccuracy,
                                                                           targetCoordinates,
                                                                           targetAccuracy);
                    *lat = targetCoordinates.latitude();
                    *lng = targetCoordinates.longitude();
                    *alt = height;
                    return;
                }
                case CoordinateType::newZealandMapGrid: {
                    NSString *ellipsoidCode = getEllipsoidCode();
                    char* eCode = (char *)[ellipsoidCode cStringUsingEncoding:NSASCIIStringEncoding];
                    NZMG nzmg = NZMG(eCode);
                    GeodeticCoordinates *geodeticCoordinates = nzmg.convertToGeodetic(new MapProjectionCoordinates(CoordinateType::newZealandMapGrid, easting, northing));
                    _lat = geodeticCoordinates->latitude();
                    _lng = geodeticCoordinates->longitude();
                    _alt = height;//geodeticCoordinates->height();
                    
                    // Tính chuyển tọa độ sang hệ đích (tọa độ trắc địa)
                    CoordinateConversionService ccsGeodeticMlsEgmToGeodetic(_targetCode, &sourceParams, _srcCode, &sourceParams);
                    
                    GeodeticCoordinates targetCoordinates(CoordinateType::geodetic, _lng, _lat, _alt);
                    GeodeticCoordinates sourceCoordinates;
                    
                    ccsGeodeticMlsEgmToGeodetic.convertSourceToTarget(&sourceCoordinates, &sourceAccuracy,
                                                                      targetCoordinates, targetAccuracy);
                    *lat = targetCoordinates.latitude();
                    *lng = targetCoordinates.longitude();
                    *alt = height;
                    return;
                }
                case CoordinateType::obliqueMercator: {
                    
                    // Lấy tham số lưới chiếu đã lưu
                    getObliqueMercatorParameters(&originLatitude, &longitude1, &latitude1, &longitude2, &latitude2, &falseEasting, &falseNorthing, &scaleFactor);
                    
                    // Tạo tham số lưới chiếu đích
                    ObliqueMercatorParameters targetParams = ObliqueMercatorParameters(coordinateType, originLatitude, longitude1, latitude1, longitude2, latitude2, falseEasting, falseNorthing, scaleFactor);
                    
                    // Thiết lập chuyển đổi
                    CoordinateConversionService ccsMapProjectionToGeodeticMlsEgm(_targetCode, &targetParams, _srcCode, &sourceParams);
                    
                    ccsMapProjectionToGeodeticMlsEgm.convertSourceToTarget(&sourceCoordinates,
                                                                           &sourceAccuracy,
                                                                           targetCoordinates,
                                                                           targetAccuracy);
                    *lat = targetCoordinates.latitude();
                    *lng = targetCoordinates.longitude();
                    *alt = height;
                    return;
                }
                case CoordinateType::polarStereographicScaleFactor: {
                    
                    // Lấy tham số lưới chiếu đã lưu
                    getPolarStereographicScaleFactorParameters(&centralMeridian, &scaleFactor, &falseEasting, &falseNorthing);
                    
                    // Tạo tham số lưới chiếu đích
                    char hemisphere = 'N';
                    PolarStereographicScaleFactorParameters targetParams = PolarStereographicScaleFactorParameters(coordinateType, centralMeridian, scaleFactor, hemisphere, falseEasting, falseNorthing);
                    
                    // Thiết lập chuyển đổi
                    CoordinateConversionService ccsMapProjectionToGeodeticMlsEgm(_targetCode, &targetParams, _srcCode, &sourceParams);
                    
                    ccsMapProjectionToGeodeticMlsEgm.convertSourceToTarget(&sourceCoordinates,
                                                                           &sourceAccuracy,
                                                                           targetCoordinates,
                                                                           targetAccuracy);
                    *lat = targetCoordinates.latitude();
                    *lng = targetCoordinates.longitude();
                    *alt = height;
                    return;
                }
                case CoordinateType::polarStereographicStandardParallel: {
                    
                    // Lấy tham số lưới chiếu đã lưu
                    getPolarStereographicStandardParallelParameters(&centralMeridian, &standardParallel, &falseEasting, &falseNorthing);
                    
                    // Tạo tham số lưới chiếu đích
                    PolarStereographicStandardParallelParameters targetParams = PolarStereographicStandardParallelParameters(coordinateType, centralMeridian, standardParallel, falseEasting, falseNorthing);
                    
                    // Thiết lập chuyển đổi
                    CoordinateConversionService ccsMapProjectionToGeodeticMlsEgm(_targetCode, &targetParams, _srcCode, &sourceParams);
                    
                    ccsMapProjectionToGeodeticMlsEgm.convertSourceToTarget(&sourceCoordinates,
                                                                           &sourceAccuracy,
                                                                           targetCoordinates,
                                                                           targetAccuracy);
                    *lat = targetCoordinates.latitude();
                    *lng = targetCoordinates.longitude();
                    *alt = height;
                    return;
                }
                case CoordinateType::webMercator: {
                    NSString *ellipsoidCode = @"WE"; // Luôn luôn là WE
                    char* eCode = (char *)[ellipsoidCode cStringUsingEncoding:NSASCIIStringEncoding];
                    WebMercator webMercator = WebMercator(eCode);
                    GeodeticCoordinates *geodeticCoordinates = webMercator.convertToGeodetic(new MapProjectionCoordinates(CoordinateType::webMercator, easting, northing));
                    _lat = geodeticCoordinates->latitude();
                    _lng = geodeticCoordinates->longitude();
                    _alt = height;//geodeticCoordinates->height();
                    
                    // Tính chuyển tọa độ sang hệ đích (tọa độ trắc địa)
                    CoordinateConversionService ccsGeodeticMlsEgmToGeodetic(_targetCode, &sourceParams, _srcCode, &sourceParams);
                    
                    GeodeticCoordinates targetCoordinates(CoordinateType::geodetic, _lng, _lat, _alt);
                    GeodeticCoordinates sourceCoordinates;
                    
                    ccsGeodeticMlsEgmToGeodetic.convertSourceToTarget(&sourceCoordinates, &sourceAccuracy,
                                                                      targetCoordinates, targetAccuracy);
                    *lat = targetCoordinates.latitude();
                    *lng = targetCoordinates.longitude();
                    *alt = height;
                    return;
                }
                default:
                    break;
            }
        } catch(CoordinateConversionException& e) {
            // catch and report any exceptions thrown by the Coordinate
            // Conversion Service
            *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
            NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
        } catch(std::exception& e) {
            // catch and report any unexpected exceptions thrown
            *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
            NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
        }
        
    } catch(CoordinateConversionException& e) {
        // catch and report any exceptions thrown by the Coordinate
        // Conversion Service
        *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
        NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
    } catch(std::exception& e) {
        // catch and report any unexpected exceptions thrown
        *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
        NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
    }
}

- (void)getGeodeticForUPSCoordinates:(double *)lat lng:(double *)lng alt:(double *)alt warningMessage:(NSString **)warningMessage type:(long)type hemisphere:(NSString *)hemisphere easting:(double)easting northing:(double)northing height:(double)height hType:(long)hType {
    _srcCode = [_srcDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    _targetCode = [_targetDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    try {
        try {
            *warningMessage = @"";
            // 1. Tính chuyển từ tọa độ cục bộ sang tọa độ trắc địa trong cùng hệ
            // 2. Tính chuyển tọa độ trắc địa cục bộ sang tọa độ trắc địa WGS 84
            
            char hemi = [hemisphere characterAtIndex:0];
            CoordinateType::Enum coordinateType = (CoordinateType::Enum)type;
            UPSCoordinates *coordinates = new UPSCoordinates(coordinateType, hemi, easting, northing);
            
            double ellipsoidSemiMajorAxis;
            double ellipsoidFlattening;
            getEllipsoidParameters(&ellipsoidSemiMajorAxis, &ellipsoidFlattening);
            UPS ups = UPS(ellipsoidSemiMajorAxis, ellipsoidFlattening);
            
            GeodeticCoordinates *geodeticCoordinates = ups.convertToGeodetic(coordinates);
            
            double __lat = geodeticCoordinates->latitude();
            double __lng = geodeticCoordinates->longitude();
            double __alt = geodeticCoordinates->height();
            
            // ========= DATUM TRANSFORMATION ========
            // Tạo tham số nguồn là geodetic (tọa độ trắc địa)
            GeodeticParameters geodeticMlsEgmParams(CoordinateType::geodetic, HeightType::EGM96VariableNaturalSpline);
            
            // Thiết lập tính chuyển tọa độ sang hệ đích (tọa độ trắc địa)
            CoordinateConversionService ccsGeodeticMlsEgmToGeodetic(_srcCode, &geodeticMlsEgmParams, _targetCode, &geodeticMlsEgmParams);
            
            // Tính chuyển tọa độ trắc địa sang tọa độ trắc địa trên hệ cục bộ
            Accuracy sourceAccuracy;
            Accuracy targetAccuracy;
            
            GeodeticCoordinates sourceCoordinates(CoordinateType::geodetic, __lng, __lat, __alt);
            GeodeticCoordinates targetCoordinates;
            
            // Tính chuyển tọa độ trắc địa cục bộ sang tọa độ trắc địa toàn cầu có sử sụng datum
            ccsGeodeticMlsEgmToGeodetic.convertTargetToSource(&sourceCoordinates, &sourceAccuracy, targetCoordinates, targetAccuracy);
            
            *lat = targetCoordinates.latitude();
            *lng = targetCoordinates.longitude();
            *alt = targetCoordinates.height();
            
            // ========= END DATUM TRANSFORMATION ========
            
        } catch(CoordinateConversionException& e) {
            // catch and report any exceptions thrown by the Coordinate
            // Conversion Service
            *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
            NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
        } catch(std::exception& e) {
            // catch and report any unexpected exceptions thrown
            *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
            NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
        }
        
    } catch(CoordinateConversionException& e) {
        // catch and report any exceptions thrown by the Coordinate
        // Conversion Service
        *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
        NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
    } catch(std::exception& e) {
        // catch and report any unexpected exceptions thrown
        *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
        NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
    }
}

- (void)getGeodeticForUTMCoordinates:(double *)lat lng:(double *)lng alt:(double *)alt warningMessage:(NSString **)warningMessage type:(long)type zone:(long)zone hemisphere:(NSString *)hemisphere easting:(double)easting northing:(double)northing height:(double)height hType:(long)hType {
    _srcCode = [_srcDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    _targetCode = [_targetDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
    try {
        try {
            *warningMessage = @"";
            // 1. Tính chuyển từ tọa độ cục bộ sang tọa độ trắc địa trong cùng hệ
            // 2. Tính chuyển tọa độ trắc địa cục bộ sang tọa độ trắc địa WGS 84
            
            char hemi = [hemisphere characterAtIndex:0];
            CoordinateType::Enum coordinateType = (CoordinateType::Enum)type;
            UTMCoordinates *coordinates = new UTMCoordinates(coordinateType, zone, hemi, easting, northing);
            
            NSString *eCode = getEllipsoidCode();
            char *ellipsoidCode = (char*)[eCode cStringUsingEncoding:NSASCIIStringEncoding];
            double ellipsoidSemiMajorAxis;
            double ellipsoidFlattening;
            getEllipsoidParameters(&ellipsoidSemiMajorAxis, &ellipsoidFlattening);
            UTM utm = UTM(ellipsoidSemiMajorAxis, ellipsoidFlattening, ellipsoidCode);
            
            GeodeticCoordinates *geodeticCoordinates = utm.convertToGeodetic(coordinates);
            
            double __lat = geodeticCoordinates->latitude();
            double __lng = geodeticCoordinates->longitude();
            double __alt = geodeticCoordinates->height();
            
            // ========= DATUM TRANSFORMATION ========
            // Tạo tham số nguồn là geodetic (tọa độ trắc địa)
            GeodeticParameters geodeticMlsEgmParams(CoordinateType::geodetic, HeightType::EGM96VariableNaturalSpline);
            
            // Thiết lập tính chuyển tọa độ sang hệ đích (tọa độ trắc địa)
            CoordinateConversionService ccsGeodeticMlsEgmToGeodetic(_srcCode, &geodeticMlsEgmParams, _targetCode, &geodeticMlsEgmParams);
            
            // Tính chuyển tọa độ trắc địa sang tọa độ trắc địa trên hệ cục bộ
            Accuracy sourceAccuracy;
            Accuracy targetAccuracy;
            
            GeodeticCoordinates sourceCoordinates(CoordinateType::geodetic, __lng, __lat, __alt);
            GeodeticCoordinates targetCoordinates;
            
            // Tính chuyển tọa độ trắc địa cục bộ sang tọa độ trắc địa toàn cầu có sử sụng datum
            ccsGeodeticMlsEgmToGeodetic.convertTargetToSource(&sourceCoordinates, &sourceAccuracy, targetCoordinates, targetAccuracy);
            
            *lat = targetCoordinates.latitude();
            *lng = targetCoordinates.longitude();
            *alt = targetCoordinates.height();
            
            // ========= END DATUM TRANSFORMATION ========
            
        } catch(CoordinateConversionException& e) {
            // catch and report any exceptions thrown by the Coordinate
            // Conversion Service
            *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
            NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
        } catch(std::exception& e) {
            // catch and report any unexpected exceptions thrown
            *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
            NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
        }
        
    } catch(CoordinateConversionException& e) {
        // catch and report any exceptions thrown by the Coordinate
        // Conversion Service
        *warningMessage = [NSString stringWithFormat:@"%s" , e.getMessage()];
        NSLog(@"ERROR: Coordinate Conversion Service exception encountered - %s", e.getMessage());
    } catch(std::exception& e) {
        // catch and report any unexpected exceptions thrown
        *warningMessage = [NSString stringWithFormat:@"%s" , e.what()];
        NSLog(@"ERROR: Unexpected exception encountered - %s", e.what());
    }
}

@end
