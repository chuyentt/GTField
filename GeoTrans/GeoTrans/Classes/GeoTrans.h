//
//  GeoTrans.h
//  Pods
//
//  Created by Chuyen Trung Tran on 2/20/17.
//
//

#import <Foundation/Foundation.h>

#define RAD2DEG (180.0/M_PI)
#define DEG2RAD (M_PI/180.0)

#define guard(CONDITION) if (CONDITION) {}

/*
 * Lấy tham số Ellipsoid
 */
NS_INLINE void getEllipsoidParameters(double *a, double *f) {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"ellipsoidSemiMajorAxis"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:6378137.0 forKey:@"ellipsoidSemiMajorAxis"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"ellipsoidFlattening"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:1.0/298.257223563 forKey:@"ellipsoidFlattening"];
    }
    *a = [[NSUserDefaults standardUserDefaults] doubleForKey:@"ellipsoidSemiMajorAxis"];
    *f = [[NSUserDefaults standardUserDefaults] doubleForKey:@"ellipsoidFlattening"];
}

NS_INLINE void setEllipsoidParameters(double a, double f) {
    [[NSUserDefaults standardUserDefaults] setDouble:a forKey:@"ellipsoidSemiMajorAxis"];
    [[NSUserDefaults standardUserDefaults] setDouble:f forKey:@"ellipsoidFlattening"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*
 * Lấy 3 tham số Datum
 */
NS_INLINE void getThreeParamDatum(double *dx, double *dy, double *dz) {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"deltaX"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"deltaX"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"deltaY"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"deltaY"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"deltaZ"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"deltaZ"];
    }
    *dx = [[NSUserDefaults standardUserDefaults] doubleForKey:@"deltaX"];
    *dy = [[NSUserDefaults standardUserDefaults] doubleForKey:@"deltaY"];
    *dz = [[NSUserDefaults standardUserDefaults] doubleForKey:@"deltaZ"];
}

NS_INLINE void setThreeParamDatum(double dx, double dy, double dz) {
    [[NSUserDefaults standardUserDefaults] setDouble:dx forKey:@"deltaX"];
    [[NSUserDefaults standardUserDefaults] setDouble:dy forKey:@"deltaY"];
    [[NSUserDefaults standardUserDefaults] setDouble:dz forKey:@"deltaZ"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*
 * Lấy 7 tham số Datum
 */
NS_INLINE void getSevenParamDatum(double *dx, double *dy, double *dz, double *rx, double *ry, double *rz, double *sf) {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"deltaX"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"deltaX"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"deltaY"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"deltaY"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"deltaZ"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"deltaZ"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"rotationX"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"rotationX"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"rotationY"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"rotationY"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"rotationZ"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"rotationZ"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"datumScaleFactor"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"datumScaleFactor"];
    }
    *dx = [[NSUserDefaults standardUserDefaults] doubleForKey:@"deltaX"];
    *dy = [[NSUserDefaults standardUserDefaults] doubleForKey:@"deltaY"];
    *dz = [[NSUserDefaults standardUserDefaults] doubleForKey:@"deltaZ"];
    *rx = [[NSUserDefaults standardUserDefaults] doubleForKey:@"rotationX"];
    *ry = [[NSUserDefaults standardUserDefaults] doubleForKey:@"rotationY"];
    *rz = [[NSUserDefaults standardUserDefaults] doubleForKey:@"rotationZ"];
    *sf = [[NSUserDefaults standardUserDefaults] doubleForKey:@"datumScaleFactor"];
}

/*
 * Lưu thông tin datum 7 tham số
 * rotation in radians
 * scaleFactor in double (không phải nghịch đảo)
 */
