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

#include "TransverseMercator.h"

using namespace MSP::CCS;
/*
 * Thiết lập theo lưới chiếu (tạm)
 */
NS_INLINE void setParameters(char* proj4) {
    // Chỗ này xử lý proj4, tách xâu, xác định type,
    MSP::CCS::CoordinateType::Enum type = MSP::CCS::CoordinateType::universalTransverseMercator;
    
    switch (type) {
            case MSP::CCS::CoordinateType::britishNationalGrid:
            case MSP::CCS::CoordinateType::militaryGridReferenceSystem:
            case MSP::CCS::CoordinateType::newZealandMapGrid:
            case MSP::CCS::CoordinateType::usNationalGrid:
            case MSP::CCS::CoordinateType::webMercator:
            //=>EllipsoidParameters
            break;
            
            case MSP::CCS::CoordinateType::equidistantCylindrical:
            //=>EquidistantCylindricalParameters
            break;
            
            case MSP::CCS::CoordinateType::localCartesian:
            //=>LocalCartesianParameters
            break;
            
            case MSP::CCS::CoordinateType::eckert4:
            case MSP::CCS::CoordinateType::eckert6:
            case MSP::CCS::CoordinateType::millerCylindrical:
            case MSP::CCS::CoordinateType::mollweide:
            case MSP::CCS::CoordinateType::sinusoidal:
            case MSP::CCS::CoordinateType::vanDerGrinten:
            //=>MapProjection3Parameters
            break;
            
            case MSP::CCS::CoordinateType::azimuthalEquidistant:
            case MSP::CCS::CoordinateType::bonne:
            case MSP::CCS::CoordinateType::cassini:
            case MSP::CCS::CoordinateType::cylindricalEqualArea:
            case MSP::CCS::CoordinateType::gnomonic:
            case MSP::CCS::CoordinateType::orthographic:
            case MSP::CCS::CoordinateType::polyconic:
            case MSP::CCS::CoordinateType::stereographic:
            //=>MapProjection4Parameters
            break;
            
            case MSP::CCS::CoordinateType::transverseCylindricalEqualArea:
            case MSP::CCS::CoordinateType::transverseMercator:
            case MSP::CCS::CoordinateType::lambertConformalConic1Parallel:
            //=>MapProjection5Parameters
            break;
            case MSP::CCS::CoordinateType::lambertConformalConic2Parallels:
            //=>MapProjection6Parameters
            break;
            
            case MSP::CCS::CoordinateType::albersEqualAreaConic:
            //=>MapProjection6Parameters
            break;
            
            case MSP::CCS::CoordinateType::mercatorStandardParallel:
            //=>MercatorStandardParallelParameters
            break;
            
            case MSP::CCS::CoordinateType::mercatorScaleFactor:
            //=>MercatorScaleFactorParameters
            break;
            
            case MSP::CCS::CoordinateType::neys:
            //=>NeysParameters
            break;
            
            case MSP::CCS::CoordinateType::obliqueMercator:
            //=>ObliqueMercatorParameters
            break;
            case MSP::CCS::CoordinateType::polarStereographicStandardParallel:
            //=>PolarStereographicStandardParallelParameters
            break;
            case MSP::CCS::CoordinateType::polarStereographicScaleFactor:
            //=>PolarStereographicScaleFactorParameters
            break;
            case MSP::CCS::CoordinateType::universalTransverseMercator:
            //=>UTMParameters
            break;
        default:
            break;
    }
}

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

void convertGeodeticMlsEgmToMapProjection(
                               CoordinateConversionService& ccsGeodeticMlsEgmToMapProjection,
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
    
    ccsGeodeticMlsEgmToMapProjection.convertSourceToTarget(
                                                           &sourceCoordinates,
                                                           &sourceAccuracy,
                                                           targetCoordinates,
                                                           targetAccuracy);
    
    easting = targetCoordinates.easting();
    northing = targetCoordinates.northing();
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
    
    CoordinateSystemParameters tmParameters;
    
    
    HeightType::Enum sourceHeightType;
    HeightType::Enum targetHeightType;
    CoordinateType::Enum sourceCoordinateType;
    CoordinateType::Enum targetCoordinateType;
    
    
    
}
@property (nonatomic) MSP::CCS::DatumLibrary *datumLibrary;

@end

