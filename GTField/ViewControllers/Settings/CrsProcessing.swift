//
//  CrsProcessing.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 9/7/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import Foundation
import GeoTrans

func datumProcessing(_ keyValue: [String]) {
    let dCode: String = keyValue[1]
    //var index = 9999
    var datumParameters = DatumParameters(code: "WGE", name: "WGS 84", deltaX: 0, deltaY: 0, deltaZ: 0, rotationX: 0, rotationY: 0, rotationZ: 0, scaleFactor: 0)
    var datum: ListItem = datumItems[0];
    if let index = datumItems.index(where: { (_item) -> Bool in
        (_item.code == dCode)
    }) {
        datum = datumItems[index]
    } else {
        datum = ListItem(code: "WGE", name: "WGS 84", value: "+ellps_code=WE +towgs84=0,0,0,0,0,0,0")
    }
    
    let arr = datum.value.components(separatedBy: " +")
    for item in arr {
        let keyValue = item.components(separatedBy: "=")
        if keyValue[0] == "towgs84" {
            datumParameters = getDatumParameters(datum.code, datum.name, keyValue)
        }
    }
    
    setDatumCode(datumParameters.code)
    setDatumName(datumParameters.name)
    geotrans?.targetDatumCode = datumParameters.code
    setSevenParamDatum(datumParameters.deltaX,
                       datumParameters.deltaY,
                       datumParameters.deltaZ,
                       datumParameters.rotationX,
                       datumParameters.rotationY,
                       datumParameters.rotationZ,
                       datumParameters.scaleFactor)
}

private func getDatumParameters(_ code: String, _ name: String, _ keyValue: [String]) -> DatumParameters {
    var deltaX: Double = 0
    var deltaY: Double = 0
    var deltaZ: Double = 0
    var rotationX: Double = 0
    var rotationY: Double = 0
    var rotationZ: Double = 0
    var sf: Double = 0
    
    let keyValue = keyValue[1].components(separatedBy: ",")
    if keyValue.count == 7 {
        deltaX = Double(keyValue[0])!
        deltaY = Double(keyValue[1])!
        deltaZ = Double(keyValue[2])!
        rotationX = Double(keyValue[3])!
        rotationY = Double(keyValue[4])!
        rotationZ = Double(keyValue[5])!
        sf = Double(keyValue[6])!
    }
    return DatumParameters(code: code,
                           name: name,
                           deltaX: deltaX,
                           deltaY: deltaY,
                           deltaZ: deltaZ,
                           rotationX: rotationX,
                           rotationY: rotationY,
                           rotationZ: rotationZ,
                           scaleFactor: sf)
}


func toWGS84Processing(_ keyValue: [String]) {
    let datumParameters = getDatumParameters("9999", "7 Parameteres to WGS84", keyValue)
    setDatumCode(datumParameters.code)
    setDatumName(datumParameters.name)
    geotrans?.targetDatumCode = datumParameters.code
    setSevenParamDatum(datumParameters.deltaX,
                       datumParameters.deltaY,
                       datumParameters.deltaZ,
                       datumParameters.rotationX,
                       datumParameters.rotationY,
                       datumParameters.rotationZ,
                       datumParameters.scaleFactor)
}

/*
 * Xử lý chuỗi proj4
 * type: UInt, _ arr: [String], _ select: Bool
 *
 */