NS_INLINE void setSevenParamDatum(double dx, double dy, double dz, double rx, double ry, double rz, double sf) {
    [[NSUserDefaults standardUserDefaults] setDouble:dx forKey:@"deltaX"];
    [[NSUserDefaults standardUserDefaults] setDouble:dy forKey:@"deltaY"];
    [[NSUserDefaults standardUserDefaults] setDouble:dz forKey:@"deltaZ"];
    
    [[NSUserDefaults standardUserDefaults] setDouble:rx forKey:@"rotationX"];
    [[NSUserDefaults standardUserDefaults] setDouble:ry forKey:@"rotationY"];
    [[NSUserDefaults standardUserDefaults] setDouble:rz forKey:@"rotationZ"];
    [[NSUserDefaults standardUserDefaults] setDouble:sf forKey:@"datumScaleFactor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*
 * Lấy tham số lưới chiếu đã thiết lập
 */
NS_INLINE void getEquidistantCylindricalParameters(double *centralMeridian, double *standardParallel, double *falseEasting, double *falseNorthing) {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"centralMeridian"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"centralMeridian"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"standardParallel"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"standardParallel"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"falseEasting"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"falseEasting"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"falseNorthing"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"falseNorthing"];
    }
    
    *centralMeridian = [[NSUserDefaults standardUserDefaults] doubleForKey:@"centralMeridian"];
    *standardParallel = [[NSUserDefaults standardUserDefaults] doubleForKey:@"standardParallel"];
    *centralMeridian = [[NSUserDefaults standardUserDefaults] doubleForKey:@"falseEasting"];
    *centralMeridian = [[NSUserDefaults standardUserDefaults] doubleForKey:@"falseNorthing"];
}

NS_INLINE void setEquidistantCylindricalParameters(double centralMeridian, double standardParallel, double falseEasting, double falseNorthing) {
    [[NSUserDefaults standardUserDefaults] setDouble:centralMeridian forKey:@"centralMeridian"];
    [[NSUserDefaults standardUserDefaults] setDouble:standardParallel forKey:@"standardParallel"];
    [[NSUserDefaults standardUserDefaults] setDouble:falseNorthing forKey:@"falseEasting"];
    [[NSUserDefaults standardUserDefaults] setDouble:falseNorthing forKey:@"falseNorthing"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NS_INLINE void getLocalCartesianParameters(double *longitude, double *latitude, double *height, double *orientation) {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"longitude"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"longitude"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"latitude"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"height"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"height"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"orientation"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"orientation"];
    }
    
    *longitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"longitude"];
    *latitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"latitude"];
    *height = [[NSUserDefaults standardUserDefaults] doubleForKey:@"height"];
    *orientation = [[NSUserDefaults standardUserDefaults] doubleForKey:@"orientation"];
}

NS_INLINE void setLocalCartesianParameters(double longitude, double latitude, double height, double orientation) {
    [[NSUserDefaults standardUserDefaults] setDouble:longitude forKey:@"longitude"];
    [[NSUserDefaults standardUserDefaults] setDouble:latitude forKey:@"latitude"];
    [[NSUserDefaults standardUserDefaults] setDouble:height forKey:@"height"];
    [[NSUserDefaults standardUserDefaults] setDouble:orientation forKey:@"orientation"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NS_INLINE void getMapProjection3Parameters(double *centralMeridian, double *falseEasting, double *falseNorthing) {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"centralMeridian"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"centralMeridian"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"falseEasting"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"falseEasting"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"falseNorthing"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"falseNorthing"];
    }
    
    *centralMeridian = [[NSUserDefaults standardUserDefaults] doubleForKey:@"centralMeridian"];
    *falseEasting = [[NSUserDefaults standardUserDefaults] doubleForKey:@"falseEasting"];
    *falseNorthing = [[NSUserDefaults standardUserDefaults] doubleForKey:@"falseNorthing"];
}