@implementation GeoTrans
@synthesize srcCode = _srcCode;
@synthesize targetCode = _targetCode;
@synthesize datumLibrary = _datumLibrary;
@synthesize lat = _lat;
@synthesize lng = _lng;
@synthesize alt = _alt;

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
        
        //tmParameters = CoordinateSystemParameters(CoordinateType::transverseMercator);
        //MapProjection3Parameters( CoordinateType::Enum _coordinateType, double __centralMeridian, double __falseEasting, double __falseNorthing );
        //MapProjection4Parameters( CoordinateType::Enum _coordinateType, double __centralMeridian, double __originLatitude, double __falseEasting, double __falseNorthing );
        //MapProjection5Parameters::MapProjection5Parameters() :
//        CoordinateSystemParameters( CoordinateType::transverseMercator ),
//        _centralMeridian( 0 ),
//        _originLatitude( 0 ),
//        _scaleFactor( 1.0 ),
//        _falseEasting( 0 ),
//        _falseNorthing( 0 )
//        {
//        }
        //MapProjection6Parameters( CoordinateType::Enum _coordinateType, double __centralMeridian, double __originLatitude, double __standardParallel1, double __standardParallel2, double __falseEasting, double __falseNorthing );
        //

        
        //tmParameters = MapProjection5Parameters(CoordinateType::transverseMercator, 105.0*DEG2RAD, 0.0, 0.9999,500000.0,0.0);
        
        
        _srcCode = [@"WGE" cStringUsingEncoding:NSASCIIStringEncoding];
        _targetCode = [@"WGE" cStringUsingEncoding:NSASCIIStringEncoding];
        
        sourceHeightType = HeightType::noHeight;
        targetHeightType = HeightType::noHeight;
        
        sourceCoordinateType = CoordinateType::geodetic;
        targetCoordinateType = CoordinateType::usNationalGrid;
        
        // Khởi tạo datumLibrary để tạo datum từ proj4
        GeodeticParameters geodeticMlsEgmParams(CoordinateType::geodetic, HeightType::EGM2008TwoPtFiveMinBicubicSpline);
        UTMParameters utmParams = UTMParameters(CoordinateType::universalTransverseMercator, 1, 0);
        CoordinateConversionService ccs(_srcCode, &geodeticMlsEgmParams, _targetCode, &utmParams);
        _datumLibrary = ccs.getDatumLibrary();
    }
    return self;
}

