//
//  CCSWrapper.m
//  Pods
//
//  Created by Chuyen Trung Tran on 2/20/17.
//
//

#include <iostream>
#include <string>

#import "CCSWrapper.h"
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
                                          MSP::CCS::CoordinateConversionService& ccsGeodeticEllipsoidToGeocentric,
                                          double lat,
                                          double lon,
                                          double height,
                                          double& x,
                                          double& y,
                                          double& z)
{
    MSP::CCS::Accuracy sourceAccuracy;
    MSP::CCS::Accuracy targetAccuracy;
    MSP::CCS::GeodeticCoordinates sourceCoordinates(
                                                    MSP::CCS::CoordinateType::geodetic, lon, lat, height);
    MSP::CCS::CartesianCoordinates targetCoordinates(
                                                     MSP::CCS::CoordinateType::geocentric);
    
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
                                          MSP::CCS::CoordinateConversionService& ccsGeodeticEllipsoidToGeocentric,
                                          double x,
                                          double y,
                                          double z,
                                          double& lat,
                                          double& lon,
                                          double& height)
{
    MSP::CCS::Accuracy geocentricAccuracy;
    MSP::CCS::Accuracy geodeticAccuracy;
    MSP::CCS::CartesianCoordinates geocentricCoordinates(
                                                         MSP::CCS::CoordinateType::geocentric, x, y, z);
    MSP::CCS::GeodeticCoordinates geodeticCoordinates;
    
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
                                         MSP::CCS::CoordinateConversionService& ccsGeocentricToGeodeticMslEgm96,
                                         double x,
                                         double y,
                                         double z,
                                         double& lat,
                                         double& lon,
                                         double& height)
{
    MSP::CCS::Accuracy sourceAccuracy;
    MSP::CCS::Accuracy targetAccuracy;
    MSP::CCS::CartesianCoordinates sourceCoordinates(
                                                     MSP::CCS::CoordinateType::geocentric, x, y, z);
    MSP::CCS::GeodeticCoordinates targetCoordinates(
                                                    MSP::CCS::CoordinateType::geodetic, lon, lat, height);
    
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
                                         MSP::CCS::CoordinateConversionService& ccsGeocentricToGeodeticMslEgm,
                                         double x,
                                         double y,
                                         double z,
                                         double& lat,
                                         double& lon,
                                         double& height)
{
    MSP::CCS::Accuracy sourceAccuracy;
    MSP::CCS::Accuracy targetAccuracy;
    MSP::CCS::CartesianCoordinates sourceCoordinates(
                                                     MSP::CCS::CoordinateType::geocentric, x, y, z);
    MSP::CCS::GeodeticCoordinates targetCoordinates(
                                                    MSP::CCS::CoordinateType::geodetic, lon, lat, height);
    
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
                                      MSP::CCS::CoordinateConversionService& ccsMslEgm96ToEllipsoidHeight,
                                      double lat,
                                      double lon,
                                      double mslHeight,
                                      double& ellipsoidHeight)
{
    MSP::CCS::Accuracy sourceAccuracy;
    MSP::CCS::Accuracy targetAccuracy;
    MSP::CCS::GeodeticCoordinates sourceCoordinates(
                                                    MSP::CCS::CoordinateType::geodetic, lon, lat, mslHeight);
    MSP::CCS::GeodeticCoordinates targetCoordinates;
    
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
                                      MSP::CCS::CoordinateConversionService& ccsMslEgmToEllipsoidHeight,
                                      double lat,
                                      double lon,
                                      double mslHeight,
                                      double& ellipsoidHeight)
{
    MSP::CCS::Accuracy sourceAccuracy;
    MSP::CCS::Accuracy targetAccuracy;
    MSP::CCS::GeodeticCoordinates sourceCoordinates(
                                                    MSP::CCS::CoordinateType::geodetic, lon, lat, mslHeight);
    MSP::CCS::GeodeticCoordinates targetCoordinates;
    
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
                                    MSP::CCS::CoordinateConversionService& ccsEllipsoidHeightToMslEgm,
                                    double lat,
                                    double lon,
                                    double ellipsoidHeight,
                                    double& mslHeight)
{
    MSP::CCS::Accuracy sourceAccuracy;
    MSP::CCS::Accuracy targetAccuracy;
    
    MSP::CCS::GeodeticCoordinates sourceCoordinates(
                                                    MSP::CCS::CoordinateType::geodetic, lon, lat, ellipsoidHeight);
    MSP::CCS::GeodeticCoordinates targetCoordinates;
    
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
                                      MSP::CCS::CoordinateConversionService& ccsEllipsoidHeightToMslEgm96,
                                      double lat,
                                      double lon,
                                      double ellipsoidHeight,
                                      double& mslHeight)
{
    MSP::CCS::Accuracy sourceAccuracy;
    MSP::CCS::Accuracy targetAccuracy;
    
    MSP::CCS::GeodeticCoordinates sourceCoordinates(
                                                    MSP::CCS::CoordinateType::geodetic, lon, lat, ellipsoidHeight);
    MSP::CCS::GeodeticCoordinates targetCoordinates;
    
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
                            MSP::CCS::CoordinateConversionService& ccsGeocentricToUtm,
                            double x,
                            double y,
                            double z, 
                            long& zone,
                            char& hemisphere, 
                            double& easting,
                            double& northing)
{
    MSP::CCS::Accuracy sourceAccuracy;
    MSP::CCS::Accuracy targetAccuracy;
    MSP::CCS::CartesianCoordinates sourceCoordinates(
                                                     MSP::CCS::CoordinateType::geocentric, x, y, z);
    MSP::CCS::UTMCoordinates targetCoordinates;
    
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
                                    MSP::CCS::CoordinateConversionService& ccsGeocentricToMgrs,
                                    double x,
                                    double y,
                                    double z, 
                                    MSP::CCS::Precision::Enum& precision)
{
    char* p;
    std::string mgrsString;
    
    MSP::CCS::Accuracy sourceAccuracy;
    MSP::CCS::Accuracy targetAccuracy;
    MSP::CCS::CartesianCoordinates sourceCoordinates(
                                                     MSP::CCS::CoordinateType::geocentric, x, y, z);
    MSP::CCS::MGRSorUSNGCoordinates targetCoordinates;
    
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


@interface CCSWrapper() {
    
}

//@property TestCppClass *cppItem;

@end


@implementation CCSWrapper

- (instancetype)initWithTitle:(NSString*)title
{
    if (self = [super init]) {
//        self.cppItem = new TestCppClass(std::string([title cStringUsingEncoding:NSUTF8StringEncoding]));
    }
    return self;
}
- (void)sayHello {
    NSLog(@"Hello");
}

- (int)testCoordinateConversion {
    //const char* VN2 = "VN-2";
    const char* WGE = "WGE";
    
    // initialize status value to one, indicating an error condition
    int status = 1;
    
    //
    // Coordinate System Parameters
    //
    MSP::CCS::GeodeticParameters ellipsoidParameters(
                                                     MSP::CCS::CoordinateType::geodetic,
                                                     MSP::CCS::HeightType::ellipsoidHeight);
    
    MSP::CCS::CoordinateSystemParameters geocentricParameters(
                                                              MSP::CCS::CoordinateType::geocentric);
    
    MSP::CCS::GeodeticParameters mslEgm84TenDegBilinearParameters(
                                                                  MSP::CCS::CoordinateType::geodetic,
                                                                  MSP::CCS::HeightType::EGM84TenDegBilinear);
    
    MSP::CCS::GeodeticParameters mslEgm84ThirtyMinBiLinearParameters(
                                                                  MSP::CCS::CoordinateType::geodetic,
                                                                  MSP::CCS::HeightType::EGM84ThirtyMinBiLinear);

    MSP::CCS::GeodeticParameters mslEgm84TenDegNaturalSplineParameters(
                                                                     MSP::CCS::CoordinateType::geodetic,
                                                                     MSP::CCS::HeightType::EGM84TenDegNaturalSpline);

    MSP::CCS::GeodeticParameters mslEgm96FifteenMinBilinearParameters(
                                                    MSP::CCS::CoordinateType::geodetic,
                                                    MSP::CCS::HeightType::EGM96FifteenMinBilinear);
    
    MSP::CCS::GeodeticParameters mslEgm96VariableNaturalSplineParameters(
                                                    MSP::CCS::CoordinateType::geodetic,
                                                    MSP::CCS::HeightType::EGM96VariableNaturalSpline);

    MSP::CCS::GeodeticParameters mslEgm2008TwoPtFiveMinBicubicSplineParameters(
                                                                         MSP::CCS::CoordinateType::geodetic,
                                                                         MSP::CCS::HeightType::EGM2008TwoPtFiveMinBicubicSpline);

    
    MSP::CCS::UTMParameters utmParameters(
                                          MSP::CCS::CoordinateType::universalTransverseMercator,
                                          1,
                                          0);
    
    MSP::CCS::CoordinateSystemParameters mgrsParameters(
                                                        MSP::CCS::CoordinateType::militaryGridReferenceSystem);

    //
    // Coordinate Conversion Services
    //
    MSP::CCS::CoordinateConversionService ccsGeodeticEllipsoidToGeocentric(
                                                                           WGE, &ellipsoidParameters,
                                                                           WGE, &geocentricParameters);

    MSP::CCS::CoordinateConversionService ccsGeocentricToGeodeticMslEgm96(
                                                                          WGE, &geocentricParameters,
                                                                          WGE, &mslEgm96FifteenMinBilinearParameters);
    
    MSP::CCS::CoordinateConversionService ccsMslEgm96ToEllipsoidHeight(
                                                                       WGE, &mslEgm96FifteenMinBilinearParameters,
                                                                       WGE, &ellipsoidParameters);
    MSP::CCS::CoordinateConversionService ccsEllipsoidHeightToMslEgm96(
                                                                       WGE, &ellipsoidParameters,
                                                                       WGE, &mslEgm96FifteenMinBilinearParameters);

    MSP::CCS::CoordinateConversionService ccsGeocentricToGeodeticMslEgm2008(
                                                                          WGE, &geocentricParameters,
                                                                          WGE, &mslEgm2008TwoPtFiveMinBicubicSplineParameters);
    
    MSP::CCS::CoordinateConversionService ccsMslEgm2008ToEllipsoidHeight(
                                                                       WGE, &mslEgm2008TwoPtFiveMinBicubicSplineParameters,
                                                                       WGE, &ellipsoidParameters);
    MSP::CCS::CoordinateConversionService ccsEllipsoidHeightToMslEgm2008(
                                                                       WGE, &ellipsoidParameters,
                                                                       WGE, &mslEgm2008TwoPtFiveMinBicubicSplineParameters);
    
    MSP::CCS::CoordinateConversionService ccsGeocentricToUtm(
                                                             WGE, &geocentricParameters,
                                                             WGE, &utmParameters);
    MSP::CCS::CoordinateConversionService ccsGeocentricToMgrs(
                                                              WGE, &geocentricParameters,
                                                              WGE, &mgrsParameters);

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
        MSP::CCS::Precision::Enum precision;
        
        mgrsString = convertGeocentricToMgrs(
                                             ccsGeocentricToMgrs, 
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
        
    } catch(MSP::CCS::CoordinateConversionException& e) {
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