NS_INLINE void setMapProjection3Parameters(double centralMeridian, double falseEasting, double falseNorthing) {
    [[NSUserDefaults standardUserDefaults] setDouble:centralMeridian forKey:@"centralMeridian"];
    [[NSUserDefaults standardUserDefaults] setDouble:falseEasting forKey:@"falseEasting"];
    [[NSUserDefaults standardUserDefaults] setDouble:falseNorthing forKey:@"falseNorthing"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NS_INLINE void getMapProjection4Parameters(double *centralMeridian, double *originLatitude, double *falseEasting, double *falseNorthing) {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"centralMeridian"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"centralMeridian"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"originLatitude"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"originLatitude"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"falseEasting"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"falseEasting"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"falseNorthing"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"falseNorthing"];
    }
    
    *centralMeridian = [[NSUserDefaults standardUserDefaults] doubleForKey:@"centralMeridian"];
    *originLatitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"originLatitude"];
    *falseEasting = [[NSUserDefaults standardUserDefaults] doubleForKey:@"falseEasting"];
    *falseNorthing = [[NSUserDefaults standardUserDefaults] doubleForKey:@"falseNorthing"];
}

NS_INLINE void setMapProjection4Parameters(double centralMeridian, double originLatitude, double falseEasting, double falseNorthing) {
    [[NSUserDefaults standardUserDefaults] setDouble:centralMeridian forKey:@"centralMeridian"];
    [[NSUserDefaults standardUserDefaults] setDouble:originLatitude forKey:@"originLatitude"];
    [[NSUserDefaults standardUserDefaults] setDouble:falseEasting forKey:@"falseEasting"];
    [[NSUserDefaults standardUserDefaults] setDouble:falseNorthing forKey:@"falseNorthing"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NS_INLINE void getMapProjection5Parameters(double *centralMeridian, double *originLatitude, double *scaleFactor, double *falseEasting, double *falseNorthing) {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"centralMeridian"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"centralMeridian"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"originLatitude"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"originLatitude"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"scaleFactor"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:1.0 forKey:@"scaleFactor"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"falseEasting"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"falseEasting"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"falseNorthing"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"falseNorthing"];
    }
    
    *centralMeridian = [[NSUserDefaults standardUserDefaults] doubleForKey:@"centralMeridian"];
    *originLatitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"originLatitude"];
    *scaleFactor = [[NSUserDefaults standardUserDefaults] doubleForKey:@"scaleFactor"];
    *falseEasting = [[NSUserDefaults standardUserDefaults] doubleForKey:@"falseEasting"];
    *falseNorthing = [[NSUserDefaults standardUserDefaults] doubleForKey:@"falseNorthing"];
}

NS_INLINE void setMapProjection5Parameters(double centralMeridian, double originLatitude, double scaleFactor, double falseEasting, double falseNorthing) {
    [[NSUserDefaults standardUserDefaults] setDouble:centralMeridian forKey:@"centralMeridian"];
    [[NSUserDefaults standardUserDefaults] setDouble:originLatitude forKey:@"originLatitude"];
    [[NSUserDefaults standardUserDefaults] setDouble:scaleFactor forKey:@"scaleFactor"];
    [[NSUserDefaults standardUserDefaults] setDouble:falseEasting forKey:@"falseEasting"];
    [[NSUserDefaults standardUserDefaults] setDouble:falseNorthing forKey:@"falseNorthing"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NS_INLINE void getMapProjection6Parameters(double *centralMeridian, double *originLatitude, double *standardParallel1, double *standardParallel2, double *falseEasting, double *falseNorthing) {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"centralMeridian"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"centralMeridian"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"originLatitude"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"originLatitude"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"standardParallel1"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"standardParallel1"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"standardParallel2"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"standardParallel2"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"falseEasting"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"falseEasting"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"falseNorthing"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"falseNorthing"];
    }
    
    *centralMeridian = [[NSUserDefaults standardUserDefaults] doubleForKey:@"centralMeridian"];
    *originLatitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"originLatitude"];
    *standardParallel1 = [[NSUserDefaults standardUserDefaults] doubleForKey:@"standardParallel1"];
    *standardParallel2 = [[NSUserDefaults standardUserDefaults] doubleForKey:@"standardParallel2"];
    *falseEasting = [[NSUserDefaults standardUserDefaults] doubleForKey:@"falseEasting"];
    *falseNorthing = [[NSUserDefaults standardUserDefaults] doubleForKey:@"falseNorthing"];
}