- (instancetype)init:(NSString *)sourceDatumCode :(NSString *)targetDatumCode {
    if (self = [self init]) {
        _srcCode = [sourceDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
        _targetCode = [targetDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
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

- (void)setSourceDatumCode:(NSString *)sourceDatumCode {
    _srcCode = [sourceDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
}

- (void)setTargetDatumCode:(NSString *)targetDatumCode {
    _targetCode = [targetDatumCode cStringUsingEncoding:NSASCIIStringEncoding];
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

/*
 * Hàm lấy tham số lưới chiếu từ NSUserDefault được thiết lập từ GTField
 */
CoordinateSystemParameters getCoordinateSystemParametersForCoordinateType(CoordinateType::Enum type) {
    double ellipsoidSemiMajorAxis = 6378137.0;
    double ellipsoidFlattening = 1/298.257223563;
    double __centralMeridian;
    double __standardParallel;
    double __falseEasting;
    double __falseNorthing;
    double __longitude;
    double __latitude;
    double __height;
    double __orientation;
    double __originLatitude;
    double __scaleFactor;
    double __standardParallel1;
    double __standardParallel2;
    double __longitude1;
    double __latitude1;
    double __longitude2;
    double __latitude2;
    double __longitudeDownFromPole;
    char __hemisphere;
    double __latitudeOfTrueScale;
    long __zone;
    long __override;
    switch (type) {
            case MSP::CCS::CoordinateType::britishNationalGrid:
            case MSP::CCS::CoordinateType::militaryGridReferenceSystem:
            case MSP::CCS::CoordinateType::newZealandMapGrid:
            case MSP::CCS::CoordinateType::usNationalGrid:
            case MSP::CCS::CoordinateType::webMercator:
            //=>EllipsoidParameters
            return CoordinateSystemParameters(type);
            break;
            
            case MSP::CCS::CoordinateType::equidistantCylindrical:
            //=>EquidistantCylindricalParameters
            getEquidistantCylindricalParameters(&__centralMeridian, &__standardParallel, &__falseEasting, &__falseNorthing);
            return EquidistantCylindricalParameters(type, __centralMeridian, __standardParallel, __falseEasting, __falseNorthing);
            break;
            
            case MSP::CCS::CoordinateType::localCartesian:
            //=>LocalCartesianParameters
            getLocalCartesianParameters(&__longitude, &__latitude, &__height, &__orientation);
            return LocalCartesianParameters(type, __longitude, __latitude, __height, __orientation);
            break;
            
            case MSP::CCS::CoordinateType::eckert4:
            case MSP::CCS::CoordinateType::eckert6:
            case MSP::CCS::CoordinateType::millerCylindrical:
            case MSP::CCS::CoordinateType::mollweide:
            case MSP::CCS::CoordinateType::sinusoidal:
            case MSP::CCS::CoordinateType::vanDerGrinten:
            //=>MapProjection3Parameters
            getMapProjection3Parameters(&__centralMeridian, &__falseEasting, &__falseNorthing);
            return MapProjection3Parameters(type, __centralMeridian, __falseEasting, __falseNorthing);
            break;
            
            case MSP::CCS::CoordinateType::azimuthalEquidistant:
            case MSP::CCS::CoordinateType::bonne:
            case MSP::CCS::CoordinateType::cassini:
            case MSP::CCS::CoordinateType::cylindricalEqualArea:
            case MSP::CCS::CoordinateType::gnomonic:
            case MSP::CCS::CoordinateType::orthographic:
            case MSP::CCS::CoordinateType::polyconic:
            case MSP::CCS::CoordinateType::stereographic:
            //=>MapProjection4Parameters
            getMapProjection4Parameters(&__centralMeridian, &__originLatitude, &__falseEasting, &__falseNorthing);
            return MapProjection3Parameters(type, __centralMeridian, __falseEasting, __falseNorthing);
            break;
            
            case MSP::CCS::CoordinateType::transverseCylindricalEqualArea:
            case MSP::CCS::CoordinateType::transverseMercator:
            case MSP::CCS::CoordinateType::lambertConformalConic1Parallel: {
                //=>MapProjection5Parameters
                getMapProjection5Parameters(&__centralMeridian, &__originLatitude, &__scaleFactor, &__falseEasting, &__falseNorthing);
                getEllipsoidParameters(&ellipsoidSemiMajorAxis, &ellipsoidFlattening);
                
//                char *ellipsoidCode = "99";
//                TransverseMercator tm = TransverseMercator(ellipsoidSemiMajorAxis, ellipsoidFlattening, __centralMeridian, __originLatitude, __falseEasting, __falseNorthing, __scaleFactor, ellipsoidCode);
//                
//                return *tm.getParameters();
//                
                return MapProjection5Parameters(type, 105.0*DEG2RAD, 0.0, 0.9999, 500000.0, 0.0);
                //return MapProjection5Parameters(type, __centralMeridian, __originLatitude, __scaleFactor, __falseEasting, __falseNorthing);
            }
            break;
            case MSP::CCS::CoordinateType::lambertConformalConic2Parallels:
            case MSP::CCS::CoordinateType::albersEqualAreaConic:
            //=>MapProjection6Parameters
            getMapProjection6Parameters(&__centralMeridian, &__originLatitude, &__standardParallel1, &__standardParallel2, &__falseEasting, &__falseNorthing);
            return MapProjection6Parameters(type, __centralMeridian, __originLatitude, __standardParallel1, __standardParallel2, __falseEasting, __falseNorthing);
            break;
            
            case MSP::CCS::CoordinateType::mercatorStandardParallel:
            //=>MercatorStandardParallelParameters
            getMercatorStandardParallelParameters(&__centralMeridian, &__standardParallel, &__scaleFactor, &__falseEasting, &__falseNorthing);
            return MercatorStandardParallelParameters(type, __centralMeridian, __standardParallel, __scaleFactor,  __falseEasting, __falseNorthing);
            break;
            
            case MSP::CCS::CoordinateType::mercatorScaleFactor:
            //=>MercatorScaleFactorParameters
            getMercatorScaleFactorParameters(&__centralMeridian, &__scaleFactor, &__falseEasting, &__falseNorthing);
            return MercatorScaleFactorParameters(type, __centralMeridian, __scaleFactor, __falseEasting, __falseNorthing);
            break;
            
            case MSP::CCS::CoordinateType::neys:
            //=>NeysParameters
            getNeysParameters(&__centralMeridian, &__originLatitude, &__standardParallel1, &__falseEasting, &__falseNorthing);
            return NeysParameters(type, __centralMeridian, __originLatitude, __standardParallel1, __falseEasting, __falseNorthing);
            break;
            
            case MSP::CCS::CoordinateType::obliqueMercator:
            //=>ObliqueMercatorParameters
            getObliqueMercatorParameters(&__originLatitude, &__longitude1, &__latitude1, &__longitude2, &__latitude2, &__falseEasting, &__falseNorthing, &__scaleFactor);
            return ObliqueMercatorParameters(type, __originLatitude, __longitude1, __latitude1, __longitude2, __latitude2, __falseEasting, __falseNorthing, __scaleFactor);
            break;
            case MSP::CCS::CoordinateType::polarStereographicStandardParallel:
            //=>PolarStereographicStandardParallelParameters
            getPolarStereographicStandardParallelParameters(&__longitudeDownFromPole, &__latitudeOfTrueScale, &__falseEasting, &__falseNorthing);
            return PolarStereographicStandardParallelParameters(type, __longitudeDownFromPole, __latitudeOfTrueScale, __falseEasting, __falseNorthing);
            break;
            case MSP::CCS::CoordinateType::polarStereographicScaleFactor:
            //=>PolarStereographicScaleFactorParameters
            getPolarStereographicScaleFactorParameters(&__longitudeDownFromPole, &__scaleFactor, &__hemisphere, &__falseEasting, &__falseNorthing);
            return PolarStereographicScaleFactorParameters(type, __longitudeDownFromPole, __scaleFactor, __hemisphere, __falseEasting, __falseNorthing);
            break;
            case MSP::CCS::CoordinateType::universalTransverseMercator:
            //=>UTMParameters
            getUTMParameters(&__zone, &__override);
            return UTMParameters(type, __zone, __override);
            break;
        default:
            break;
    }
    return UTMParameters(CoordinateType::universalTransverseMercator, 1, 0);
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

- (int)getTM:(double *)easting :(double *)northing {
    int status = 1;
    try {
        try {
            GeodeticParameters geodeticMlsEgmParams(CoordinateType::geodetic, HeightType::EGM2008TwoPtFiveMinBicubicSpline);
// Có thể tạo parameters theo cách này:
// MapProjection5Parameters tmParams = MapProjection5Parameters(CoordinateType::transverseMercator,105.0*DEG2RAD, 0.0, 0.9999,500000.0,0.0);

// Cũng có thể tạp parameters từ Projection class (có thể thêm ellipsoid):
// char* eCode = "WO";
// TransverseMercator tm = TransverseMercator(6378137.0, 1/298.257223563, 105.0*DEG2RAD, 0.0, 500000.0, 0.0, 0.9999, eCode);
// MapProjection5Parameters *tmParams = tm.getParameters();

            char* eCode = "WO";
            TransverseMercator tm = TransverseMercator(6378137.0, 1/298.257223563, 105.0*DEG2RAD, 0.0, 500000.0, 0.0, 0.9999, eCode);
            
            MapProjection5Parameters *tmParams = tm.getParameters();
            // Tao datum
//            -191.90441429, -39.30318279, -111.45032835,0,0,0,108 -0.00928836, 0.01975479, -0.00427372, 0.25290628,
//            EllipsoidLibrary::defineEllipsoid(<#const char *code#>, <#const char *name#>, <#double semiMajorAxis#>, <#double flattening#>)
//            datumLibrary->defineDatum(DatumType::Enum::sevenParamDatum, "VN", "Vietnam", "WE", -191.90441429, -39.30318279, -111.45032835,0,0,0, 103.0*DEG2RAD, 114.0*DEG2RAD, 8.0*DEG2RAD, 24.0*DEG2RAD, -0.00928836, 0.01975479, -0.00427372, 0.25290628/1000000.0e0);
            
            const char* wgeCode = "WGE";
            const char* weCode = "WE";
            const char* dCode = "VN2";
            GeodeticParameters geodeticParams(CoordinateType::geodetic);
            CoordinateConversionService ccs(wgeCode, &geodeticParams, wgeCode, &geodeticParams);
            _datumLibrary = ccs.getDatumLibrary();
            long count;
            _datumLibrary->getDatumCount(&count);
            NSLog(@"%ld", count);
            CoordinateTuple ct;
            
//            _datumLibrary->defineDatum(DatumType::Enum::sevenParamDatum, dCode, "Vietnam", weCode, -191.90441429, -39.30318279, -111.45032835,0,0,0, 103.0*DEG2RAD, 114.0*DEG2RAD, 8.0*DEG2RAD, 24.0*DEG2RAD, -0.00928836, 0.01975479, -0.00427372, 0.25290628/1000000.0e0);
            
            CoordinateConversionService ccsGeodeticMlsEgmToTm(_srcCode, &geodeticMlsEgmParams, _targetCode, tmParams);

            
            
            convertGeodeticMlsEgmToTm(ccsGeodeticMlsEgmToTm,
                                      _lat, _lng, _alt,
                                      *easting, *northing);
            
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

- (int)getTMForLat:(double)lat lng:(double)lng easting:(double *)easting northing:(double *)northing {
    int status = 1;
    _lat = lat;
    _lng = lng;
    try {
        try {
            // Kiểm tra xem lưới chiếu hiện tại là gì
            long coordinateType = 0; //UTM
            getCoordinateType(&coordinateType);
            CoordinateType::Enum type = (CoordinateType::Enum)coordinateType;
            CoordinateSystemParameters targetParams = getCoordinateSystemParametersForCoordinateType(type);
            
            GeodeticParameters geodeticMlsEgmParams(CoordinateType::geodetic, HeightType::EGM2008TwoPtFiveMinBicubicSpline);
            
            // Chỉ cần đặt mặc định source là WGE và target là VN-2, chương trình sẽ định hướng đến hệ tọa độ đích
            // sau đó, đoạn fix chuyentt sẽ đọc tham số elliosoid và datum từ NSUserDefault chứ không đọc từ file
            CoordinateConversionService ccsGeodeticMlsEgmToTm("WGE", &geodeticMlsEgmParams, "VN-2", &targetParams);
            
            convertGeodeticMlsEgmToTm(ccsGeodeticMlsEgmToTm,
                                      _lat, _lng, _alt,
                                      *easting, *northing);
            
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


/*
 * Chuẩn hóa
 */
- (void)getBNGCoordinatesForLat:(double)lat lng:(double)lng alt:(double)alt type:(long)type warningMessage:(NSString **)warningMessage BNGString:(NSString **)BNGString precision:(long *)precision {
    
}

- (void)getCartesianCoordinatesForLat:(double)lat lng:(double)lng alt:(double)alt type:(long)type warningMessage:(NSString **)warningMessage x:(double *)x y:(double *)y z:(double *)z {
    
}

- (void)getGARSCoordinatesForLat:(double)lat lng:(double)lng alt:(double)alt type:(long)type warningMessage:(NSString **)warningMessage GARSString:(NSString **)GARSString precision:(long *)precision {
    
}

- (void)getGEOREFCoordinatesForLat:(double)lat lng:(double)lng alt:(double)alt type:(long)type warningMessage:(NSString **)warningMessage GEOREFString:(NSString **)GEOREFString precision:(long *)precision {
    
}

- (void)getMapProjectionCoordinatesForLat:(double)lat lng:(double)lng alt:(double)alt type:(long)type warningMessage:(NSString **)warningMessage easting:(double *)easting northing:(double *)northing {
    _lat = lat; _lng = lng; _alt = alt;
    try {
        try {
            // Kiểm tra xem lưới chiếu hiện tại là gì
            long coordinateType = 0; //UTM
            getCoordinateType(&coordinateType);
            CoordinateType::Enum type = (CoordinateType::Enum)coordinateType;
            
            double centralMeridian = 0.0;
            double originLatitude = 0.0;
            double scaleFactor = 1.0;
            double falseEasting = 0.0;
            double falseNorthing = 0.0;
            
            // Lấy thông số lưới chiếu đã lưu
            getMapProjection5Parameters(&centralMeridian, &originLatitude, &scaleFactor, &falseEasting, &falseNorthing);
            
            // Tạo tham số lưới chiếu đích
            MapProjection5Parameters targetParams = MapProjection5Parameters(type, centralMeridian, originLatitude, scaleFactor, falseEasting, falseNorthing);
            
            // Tạo tham số nguồn
            GeodeticParameters geodeticMlsEgmParams(CoordinateType::geodetic, HeightType::EGM2008TwoPtFiveMinBicubicSpline);
            
            // Chỉ cần đặt mặc định source là WGE và target là VN-2, chương trình sẽ định hướng đến hệ tọa độ đích
            // sau đó, đoạn fix chuyentt sẽ đọc tham số elliosoid và datum từ NSUserDefault chứ không đọc từ file
            CoordinateConversionService ccsGeodeticMlsEgmToMapProjection("WGE", &geodeticMlsEgmParams, "VN-2", &targetParams);
            
            convertGeodeticMlsEgmToMapProjection(ccsGeodeticMlsEgmToMapProjection,
                                                 _lat, _lng, _alt,
                                                 *easting, *northing);
            
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

- (void)getMGRSorUSNGCoordinatesForLat:(double)lat lng:(double)lng alt:(double)alt type:(long)type warningMessage:(NSString **)warningMessage MGRS:(NSString **)MGRS precision:(long *)precision {
    
}

- (void)getUPSCoordinatesForLat:(double)lat lng:(double)lng alt:(double)alt type:(long)type warningMessage:(NSString **)warningMessage hemisphere:(NSString **)hemisphere easting:(double *)easting northing:(double *)northing {
    
}

- (void)getUTMCoordinatesForLat:(double)lat lng:(double)lng alt:(double)alt type:(long)type warningMessage:(NSString **)warningMessage zone:(long *)zone hemisphere:(NSString **)hemisphere easting:(double *)easting northing:(double *)northing {
    
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
            CoordinateConversionService ccsGeodeticEllipsoidToGeocentric(_srcCode, &ellipsoidParams, _targetCode, &geocentricParams);
            convertGeodeticEllipsoidToGeocentric(ccsGeodeticEllipsoidToGeocentric,
                                                 _lat, _lng, _alt,
                                                 x, y, z);
            
            UTMParameters utmParams = UTMParameters(CoordinateType::universalTransverseMercator, 1, 0);
            CoordinateConversionService ccsGeodeticToUtm(_srcCode, &geocentricParams, _targetCode, &utmParams);
            
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
        CoordinateConversionService ccsGeodeticEllipsoidToGeocentric(_srcCode, &ellipsoidParams, _targetCode, &geocentricParams);
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
        CoordinateConversionService ccsGeocentricToUtm(_srcCode, &geocentricParameters, _targetCode, &utmParameters);
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
        CoordinateConversionService ccsGeocentricToMgrs(_srcCode, &geocentricParameters, _targetCode, &mgrsParameters);
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
    CoordinateConversionService ccsGeodeticEllipsoidToGeocentric(_srcCode, &ellipsoidParameters, _targetCode, &geocentricParameters);
    
    CoordinateConversionService ccsGeocentricToGeodeticMslEgm96(_srcCode, &geocentricParameters, _targetCode, &mslEgm96FifteenMinBilinearParameters);
    
    CoordinateConversionService ccsMslEgm96ToEllipsoidHeight(_srcCode, &mslEgm96FifteenMinBilinearParameters, _targetCode, &ellipsoidParameters);
    
    CoordinateConversionService ccsEllipsoidHeightToMslEgm96(_srcCode, &ellipsoidParameters, _targetCode, &mslEgm96FifteenMinBilinearParameters);
    
    CoordinateConversionService ccsGeocentricToGeodeticMslEgm2008(_srcCode, &geocentricParameters, _targetCode, &mslEgm2008TwoPtFiveMinBicubicSplineParameters);
    
    CoordinateConversionService ccsMslEgm2008ToEllipsoidHeight(_srcCode, &mslEgm2008TwoPtFiveMinBicubicSplineParameters, _targetCode, &ellipsoidParameters);
    
    CoordinateConversionService ccsEllipsoidHeightToMslEgm2008(_srcCode, &ellipsoidParameters, _targetCode, &mslEgm2008TwoPtFiveMinBicubicSplineParameters);
    
    CoordinateConversionService ccsGeocentricToUtm(_srcCode, &geocentricParameters, _targetCode, &utmParameters);
    
    CoordinateConversionService ccsGeocentricToMgrs(_srcCode, &geocentricParameters, _targetCode, &mgrsParameters);

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