func crsProcessing(_ crsName: String, _ proj4String: String) {
    var type = 0
    var ellps_code = "WE"
    // Đặt mặc định WGS84
    toWGS84Processing(["towgs84","0,0,0,0,0,0,0"])
    datumProcessing(["datum","WGE"]);
    
    let arr = proj4String.components(separatedBy: " +")
    // Lấy 2 xâu đầu tách ra để lấy index của lưới chiếu và ellipsoid code
    var keyValue = arr[0].components(separatedBy: "=")
    print(arr)
    if keyValue[0] == "+proj_code" {
        type = Int(keyValue[1])!
        if type > 37 {
            type = 0
        }
    }
    keyValue = arr[1].components(separatedBy: "=")
    if keyValue[0] == "ellps_code" {
        ellps_code = keyValue[1].trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    setCoordinateType(type)
    setMapProjectionCode(projectionItems[type].code)
    setMapProjectionName(projectionItems[type].name)
    setEllipsoidCode(ellps_code)
    
    let coordinateType: CoordinateType = CoordinateType(rawValue: Int(type))!
    switch (coordinateType) {
    case CoordinateType.britishNationalGrid:
        // Không có lưới chiếu này trong proj4
        for item in arr {
            let keyValue = item.components(separatedBy: "=")
            if keyValue[0] == "datum" {
                datumProcessing(keyValue)
            } else if keyValue[0] == "towgs84" {
                toWGS84Processing(keyValue)
            }
        }
        break
        
    case CoordinateType.militaryGridReferenceSystem:
        // Không có lưới chiếu này trong proj4
        for item in arr {
            let keyValue = item.components(separatedBy: "=")
            if keyValue[0] == "datum" {
                datumProcessing(keyValue)
            } else if keyValue[0] == "towgs84" {
                toWGS84Processing(keyValue)
            }
        }
        break
        
    case CoordinateType.localCartesian:
        // Không có lưới chiếu này trong proj4
        var originLongitude:Double = 0
        var originLatitude:Double = 0
        var originHeight:Double = 0
        var orientation:Double = 0
        for item in arr {
            let keyValue = item.components(separatedBy: "=")
            if keyValue[0] == "lon_0" {
                originLongitude = Double(keyValue[1])!
            } else if keyValue[0] == "lat_0" {
                originLatitude = Double(keyValue[1])!
            } else if keyValue[0] == "h_0" {
                originHeight = Double(keyValue[1])!
            } else if keyValue[0] == "o_0" {
                orientation = Double(keyValue[1])!
            } else if keyValue[0] == "datum" {
                datumProcessing(keyValue)
            } else if keyValue[0] == "towgs84" {
                toWGS84Processing(keyValue)
            }
        }
        setLocalCartesianParameters(originLongitude*DEG2RAD, originLatitude*DEG2RAD, originHeight, orientation*DEG2RAD)
        break
        
    case CoordinateType.globalAreaReferenceSystem:
        // Không có lưới chiếu này trong proj4
        for item in arr {
            let keyValue = item.components(separatedBy: "=")
            if keyValue[0] == "datum" {
                datumProcessing(keyValue)
            } else if keyValue[0] == "towgs84" {
                toWGS84Processing(keyValue)
            }
        }
        break
        
    case CoordinateType.georef:
        // Không có lưới chiếu này trong proj4
        for item in arr {
            let keyValue = item.components(separatedBy: "=")
            if keyValue[0] == "datum" {
                datumProcessing(keyValue)
            } else if keyValue[0] == "towgs84" {
                toWGS84Processing(keyValue)
            }
        }
        break
        
    case CoordinateType.universalPolarStereographic:
        // Không có lưới chiếu này trong proj4
        for item in arr {
            let keyValue = item.components(separatedBy: "=")
            if keyValue[0] == "datum" {
                datumProcessing(keyValue)
            } else if keyValue[0] == "towgs84" {
                toWGS84Processing(keyValue)
            }
        }
        break
        
    case CoordinateType.universalTransverseMercator:
        for item in arr {
            let keyValue = item.components(separatedBy: "=")
            if keyValue[0] == "datum" {
                datumProcessing(keyValue)
            } else if keyValue[0] == "towgs84" {
                toWGS84Processing(keyValue)
            }
        }
        
        break
        
    // =>MapProjection3Parameters
    case CoordinateType.eckert4,
         CoordinateType.eckert6,
         CoordinateType.millerCylindrical,
         CoordinateType.mollweide,
         CoordinateType.sinusoidal,
         CoordinateType.vanDerGrinten:
        
        var centralMeridian: Double = 0
        var falseEasting: Double = 0
        var falseNorthing: Double = 0
        
        for item in arr {
            let keyValue = item.components(separatedBy: "=")
            if keyValue[0] == "lon_0" {
                centralMeridian = Double(keyValue[1])!
            } else if keyValue[0] == "x_0" {
                falseEasting = Double(keyValue[1])!
            } else if keyValue[0] == "y_0" {
                falseNorthing = Double(keyValue[1])!
            } else if keyValue[0] == "datum" {
                datumProcessing(keyValue)
            } else if keyValue[0] == "towgs84" {
                toWGS84Processing(keyValue)
            }
        }
        setMapProjection3Parameters(centralMeridian*DEG2RAD, falseEasting, falseNorthing)
        break
        
    //=>MapProjection4Parameters
    case CoordinateType.azimuthalEquidistant,
         CoordinateType.bonne,
         CoordinateType.cassini,
         CoordinateType.cylindricalEqualArea,
         CoordinateType.gnomonic,
         CoordinateType.orthographic,
         CoordinateType.polyconic,
         CoordinateType.stereographic:
        
        var centralMeridian: Double = 0
        var originLatitude: Double = 0
        var falseEasting: Double = 0
        var falseNorthing: Double = 0
        
        for item in arr {
            let keyValue = item.components(separatedBy: "=")
            if keyValue[0] == "lon_0" {
                centralMeridian = Double(keyValue[1])!
            } else if keyValue[0] == "lat_0" {
                originLatitude = Double(keyValue[1])!
            } else if keyValue[0] == "x_0" {
                falseEasting = Double(keyValue[1])!
            } else if keyValue[0] == "y_0" {
                falseNorthing = Double(keyValue[1])!
            } else if keyValue[0] == "datum" {
                datumProcessing(keyValue)
            } else if keyValue[0] == "towgs84" {
                toWGS84Processing(keyValue)
            }
        }
        setMapProjection4Parameters(centralMeridian*DEG2RAD, originLatitude*DEG2RAD, falseEasting, falseNorthing)
        break
        
        
    //=>MapProjection5Parameters
    case CoordinateType.transverseCylindricalEqualArea,
         CoordinateType.transverseMercator,
         CoordinateType.lambertConformalConic1Parallel:
        
        var centralMeridian: Double = 0
        var originLatitude: Double = 0
        var scaleFactor: Double = 1
        var falseEasting: Double = 0
        var falseNorthing: Double = 0
        
        for item in arr {
            let keyValue = item.components(separatedBy: "=")
            if keyValue[0] == "lon_0" {
                centralMeridian = Double(keyValue[1])!
            } else if keyValue[0] == "lat_0" {
                originLatitude = Double(keyValue[1])!
            } else if keyValue[0] == "k" {
                scaleFactor = Double(keyValue[1])!
            } else if keyValue[0] == "x_0" {
                falseEasting = Double(keyValue[1])!
            } else if keyValue[0] == "y_0" {
                falseNorthing = Double(keyValue[1])!
            } else if keyValue[0] == "datum" {
                datumProcessing(keyValue)
            } else if keyValue[0] == "towgs84" {
                toWGS84Processing(keyValue)
            }
        }
        setMapProjection5Parameters(centralMeridian*DEG2RAD, originLatitude*DEG2RAD, scaleFactor, falseEasting, falseNorthing)
        break
        
        
    //=>MapProjection6Parameters
    case CoordinateType.lambertConformalConic2Parallels,
         CoordinateType.albersEqualAreaConic:
        
        var centralMeridian: Double = 0
        var originLatitude: Double = 0
        var standardParallel1: Double = 0
        var standardParallel2: Double = 0
        var falseEasting: Double = 0
        var falseNorthing: Double = 0
        
        for item in arr {
            let keyValue = item.components(separatedBy: "=")
            if keyValue[0] == "lon_0" {
                centralMeridian = Double(keyValue[1])!
            } else if keyValue[0] == "lat_0" {
                originLatitude = Double(keyValue[1])!
            } else if keyValue[0] == "lat_1" {
                standardParallel1 = Double(keyValue[1])!
            } else if keyValue[0] == "lat_2" {
                standardParallel2 = Double(keyValue[1])!
            } else if keyValue[0] == "x_0" {
                falseEasting = Double(keyValue[1])!
            } else if keyValue[0] == "y_0" {
                falseNorthing = Double(keyValue[1])!
            } else if keyValue[0] == "datum" {
                datumProcessing(keyValue)
            } else if keyValue[0] == "towgs84" {
                toWGS84Processing(keyValue)
            }
        }
        setMapProjection6Parameters(centralMeridian*DEG2RAD, originLatitude*DEG2RAD, standardParallel1*DEG2RAD, standardParallel2*DEG2RAD, falseEasting, falseNorthing);
        break
        
        
    //=>MercatorScaleFactorParameters
    case CoordinateType.mercatorScaleFactor:
        
        var centralMeridian: Double = 0
        var scaleFactor: Double = 1
        var falseEasting: Double = 0
        var falseNorthing: Double = 0
        
        for item in arr {
            let keyValue = item.components(separatedBy: "=")
            if keyValue[0] == "lon_0" {
                centralMeridian = Double(keyValue[1])!
            } else if keyValue[0] == "k" {
                scaleFactor = Double(keyValue[1])!
            } else if keyValue[0] == "x_0" {
                falseEasting = Double(keyValue[1])!
            } else if keyValue[0] == "y_0" {
                falseNorthing = Double(keyValue[1])!
            } else if keyValue[0] == "datum" {
                datumProcessing(keyValue)
            } else if keyValue[0] == "towgs84" {
                toWGS84Processing(keyValue)
            }
        }
        setMercatorScaleFactorParameters(centralMeridian*DEG2RAD, scaleFactor, falseEasting, falseNorthing);
        break
        
        
    //=>MercatorStandardParallelParameters
    case CoordinateType.mercatorStandardParallel:
        
        var centralMeridian: Double = 0
        var standardParallel: Double = 0
        var scaleFactor: Double = 1
        var falseEasting: Double = 0
        var falseNorthing: Double = 0
        
        for item in arr {
            let keyValue = item.components(separatedBy: "=")
            if keyValue[0] == "lon_0" {
                centralMeridian = Double(keyValue[1])!
            } else if keyValue[0] == "lat_ts" {
                standardParallel = Double(keyValue[1])!
            } else if keyValue[0] == "k" {
                scaleFactor = Double(keyValue[1])!
            } else if keyValue[0] == "x_0" {
                falseEasting = Double(keyValue[1])!
            } else if keyValue[0] == "y_0" {
                falseNorthing = Double(keyValue[1])!
            } else if keyValue[0] == "datum" {
                datumProcessing(keyValue)
            } else if keyValue[0] == "towgs84" {
                toWGS84Processing(keyValue)
            }
        }
        setMercatorStandardParallelParameters(centralMeridian*DEG2RAD, standardParallel*DEG2RAD, scaleFactor, falseEasting, falseNorthing);
        break
        
        
    //=>EquidistantCylindricalParameters
    case CoordinateType.equidistantCylindrical:
        
        var centralMeridian: Double = 0
        var standardParallel: Double = 0
        var falseEasting: Double = 0
        var falseNorthing: Double = 0
        
        for item in arr {
            let keyValue = item.components(separatedBy: "=")
            if keyValue[0] == "lon_0" {
                centralMeridian = Double(keyValue[1])!
            } else if keyValue[0] == "lat_ts" {
                standardParallel = Double(keyValue[1])!
            } else if keyValue[0] == "x_0" {
                falseEasting = Double(keyValue[1])!
            } else if keyValue[0] == "y_0" {
                falseNorthing = Double(keyValue[1])!
            } else if keyValue[0] == "datum" {
                datumProcessing(keyValue)
            } else if keyValue[0] == "towgs84" {
                toWGS84Processing(keyValue)
            }
        }
        setEquidistantCylindricalParameters(centralMeridian*DEG2RAD, standardParallel*DEG2RAD, falseEasting, falseNorthing);
        break
        
        
    //=>NeysParameters
    case CoordinateType.neys:
        
        var centralMeridian: Double = 0
        var originLatitude: Double = 0
        var standardParallel: Double = 0
        var falseEasting: Double = 0
        var falseNorthing: Double = 0
        
        for item in arr {
            let keyValue = item.components(separatedBy: "=")
            if keyValue[0] == "lon_0" {
                centralMeridian = Double(keyValue[1])!
            } else if keyValue[0] == "lat_0" {
                originLatitude = Double(keyValue[1])!
            } else if keyValue[0] == "lat_ts" {
                standardParallel = Double(keyValue[1])!
            } else if keyValue[0] == "x_0" {
                falseEasting = Double(keyValue[1])!
            } else if keyValue[0] == "y_0" {
                falseNorthing = Double(keyValue[1])!
            } else if keyValue[0] == "datum" {
                datumProcessing(keyValue)
            } else if keyValue[0] == "towgs84" {
                toWGS84Processing(keyValue)
            }
        }
        setNeysParameters(centralMeridian*DEG2RAD, originLatitude*DEG2RAD, standardParallel*DEG2RAD, falseEasting, falseNorthing);
        break
        
        
    //=>
    case CoordinateType.newZealandMapGrid:
        // Các tham số hệ này đã fix sẵn trong GeoTrans
        
        var centralMeridian: Double = 0
        var originLatitude: Double = 0
        var falseEasting: Double = 0
        var falseNorthing: Double = 0
        
        for item in arr {
            let keyValue = item.components(separatedBy: "=")
            if keyValue[0] == "lon_0" {
                centralMeridian = Double(keyValue[1])!
            } else if keyValue[0] == "lat_0" {
                originLatitude = Double(keyValue[1])!
            } else if keyValue[0] == "x_0" {
                falseEasting = Double(keyValue[1])!
            } else if keyValue[0] == "y_0" {
                falseNorthing = Double(keyValue[1])!
            } else if keyValue[0] == "datum" {
                datumProcessing(keyValue)
            } else if keyValue[0] == "towgs84" {
                toWGS84Processing(keyValue)
            }
        }
        setMapProjection4Parameters(centralMeridian*DEG2RAD, originLatitude*DEG2RAD, falseEasting, falseNorthing)
        break
        
        
    //TODO ObliqueMercatorParameters
    case CoordinateType.obliqueMercator:
        var originLatitude: Double = 0
        var latitude1: Double = 0
        var latitude2: Double = 0
        var longitude1: Double = 0
        var longitude2: Double = 0
        var falseEasting: Double = 0
        var falseNorthing: Double = 0
        var scaleFactor: Double = 1
        
        // lonc, alpha, gama => latitude1, latitude2, longitude1, longitude2
        for item in arr {
            let keyValue = item.components(separatedBy: "=")
            if keyValue[0] == "lat_0" {
                originLatitude = Double(keyValue[1])!
            } else if keyValue[0] == "lat_1" {
                latitude1 = Double(keyValue[1])!
            } else if keyValue[0] == "lat_2" {
                latitude2 = Double(keyValue[1])!
            } else if keyValue[0] == "lon_1" {
                longitude1 = Double(keyValue[1])!
            } else if keyValue[0] == "lon_2" {
                longitude2 = Double(keyValue[1])!
            } else if keyValue[0] == "k" {
                scaleFactor = Double(keyValue[1])!
            } else if keyValue[0] == "x_0" {
                falseEasting = Double(keyValue[1])!
            } else if keyValue[0] == "y_0" {
                falseNorthing = Double(keyValue[1])!
            } else if keyValue[0] == "datum" {
                datumProcessing(keyValue)
            } else if keyValue[0] == "towgs84" {
                toWGS84Processing(keyValue)
            }
        }
        
        setObliqueMercatorParameters(originLatitude*DEG2RAD, longitude1*DEG2RAD, latitude1*DEG2RAD, longitude2*DEG2RAD, latitude2*DEG2RAD, falseEasting, falseNorthing, scaleFactor);
        break
        
        //TODO Chưa có lưới chiếu này trong thư viện proj4
    //=>PolarStereographicScaleFactorParameters
    case CoordinateType.polarStereographicScaleFactor:
        var centralMeridian: Double = 0 //Longitude down from pole
        var scaleFactor: Double = 1
        var falseEasting: Double = 0
        var falseNorthing: Double = 0
        
        for item in arr {
            let keyValue = item.components(separatedBy: "=")
            if keyValue[0] == "lon_0" {
                centralMeridian = Double(keyValue[1])!
            } else if keyValue[0] == "k" {
                scaleFactor = Double(keyValue[1])!
            } else if keyValue[0] == "x_0" {
                falseEasting = Double(keyValue[1])!
            } else if keyValue[0] == "y_0" {
                falseNorthing = Double(keyValue[1])!
            } else if keyValue[0] == "datum" {
                datumProcessing(keyValue)
            } else if keyValue[0] == "towgs84" {
                toWGS84Processing(keyValue)
            }
        }
        setPolarStereographicScaleFactorParameters(centralMeridian*DEG2RAD, scaleFactor, falseEasting, falseNorthing)
        break
        
    //=>PolarStereographicStandardParallelParameters
    case CoordinateType.polarStereographicStandardParallel:
        var centralMeridian: Double = 0 //Longitude down from pole
        var standardParallel: Double = 0
        var falseEasting: Double = 0
        var falseNorthing: Double = 0
        
        for item in arr {
            let keyValue = item.components(separatedBy: "=")
            if keyValue[0] == "lon_0" {
                centralMeridian = Double(keyValue[1])!
            } else if keyValue[0] == "lat_ts" {
                standardParallel = Double(keyValue[1])!
            } else if keyValue[0] == "x_0" {
                falseEasting = Double(keyValue[1])!
            } else if keyValue[0] == "y_0" {
                falseNorthing = Double(keyValue[1])!
            } else if keyValue[0] == "datum" {
                datumProcessing(keyValue)
            } else if keyValue[0] == "towgs84" {
                toWGS84Processing(keyValue)
            }
        }
        setPolarStereographicStandardParallelParameters(centralMeridian*DEG2RAD, standardParallel*DEG2RAD, falseEasting, falseNorthing);
        
        break
        
        
    //TODO Chưa có lưới chiếu này trong thư viện proj4
    case CoordinateType.webMercator:
        // ========= DATUM TRANSFORMATION ========
        // Tạo tham số nguồn là geodetic (tọa độ trắc địa)
        //GeodeticParameters geodeticMlsEgmParams(CoordinateType.geodetic, HeightType.EGM2008TwoPtFiveMinBicubicSpline);
        
        // Tính chuyển tọa độ sang hệ đích (tọa độ trắc địa)
        //CoordinateConversionService ccsGeodeticMlsEgmToGeodetic(_srcCode, &geodeticMlsEgmParams, _targetCode, &geodeticMlsEgmParams);
        
        // Tính chuyển tọa độ trắc địa sang tọa độ trắc địa trên hệ cục bộ
        //Accuracy sourceAccuracy;
        //Accuracy targetAccuracy;
        //GeodeticCoordinates sourceCoordinates(CoordinateType.geodetic, _lng, _lat, _alt);
        //GeodeticCoordinates targetCoordinates;
        
        // Tính chuyển tọa độ trắc địa toàn cầu sang tọa độ trắc địa cục bộ có sử sụng datum
        //ccsGeodeticMlsEgmToGeodetic.convertSourceToTarget(&sourceCoordinates, &sourceAccuracy, targetCoordinates, targetAccuracy);
        
        //double __lat = targetCoordinates.latitude();
        //double __lng = targetCoordinates.longitude();
        // ========= END DATUM TRANSFORMATION ========
        
        //NSString *ellipsoidCode = @"WE"; // Luôn luôn là WE
        //char* eCode = (char *)[ellipsoidCode cStringUsingEncoding:NSASCIIStringEncoding];
        //WebMercator webMercator = WebMercator(eCode);
        //MapProjectionCoordinates *mapProjectionCoordinates = webMercator.convertFromGeodetic(new GeodeticCoordinates(CoordinateType.geodetic, __lng, __lat));
        //*easting = mapProjectionCoordinates->easting();
        //*northing = mapProjectionCoordinates->northing();
        break
        
        
    default:
        break;
    }
}