NS_INLINE void setMapProjection6Parameters(double centralMeridian, double originLatitude, double standardParallel1, double standardParallel2, double falseEasting, double falseNorthing) {
    [[NSUserDefaults standardUserDefaults] setDouble:centralMeridian forKey:@"centralMeridian"];
    [[NSUserDefaults standardUserDefaults] setDouble:originLatitude forKey:@"originLatitude"];
    [[NSUserDefaults standardUserDefaults] setDouble:standardParallel1 forKey:@"standardParallel1"];
    [[NSUserDefaults standardUserDefaults] setDouble:standardParallel2 forKey:@"standardParallel2"];
    [[NSUserDefaults standardUserDefaults] setDouble:falseEasting forKey:@"falseEasting"];
    [[NSUserDefaults standardUserDefaults] setDouble:falseNorthing forKey:@"falseNorthing"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NS_INLINE void getMercatorStandardParallelParameters(double *centralMeridian, double *standardParallel, double *scaleFactor, double *falseEasting, double *falseNorthing) {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"centralMeridian"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"centralMeridian"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"standardParallel"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"standardParallel"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"scaleFactor"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:1.0 forKey:@"scaleFactor"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"falseEasting"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"falseEasting"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"falseNorthing"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"falseNorthing"];
    }
    
    *centralMeridian = [[NSUserDefaults standardUserDefaults] doubleForKey:@"centralMeridian"];
    *standardParallel = [[NSUserDefaults standardUserDefaults] doubleForKey:@"standardParallel"];
    *scaleFactor = [[NSUserDefaults standardUserDefaults] doubleForKey:@"scaleFactor"];
    *falseEasting = [[NSUserDefaults standardUserDefaults] doubleForKey:@"falseEasting"];
    *falseNorthing = [[NSUserDefaults standardUserDefaults] doubleForKey:@"falseNorthing"];
}

NS_INLINE void setMercatorStandardParallelParameters(double centralMeridian, double standardParallel, double scaleFactor, double falseEasting, double falseNorthing) {
    [[NSUserDefaults standardUserDefaults] setDouble:centralMeridian forKey:@"centralMeridian"];
    [[NSUserDefaults standardUserDefaults] setDouble:standardParallel forKey:@"standardParallel"];
    [[NSUserDefaults standardUserDefaults] setDouble:scaleFactor forKey:@"scaleFactor"];
    [[NSUserDefaults standardUserDefaults] setDouble:falseEasting forKey:@"falseEasting"];
    [[NSUserDefaults standardUserDefaults] setDouble:falseNorthing forKey:@"falseNorthing"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NS_INLINE void getMercatorScaleFactorParameters(double *centralMeridian, double *scaleFactor, double *falseEasting, double *falseNorthing) {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"centralMeridian"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"centralMeridian"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"scaleFactor"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:1.0 forKey:@"scaleFactor"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"falseEasting"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"falseEasting"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"falseNorthing"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"falseNorthing"];
    }
    
    *centralMeridian = [[NSUserDefaults standardUserDefaults] doubleForKey:@"centralMeridian"];
    *scaleFactor = [[NSUserDefaults standardUserDefaults] doubleForKey:@"scaleFactor"];
    *falseEasting = [[NSUserDefaults standardUserDefaults] doubleForKey:@"falseEasting"];
    *falseNorthing = [[NSUserDefaults standardUserDefaults] doubleForKey:@"falseNorthing"];
}

NS_INLINE void setMercatorScaleFactorParameters(double centralMeridian, double scaleFactor, double falseEasting, double falseNorthing) {
    [[NSUserDefaults standardUserDefaults] setDouble:centralMeridian forKey:@"centralMeridian"];
    [[NSUserDefaults standardUserDefaults] setDouble:scaleFactor forKey:@"scaleFactor"];
    [[NSUserDefaults standardUserDefaults] setDouble:falseEasting forKey:@"falseEasting"];
    [[NSUserDefaults standardUserDefaults] setDouble:falseNorthing forKey:@"falseNorthing"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NS_INLINE void getNeysParameters(double *centralMeridian, double *originLatitude, double *standardParallel1, double *falseEasting, double *falseNorthing) {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"centralMeridian"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"centralMeridian"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"originLatitude"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"originLatitude"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"standardParallel1"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"standardParallel1"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"falseEasting"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"falseEasting"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"falseNorthing"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"falseNorthing"];
    }
    
    *centralMeridian = [[NSUserDefaults standardUserDefaults] doubleForKey:@"centralMeridian"];
    *originLatitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"originLatitude"];
    *standardParallel1 = [[NSUserDefaults standardUserDefaults] doubleForKey:@"standardParallel1"];
    *falseEasting = [[NSUserDefaults standardUserDefaults] doubleForKey:@"falseEasting"];
    *falseNorthing = [[NSUserDefaults standardUserDefaults] doubleForKey:@"falseNorthing"];
}

NS_INLINE void setNeysParameters(double centralMeridian, double originLatitude, double standardParallel1, double falseEasting, double falseNorthing) {
    [[NSUserDefaults standardUserDefaults] setDouble:centralMeridian forKey:@"centralMeridian"];
    [[NSUserDefaults standardUserDefaults] setDouble:originLatitude forKey:@"originLatitude"];
    [[NSUserDefaults standardUserDefaults] setDouble:standardParallel1 forKey:@"standardParallel1"];
    [[NSUserDefaults standardUserDefaults] setDouble:falseEasting forKey:@"falseEasting"];
    [[NSUserDefaults standardUserDefaults] setDouble:falseNorthing forKey:@"falseNorthing"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NS_INLINE void getObliqueMercatorParameters(double *originLatitude, double *longitude1, double *latitude1, double *longitude2, double *latitude2, double *falseEasting, double *falseNorthing, double *scaleFactor) {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"originLatitude"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"originLatitude"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"longitude1"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"longitude1"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"latitude1"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"latitude1"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"longitude2"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"longitude2"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"latitude2"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"latitude2"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"falseEasting"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"falseEasting"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"falseNorthing"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"falseNorthing"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"scaleFactor"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:1.0 forKey:@"scaleFactor"];
    }
    
    *originLatitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"originLatitude"];
    *longitude1 = [[NSUserDefaults standardUserDefaults] doubleForKey:@"longitude1"];
    *latitude1 = [[NSUserDefaults standardUserDefaults] doubleForKey:@"latitude1"];
    *longitude2 = [[NSUserDefaults standardUserDefaults] doubleForKey:@"longitude2"];
    *latitude2 = [[NSUserDefaults standardUserDefaults] doubleForKey:@"latitude2"];
    *falseEasting = [[NSUserDefaults standardUserDefaults] doubleForKey:@"falseEasting"];
    *falseNorthing = [[NSUserDefaults standardUserDefaults] doubleForKey:@"falseNorthing"];
    *scaleFactor = [[NSUserDefaults standardUserDefaults] doubleForKey:@"scaleFactor"];
}

NS_INLINE void setObliqueMercatorParameters(double originLatitude, double longitude1, double latitude1, double longitude2, double latitude2, double falseEasting, double falseNorthing, double scaleFactor) {
    [[NSUserDefaults standardUserDefaults] setDouble:originLatitude forKey:@"originLatitude"];
    [[NSUserDefaults standardUserDefaults] setDouble:longitude1 forKey:@"longitude1"];
    [[NSUserDefaults standardUserDefaults] setDouble:latitude1 forKey:@"latitude1"];
    [[NSUserDefaults standardUserDefaults] setDouble:longitude2 forKey:@"longitude2"];
    [[NSUserDefaults standardUserDefaults] setDouble:latitude2 forKey:@"latitude2"];
    [[NSUserDefaults standardUserDefaults] setDouble:falseEasting forKey:@"falseEasting"];
    [[NSUserDefaults standardUserDefaults] setDouble:falseNorthing forKey:@"falseNorthing"];
    [[NSUserDefaults standardUserDefaults] setDouble:scaleFactor forKey:@"scaleFactor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NS_INLINE void getPolarStereographicStandardParallelParameters(double *longitudeDownFromPole, double *latitudeOfTrueScale, double *falseEasting, double *falseNorthing) {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"longitudeDownFromPole"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"longitudeDownFromPole"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"latitudeOfTrueScale"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"latitudeOfTrueScale"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"falseEasting"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"falseEasting"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"falseNorthing"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"falseNorthing"];
    }
    
    *longitudeDownFromPole = [[NSUserDefaults standardUserDefaults] doubleForKey:@"longitudeDownFromPole"];
    *latitudeOfTrueScale = [[NSUserDefaults standardUserDefaults] doubleForKey:@"latitudeOfTrueScale"];
    *falseEasting = [[NSUserDefaults standardUserDefaults] doubleForKey:@"falseEasting"];
    *falseNorthing = [[NSUserDefaults standardUserDefaults] doubleForKey:@"falseNorthing"];
}

NS_INLINE void setPolarStereographicStandardParallelParameters(double longitudeDownFromPole, double latitudeOfTrueScale, double falseEasting, double falseNorthing) {
    [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"longitudeDownFromPole"];
    [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"latitudeOfTrueScale"];
    [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"falseEasting"];
    [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"falseNorthing"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NS_INLINE void getPolarStereographicScaleFactorParameters(double *longitudeDownFromPole, double *scaleFactor, char *hemisphere, double *falseEasting, double *falseNorthing) {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"longitudeDownFromPole"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"longitudeDownFromPole"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"scaleFactor"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:1.0 forKey:@"scaleFactor"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"hemisphere"]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"N" forKey:@"hemisphere"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"falseEasting"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"falseEasting"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"falseNorthing"]) {
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"falseNorthing"];
    }
    
    *longitudeDownFromPole = [[NSUserDefaults standardUserDefaults] doubleForKey:@"longitudeDownFromPole"];
    *scaleFactor = [[NSUserDefaults standardUserDefaults] doubleForKey:@"scaleFactor"];
    *hemisphere = [[[NSUserDefaults standardUserDefaults] valueForKey:@"hemisphere"] characterAtIndex:0];
    *falseEasting = [[NSUserDefaults standardUserDefaults] doubleForKey:@"falseEasting"];
    *falseNorthing = [[NSUserDefaults standardUserDefaults] doubleForKey:@"falseNorthing"];
}

NS_INLINE void setPolarStereographicScaleFactorParameters(double longitudeDownFromPole, double scaleFactor, char hemisphere, double falseEasting, double falseNorthing) {
    [[NSUserDefaults standardUserDefaults] setDouble:longitudeDownFromPole forKey:@"longitudeDownFromPole"];
    [[NSUserDefaults standardUserDefaults] setDouble:scaleFactor forKey:@"scaleFactor"];
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%c", hemisphere] forKey:@"hemisphere"];
    [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"falseEasting"];
    [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"falseNorthing"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NS_INLINE void getUTMParameters(long *zone, long *_override) {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"zone"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"zone"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"_override"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"_override"];
    }
    
    *zone = [[NSUserDefaults standardUserDefaults] integerForKey:@"zone"];
    *_override = [[NSUserDefaults standardUserDefaults] integerForKey:@"_override"];
}

NS_INLINE void setUTMParameters(long zone, long _override) {
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"zone"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"_override"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NS_INLINE void getCoordinateType(long *type) {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"coordinateType"]) {
        // UTM
        [[NSUserDefaults standardUserDefaults] setInteger:34 forKey:@"coordinateType"];
    }
    
    *type = [[NSUserDefaults standardUserDefaults] integerForKey:@"coordinateType"];
}

NS_INLINE void setCoordinateType(long coordinateType) {
    [[NSUserDefaults standardUserDefaults] setInteger:coordinateType forKey:@"coordinateType"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

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

- (int)getTM:(double *)easting :(double *)northing;
- (int)getTMForLat:(double)lat lng:(double)lng easting:(double *)easting northing:(double *)northing;

- (int)getUTM:(long *)zone :(NSString **)hemi :(double *)easting :(double *)northing;

- (int)geocentric2MGRS:(double)x :(double)y :(double)z :(NSString **)mgrsStr;
- (int)geocentric2UTM:(double)x :(double)y :(double)z :(long *)zone :(NSString **)hemi :(double *)easting :(double *)northing;

// Định nghĩa ellipsoid
- (int)defineEllipsoid:(const char *)code name:(const char *)name a:(double)semiMajorAxis f:(double)flattening;
- (void)defineDatum:(int)datumType dCode:(NSString *)datumCode name:(NSString *)datumName eCode:(NSString *)ellipsoidCode dx:(double)deltaX dy:(double)deltaY dz:(double)deltaZ rx:(double)rotationX ry:(double)rotationY rz:(double)rotationZ sf:(double)scaleFactor;

// Thiết lập kiểu chuỗi proj4
- (void)setProj4Str:(NSString *)parameters;



- (void)getBNGCoordinatesForLat:(double)lat lng:(double)lng alt:(double)alt type:(long)type warningMessage:(NSString **)warningMessage BNGString:(NSString **)BNGString precision:(long *)precision;

- (void)getCartesianCoordinatesForLat:(double)lat lng:(double)lng alt:(double)alt type:(long)type warningMessage:(NSString **)warningMessage x:(double *)x y:(double *)y z:(double *)z;

- (void)getGARSCoordinatesForLat:(double)lat lng:(double)lng alt:(double)alt type:(long)type warningMessage:(NSString **)warningMessage GARSString:(NSString **)GARSString precision:(long *)precision;

- (void)getGEOREFCoordinatesForLat:(double)lat lng:(double)lng alt:(double)alt type:(long)type warningMessage:(NSString **)warningMessage GEOREFString:(NSString **)GEOREFString precision:(long *)precision;

- (void)getMapProjectionCoordinatesForLat:(double)lat lng:(double)lng alt:(double)alt type:(long)type warningMessage:(NSString **)warningMessage easting:(double *)easting northing:(double *)northing;

- (void)getMGRSorUSNGCoordinatesForLat:(double)lat lng:(double)lng alt:(double)alt type:(long)type warningMessage:(NSString **)warningMessage MGRS:(NSString **)MGRS precision:(long *)precision;

- (void)getUPSCoordinatesForLat:(double)lat lng:(double)lng alt:(double)alt type:(long)type warningMessage:(NSString **)warningMessage hemisphere:(NSString **)hemisphere easting:(double *)easting northing:(double *)northing;

- (void)getUTMCoordinatesForLat:(double)lat lng:(double)lng alt:(double)alt type:(long)type warningMessage:(NSString **)warningMessage zone:(long *)zone hemisphere:(NSString **)hemisphere easting:(double *)easting northing:(double *)northing;



@property (nonatomic, assign) double lat;
@property (nonatomic, assign) double lng;
@property (nonatomic, assign) double alt;
@property (nonatomic, assign) const char* srcCode;
@property (nonatomic, assign) const char* targetCode;

@end

/*
 aea : albersEqualAreaConic
 aeqd : azimuthalEquidistant
 bonne : bonne
 cass : cassini
 cea : cylindricalEqualArea
 eck4 : eckert4
 eck6 : eckert6
 geocent : geocentric
 lcc : lambertConformalConic1Parallel
 longlat : geodetic
 merc : mercatorScaleFactor
 mill : millerCylindrical
 moll : mollweide
 nzmg : newZealandMapGrid
 omerc : obliqueMercator
 poly : polyconic
 sinu : sinusoidal
 stere : stereographic
 tmerc : transverseMercator
 utm : universalTransverseMercator
 vandg : vanDerGrinten
*/
