//
//  Global.swift
//  appyMap
//
//  Created by AppyStudio on 09/2015.
//  Copyright (c) 2015 Nicola Canali. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import CoreMotion
import GeoTrans
import simd

var areaUnitItems: [ListItem] = [
    ListItem(code: "0", name:"\(AreaUnit.squareMeter.name) (\(AreaUnit.squareMeter.symbol))", value:""),
    ListItem(code: "1", name:"\(AreaUnit.squareKilometer.name) (\(AreaUnit.squareKilometer.symbol))", value:""),
    ListItem(code: "2", name:"\(AreaUnit.hectare.name) (\(AreaUnit.hectare.symbol))", value:""),
    ListItem(code: "3", name:"\(AreaUnit.squareYard.name) (\(AreaUnit.squareYard.symbol))", value:""),
    ListItem(code: "4", name:"\(AreaUnit.squareMile.name) (\(AreaUnit.squareMile.symbol))", value:""),
    ListItem(code: "5", name:"\(AreaUnit.acre.name) (\(AreaUnit.acre.symbol))", value:"")
]

var distanceUnitItems: [ListItem] = [
    
    ListItem(code: "0", name: "\(LengthUnit.meter.name) (\(LengthUnit.meter.symbol))", value: ""),
    ListItem(code: "1", name: "\(LengthUnit.kilometer.name) (\(LengthUnit.kilometer.symbol))", value: ""),
    ListItem(code: "2", name: "\(LengthUnit.yard.name) (\(LengthUnit.yard.symbol))", value: ""),
    ListItem(code: "3", name: "\(LengthUnit.mile.name) (\(LengthUnit.mile.symbol))", value: "")
]
var latLngFormatItems: [ListItem] = [
    ListItem(code: "0", name: "ddd°mm'ss.sss N/S,E/W", value: ""),
    ListItem(code: "1", name: "ddd.dddddddd N/S,E/W", value: ""),
    ListItem(code: "2", name: "+/-ddd°mm'ss.sss", value: ""),
    ListItem(code: "3", name: "+/-ddd.dddddddd", value: "")
]
var mapGridFormatItems: [ListItem] = [
    ListItem(code: "0", name: "Easting, Northing, Elevation", value: ""),
    ListItem(code: "1", name: "Northing, Easting, Elevation", value: ""),
]

var projectionItems: [ListItem] = [
    ListItem(code:"0", name:"Albers Equal Area Conic", value: ""),
    ListItem(code:"1", name:"Azimuthal Equidistant (S)", value: ""),
    ListItem(code:"2", name:"Bonne", value: ""),
    ListItem(code:"3", name:"British National Grid (BNG)", value: ""),
    ListItem(code:"4", name:"Cassini", value: ""),
    ListItem(code:"5", name:"Cylindrical Equal Area", value: ""),
    ListItem(code:"6", name:"Eckert IV (S)", value: ""),
    ListItem(code:"7", name:"Eckert VI (S)", value: ""),
    ListItem(code:"8", name:"Equidistant Cylindrical (S)", value: ""),
    ListItem(code:"9", name:"Geocentric", value: ""),
    ListItem(code:"10", name:"Geodetic", value: ""),
    ListItem(code:"11", name:"GEOREF", value: ""),
    ListItem(code:"12", name:"Global Area Reference System (GARS)", value: ""),
    ListItem(code:"13", name:"Gnomonic (S)", value: ""),
    ListItem(code:"14", name:"Lambert Conformal Conic (1 Standard Parallel)", value: ""),
    ListItem(code:"15", name:"Lambert Conformal Conic (2 Standard Parallel)", value: ""),
    ListItem(code:"16", name:"Local Cartesian", value: ""),
    ListItem(code:"17", name:"Mercator (Standard Parallel)", value: ""),
    ListItem(code:"18", name:"Mercator (Scale Factor)", value: ""),
    ListItem(code:"19", name:"Military Grid Reference System (MGRS)", value: ""),
    ListItem(code:"20", name:"Miller Cylindrical (S)", value: ""),
    ListItem(code:"21", name:"Mollweide (S)", value: ""),
    ListItem(code:"22", name:"New Zealand Map Grid (NZMG)", value: ""),
    ListItem(code:"23", name:"Ney's (Modified Lambert Conformal Conic)", value: ""),
    ListItem(code:"24", name:"Oblique Mercator", value: ""),
    ListItem(code:"25", name:"Orthographic (S)", value: ""),
    ListItem(code:"26", name:"Polar Stereographic (Standard Parallel)", value: ""),
    ListItem(code:"27", name:"Polar Stereographic (Scale Factor)", value: ""),
    ListItem(code:"28", name:"Polyconic", value: ""),
    ListItem(code:"29", name:"Sinusoidal", value: ""),
    ListItem(code:"30", name:"Stereographic (S)", value: ""),
    ListItem(code:"31", name:"Transverse Cylindrical Equal Area", value: ""),
    ListItem(code:"32", name:"Transverse Mercator", value: ""),
    ListItem(code:"33", name:"Universal Polar Stereographic (UPS)", value: ""),
    ListItem(code:"34", name:"Universal Transverse Mercator (UTM)", value: ""),
    ListItem(code:"35", name:"United States National Grid (USNG)", value: ""),
    ListItem(code:"36", name:"Van der Grinten", value: ""),
    ListItem(code:"37", name:"Web Mercator", value: "")
]

var crsItems = [ListItem]()

var ellipsoidItems: [ListItem] = [
    ListItem(code: "AA", name: "Airy 1830", value: "+a=6377563.396 +b=6356256.90923728 +rf=299.3249646"),
    ListItem(code: "AM", name: "Modified Airy", value: "+a=6377340.189 +b=6356034.44793853 +rf=299.3249646"),
    ListItem(code: "AN", name: "Australian National", value: "+a=6378160 +b=6356774.7191953 +rf=298.25"),
    ListItem(code: "BN", name: "Bessel 1841 (Namibia)", value: "+a=6377483.865 +b=6356165.38296632 +rf=299.1528128"),
    ListItem(code: "BR", name: "Bessel 1841 (Ethiopia, etc.)", value: "+a=6377397.155 +b=6356078.96281818 +rf=299.1528128"),
    ListItem(code: "CC", name: "Clarke 1866", value: "+a=6378206.4 +b=6356583.8 +rf=294.978698213905"),
    ListItem(code: "CD", name: "Clarke 1880", value: "+a=6378249.145 +b=6356514.86954977 +rf=293.465"),
    ListItem(code: "CG", name: "Clarke 1880 (IGN)", value: "+a=6378249.2 +b=6356514.99996344 +rf=293.4660208"),
    ListItem(code: "EA", name: "Everest (India 1830)", value: "+a=6377276.345 +b=6356075.41314024 +rf=300.8017"),
    ListItem(code: "EB", name: "Everest (E. Malaysia, Brunei)", value: "+a=6377298.556 +b=6356097.55030089 +rf=300.8017"),
    ListItem(code: "EC", name: "Everest (India 1956)", value: "+a=6377301.243 +b=6356100.2283681 +rf=300.8017"),
    ListItem(code: "ED", name: "Everest (W. Malaysia 1969)", value: "+a=6377295.664 +b=6356094.6679152 +rf=300.8017"),
    ListItem(code: "EE", name: "Everest (W. Mal. & Sing. 1948", value: "+a=6377304.063 +b=6356103.03899315 +rf=300.8017"),
    ListItem(code: "EF", name: "Everest (Pakistan)", value: "+a=6377309.613 +b=6356108.57054246 +rf=300.8017"),
    ListItem(code: "FA", name: "Mod. Fischer 1960 (S. Asia)", value: "+a=6378155 +b=6356773.32048273 +rf=298.3"),
    ListItem(code: "HE", name: "Helmert 1906", value: "+a=6378200 +b=6356818.16962789 +rf=298.3"),
    ListItem(code: "HO", name: "Hough 1960", value: "+a=6378270 +b=6356794.34343434 +rf=297"),
    ListItem(code: "ID", name: "Indonesian 1974", value: "+a=6378160 +b=6356774.50408554 +rf=298.247"),
    ListItem(code: "IN", name: "International 1924", value: "+a=6378388 +b=6356911.94612794 +rf=297"),
    ListItem(code: "KA", name: "Krassovsky 1940", value: "+a=6378245 +b=6356863.01877304 +rf=298.3"),
    ListItem(code: "RF", name: "GRS 80", value: "+a=6378137 +b=6356752.31414035 +rf=298.257222101"),
    ListItem(code: "SA", name: "South American 1969", value: "+a=6378160 +b=6356774.7191953 +rf=298.25"),
    ListItem(code: "WD", name: "WGS 72", value: "+a=6378135 +b=6356750.52001609 +rf=298.26"),
    ListItem(code: "WE", name: "WGS 84", value: "+a=6378137 +b=6356752.31424517 +rf=298.257223563"),
    ListItem(code: "WO", name: "War Office 1924", value: "+a=6378300.58 +b=6356752.26722972 +rf=296")
]

var datumItems: [ListItem] = [
    ListItem(code: "ACC", name: "ACCRA, Ghana", value: "+ellps_code=WO +towgs84=-170,33,326,0,0,0,0"),
    ListItem(code: "ADI-M", name: "ADINDAN, Mean", value: "+ellps_code=CD +towgs84=-166,-15,204,0,0,0,0"),
    ListItem(code: "ADI-A", name: "ADINDAN, Ethiopia", value: "+ellps_code=CD +towgs84=-165,-11,206,0,0,0,0"),
    ListItem(code: "ADI-B", name: "ADINDAN, Sudan", value: "+ellps_code=CD +towgs84=-161,-14,205,0,0,0,0"),
    ListItem(code: "ADI-C", name: "ADINDAN, Mali", value: "+ellps_code=CD +towgs84=-123,-20,220,0,0,0,0"),
    ListItem(code: "ADI-D", name: "ADINDAN, Senegal", value: "+ellps_code=CD +towgs84=-128,-18,224,0,0,0,0"),
    ListItem(code: "ADI-E", name: "ADINDAN, Burkina Faso", value: "+ellps_code=CD +towgs84=-118,-14,218,0,0,0,0"),
    ListItem(code: "ADI-F", name: "ADINDAN, Cameroon", value: "+ellps_code=CD +towgs84=-134,-2,210,0,0,0,0"),
    ListItem(code: "ADN", name: "ADEN, Yemen", value: "+ellps_code=CD +towgs84=-24,-203,268,0,0,0,0"),
    ListItem(code: "AFG", name: "AFGOOYE, Somalia", value: "+ellps_code=KA +towgs84=-43,-163,45,0,0,0,0"),
    ListItem(code: "AIA", name: "ANTIGUA ISLAND ASTRO 1943", value: "+ellps_code=CD +towgs84=-270,13,62,0,0,0,0"),
    ListItem(code: "AIN-A", name: "AIN EL ABD 1970, Bahrain", value: "+ellps_code=IN +towgs84=-150,-250,-1,0,0,0,0"),
    ListItem(code: "AIN-B", name: "AIN EL ABD 1970, Saudi Arabia ", value: "+ellps_code=IN +towgs84=-143,-236,7,0,0,0,0"),
    ListItem(code: "AMA", name: "AMERICAN SAMOA 1962", value: "+ellps_code=CC +towgs84=-115,118,426,0,0,0,0"),
    ListItem(code: "ANO", name: "ANNA 1 ASTRO 1965, Cocos Is.", value: "+ellps_code=AN +towgs84=-491,-22,435,0,0,0,0"),
    ListItem(code: "ARF-M", name: "ARC 1950, Mean", value: "+ellps_code=CD +towgs84=-143,-90,-294,0,0,0,0"),
    ListItem(code: "ARF-A", name: "ARC 1950, Botswana", value: "+ellps_code=CD +towgs84=-138,-105,-289,0,0,0,0"),
    ListItem(code: "ARF-B", name: "ARC 1950, Lesotho", value: "+ellps_code=CD +towgs84=-125,-108,-295,0,0,0,0"),
    ListItem(code: "ARF-C", name: "ARC 1950, Malawi", value: "+ellps_code=CD +towgs84=-161,-73,-317,0,0,0,0"),
    ListItem(code: "ARF-D", name: "ARC 1950, Swaziland", value: "+ellps_code=CD +towgs84=-134,-105,-295,0,0,0,0"),
    ListItem(code: "ARF-E", name: "ARC 1950, Zaire", value: "+ellps_code=CD +towgs84=-169,-19,-278,0,0,0,0"),
    ListItem(code: "ARF-F", name: "ARC 1950, Zambia", value: "+ellps_code=CD +towgs84=-147,-74,-283,0,0,0,0"),
    ListItem(code: "ARF-G", name: "ARC 1950, Zimbabwe", value: "+ellps_code=CD +towgs84=-145,-97,-292,0,0,0,0"),
    ListItem(code: "ARF-H", name: "ARC 1950, Burundi", value: "+ellps_code=CD +towgs84=-153,-5,-292,0,0,0,0"),
    ListItem(code: "ARS-M", name: "ARC 1960, Kenya & Tanzania", value: "+ellps_code=CD +towgs84=-160,-6,-302,0,0,0,0"),
    ListItem(code: "ARS-A", name: "ARC 1960, Kenya", value: "+ellps_code=CD +towgs84=-157,-2,-299,0,0,0,0"),
    ListItem(code: "ARS-B", name: "ARC 1960, Tanzania", value: "+ellps_code=CD +towgs84=-175,-23,-303,0,0,0,0"),
    ListItem(code: "ARS-C", name: "ARC 1960, Malawi", value: "+ellps_code=CD +towgs84=-179,-81,-314,0,0,0,0"),
    ListItem(code: "ASC", name: "ASCENSION ISLAND 1958", value: "+ellps_code=IN +towgs84=-205,107,53,0,0,0,0"),
    ListItem(code: "ASM", name: "MONTSERRAT ISLAND ASTRO 1958", value: "+ellps_code=CD +towgs84=174,359,365,0,0,0,0"),
    ListItem(code: "ASQ", name: "ASTRO STATION 1952, Marcus Is.", value: "+ellps_code=IN +towgs84=124,-234,-25,0,0,0,0"),
    ListItem(code: "ATF", name: "ASTRO BEACON E 1945, Iwo Jima ", value: "+ellps_code=IN +towgs84=145,75,-272,0,0,0,0"),
    ListItem(code: "AUA", name: "AUSTRALIAN GEODETIC 1966", value: "+ellps_code=AN +towgs84=-128,-52,153,0,0,0,0"),
    ListItem(code: "AUG", name: "AUSTRALIAN GEODETIC 1984", value: "+ellps_code=AN +towgs84=-134,-48,149,0,0,0,0"),
    ListItem(code: "BAT", name: "DJAKARTA, INDONESIA", value: "+ellps_code=BR +towgs84=-377,681,-50,0,0,0,0"),
    ListItem(code: "BID", name: "BISSAU, Guinea-Bissau", value: "+ellps_code=IN +towgs84=-173,253,27,0,0,0,0"),
    ListItem(code: "BIO", name: "BIOKO, Bioko Island", value: "+ellps_code=IN +towgs84=-235,-110,393,0,0,0,0"),
    ListItem(code: "BER", name: "BERMUDA 1957, Bermuda Islands ", value: "+ellps_code=CC +towgs84=-73,213,296,0,0,0,0"),
    ListItem(code: "BOO", name: "BOGOTA OBSERVATORY, Colombia", value: "+ellps_code=IN +towgs84=307,304,-318,0,0,0,0"),
    ListItem(code: "BUR", name: "BUKIT RIMPAH, Banka & Belitung", value: "+ellps_code=BR +towgs84=-384,664,-48,0,0,0,0"),
    ListItem(code: "BVD", name: "BEKAA VALLEY 1920, Lebanon", value: "+ellps_code=CD +towgs84=-183,-15,273,0,0,0,0"),
    ListItem(code: "CAC", name: "CAPE CANAVERAL, Fla & Bahamas ", value: "+ellps_code=CC +towgs84=-2,151,181,0,0,0,0"),
    ListItem(code: "CAI", name: "CAMPO INCHAUSPE 1969, Arg.", value: "+ellps_code=IN +towgs84=-148,136,90,0,0,0,0"),
    ListItem(code: "CAO", name: "CANTON ASTRO 1966, Phoenix Is.", value: "+ellps_code=IN +towgs84=298,-304,-375,0,0,0,0"),
    ListItem(code: "CAP", name: "CAPE, South Africa", value: "+ellps_code=CD +towgs84=-136,-108,-292,0,0,0,0"),
    ListItem(code: "CAZ", name: "CAMP AREA ASTRO, Camp McMurdo ", value: "+ellps_code=IN +towgs84=-104,-129,239,0,0,0,0"),
    ListItem(code: "CCD", name: "S-JTSK, Czech Republic", value: "+ellps_code=BR +towgs84=589,76,480,0,0,0,0"),
    ListItem(code: "CGE", name: "CARTHAGE, Tunisia", value: "+ellps_code=CD +towgs84=-263,6,431,0,0,0,0"),
    ListItem(code: "CHI", name: "CHATHAM ISLAND ASTRO 1971, NZ ", value: "+ellps_code=IN +towgs84=175,-38,113,0,0,0,0"),
    ListItem(code: "CHU", name: "CHUA ASTRO, Paraguay", value: "+ellps_code=IN +towgs84=-134,229,-29,0,0,0,0"),
    ListItem(code: "CIR", name: "CIRCUIT, Zimbabwe", value: "+ellps_code=CD +towgs84=-144,-97,-291,0,0,0,0"),
    ListItem(code: "COA", name: "CORREGO ALEGRE, Brazil", value: "+ellps_code=IN +towgs84=-206,172,-6,0,0,0,0"),
    ListItem(code: "COU", name: "CONAKRY 1905, Guinea", value: "+ellps_code=CG +towgs84=-23,259,-9,0,0,0,0"),
    ListItem(code: "CPR", name: "OBSERVATORIO 1907, Mozambique ", value: "+ellps_code=CC +towgs84=-132,-110,-335,0,0,0,0"),
    ListItem(code: "DAL", name: "DABOLA, Guinea", value: "+ellps_code=CD +towgs84=-83,37,124,0,0,0,0"),
    ListItem(code: "DCS", name: "DCS-3 (ASTRO 1955), St Lucia", value: "+ellps_code=CD +towgs84=-153,153,307,0,0,0,0"),
    ListItem(code: "DID", name: "DECEPTION ISLAND", value: "+ellps_code=CD +towgs84=260,12,-147,0,0,0,0"),
    ListItem(code: "DOB", name: "GUX 1 ASTRO, Guadalcanal Is.", value: "+ellps_code=IN +towgs84=252,-209,-751,0,0,0,0"),
    ListItem(code: "EAS", name: "EASTER ISLAND 1967", value: "+ellps_code=IN +towgs84=211,147,111,0,0,0,0"),
    ListItem(code: "ENW", name: "WAKE-ENIWETOK 1960", value: "+ellps_code=HO +towgs84=102,52,-38,0,0,0,0"),
    ListItem(code: "EST", name: "ESTONIA, 1937", value: "+ellps_code=BR +towgs84=374,150,588,0,0,0,0"),
    ListItem(code: "EUR-M", name: "EUROPEAN 1950, Mean (3 Param) ", value: "+ellps_code=IN +towgs84=-87,-98,-121,0,0,0,0"),
    ListItem(code: "EUR-A", name: "EUROPEAN 1950, Western Europe ", value: "+ellps_code=IN +towgs84=-87,-96,-120,0,0,0,0"),
    ListItem(code: "EUR-B", name: "EUROPEAN 1950, Greece", value: "+ellps_code=IN +towgs84=-84,-95,-130,0,0,0,0"),
    ListItem(code: "EUR-C", name: "EUROPEAN 1950, Norway & Finland", value: "+ellps_code=IN +towgs84=-87,-95,-120,0,0,0,0"),
    ListItem(code: "EUR-D", name: "EUROPEAN 1950, Portugal & Spain", value: "+ellps_code=IN +towgs84=-84,-107,-120,0,0,0,0"),
    ListItem(code: "EUR-E", name: "EUROPEAN 1950, Cyprus", value: "+ellps_code=IN +towgs84=-104,-101,-140,0,0,0,0"),
    ListItem(code: "EUR-F", name: "EUROPEAN 1950, Egypt", value: "+ellps_code=IN +towgs84=-130,-117,-151,0,0,0,0"),
    ListItem(code: "EUR-G", name: "EUROPEAN 1950, England, Channel", value: "+ellps_code=IN +towgs84=-86,-96,-120,0,0,0,0"),
    ListItem(code: "EUR-H", name: "EUROPEAN 1950, Iran", value: "+ellps_code=IN +towgs84=-117,-132,-164,0,0,0,0"),
    ListItem(code: "EUR-I", name: "EUROPEAN 1950, Sardinia(Italy)", value: "+ellps_code=IN +towgs84=-97,-103,-120,0,0,0,0"),
    ListItem(code: "EUR-J", name: "EUROPEAN 1950, Sicily(Italy)", value: "+ellps_code=IN +towgs84=-97,-88,-135,0,0,0,0"),
    ListItem(code: "EUR-K", name: "EUROPEAN 1950, England, Ireland", value: "+ellps_code=IN +towgs84=-86,-96,-120,0,0,0,0"),
    ListItem(code: "EUR-L", name: "EUROPEAN 1950, Malta", value: "+ellps_code=IN +towgs84=-107,-88,-149,0,0,0,0"),
    ListItem(code: "EUR-S", name: "EUROPEAN 1950, Iraq, Israel", value: "+ellps_code=IN +towgs84=-103,-106,-141,0,0,0,0"),
    ListItem(code: "EUR-T", name: "EUROPEAN 1950, Tunisia", value: "+ellps_code=IN +towgs84=-112,-77,-145,0,0,0,0"),
    ListItem(code: "EUS", name: "EUROPEAN 1979", value: "+ellps_code=IN +towgs84=-86,-98,-119,0,0,0,0"),
    ListItem(code: "FAH", name: "OMAN", value: "+ellps_code=CD +towgs84=-345,3,223,0,0,0,0"),
    ListItem(code: "FJI", name: "FIJI 1956", value: "+ellps_code=IN +towgs84=265,385,-194,0,0,0,0"),
    ListItem(code: "FLO", name: "OBSERVATORIO MET. 1939, Flores", value: "+ellps_code=IN +towgs84=-425,-169,81,0,0,0,0"),
    ListItem(code: "FOT", name: "FORT THOMAS 1955, Leeward Is. ", value: "+ellps_code=CD +towgs84=-7,215,225,0,0,0,0"),
    ListItem(code: "GAA", name: "GAN 1970, Rep. of Maldives", value: "+ellps_code=IN +towgs84=-133,-321,50,0,0,0,0"),
    ListItem(code: "GAI", name: "GAMBIA, Gambia", value: "+ellps_code=CD +towgs84=-63,176,185,0,0,0,0"),
    ListItem(code: "GEO", name: "GEODETIC DATUM 1949, NZ", value: "+ellps_code=IN +towgs84=84,-22,209,0,0,0,0"),
    ListItem(code: "GIZ", name: "DOS 1968, Gizo Island", value: "+ellps_code=IN +towgs84=230,-199,-752,0,0,0,0"),
    ListItem(code: "GRA", name: "GRACIOSA BASE SW 1948, Azores ", value: "+ellps_code=IN +towgs84=-104,167,-38,0,0,0,0"),
    ListItem(code: "GUA", name: "GUAM 1963", value: "+ellps_code=CC +towgs84=-100,-248,259,0,0,0,0"),
    ListItem(code: "GSE", name: "GUNUNG SEGARA, Indonesia", value: "+ellps_code=BR +towgs84=-403,684,41,0,0,0,0"),
    ListItem(code: "HEN", name: "HERAT NORTH, Afghanistan", value: "+ellps_code=IN +towgs84=-333,-222,114,0,0,0,0"),
    ListItem(code: "HER", name: "HERMANNSKOGEL, old Yugoslavia ", value: "+ellps_code=BR +towgs84=682,-203,480,0,0,0,0"),
    ListItem(code: "HIT", name: "PROVISIONAL SOUTH CHILEAN 1963", value: "+ellps_code=IN +towgs84=16,196,93,0,0,0,0"),
    ListItem(code: "HJO", name: "HJORSEY 1955, Iceland", value: "+ellps_code=IN +towgs84=-73,47,-83,0,0,0,0"),
    ListItem(code: "HKD", name: "HONG KONG 1963", value: "+ellps_code=IN +towgs84=-156,-271,-189,0,0,0,0"),
    ListItem(code: "HTN", name: "HU-TZU-SHAN, Taiwan", value: "+ellps_code=IN +towgs84=-637,-549,-203,0,0,0,0"),
    ListItem(code: "IBE", name: "BELLEVUE (IGN), Efate Is.", value: "+ellps_code=IN +towgs84=-127,-769,472,0,0,0,0"),
    ListItem(code: "IDN", name: "INDONESIAN 1974", value: "+ellps_code=ID +towgs84=-24,-15,5,0,0,0,0"),
    ListItem(code: "IND-B", name: "INDIAN, Bangladesh", value: "+ellps_code=EA +towgs84=282,726,254,0,0,0,0"),
    ListItem(code: "IND-I", name: "INDIAN, India & Nepal", value: "+ellps_code=EC +towgs84=295,736,257,0,0,0,0"),
    ListItem(code: "IND-P", name: "INDIAN, Pakistan", value: "+ellps_code=EF +towgs84=283,682,231,0,0,0,0"),
    ListItem(code: "IND-S", name: "INDIAN, Sri Lanka", value: "+ellps_code=EA +towgs84=272,706,242,0,0,0,0"),
    ListItem(code: "INF-A", name: "INDIAN 1954, Thailand", value: "+ellps_code=EA +towgs84=217,823,299,0,0,0,0"),
    ListItem(code: "ING-A", name: "INDIAN 1960, Vietnam 16N", value: "+ellps_code=EA +towgs84=198,881,317,0,0,0,0"),
    ListItem(code: "ING-B", name: "INDIAN 1960, Con Son Island", value: "+ellps_code=EA +towgs84=182,915,344,0,0,0,0"),
    ListItem(code: "INH-A", name: "INDIAN 1975, Thailand", value: "+ellps_code=EA +towgs84=209,818,290,0,0,0,0"),
    ListItem(code: "INH-A1", name: "INDIAN 1975, Thailand", value: "+ellps_code=EA +towgs84=210,814,289,0,0,0,0"),
    ListItem(code: "IRL", name: "IRELAND 1965", value: "+ellps_code=AM +towgs84=506,-122,611,0,0,0,0"),
    ListItem(code: "ISG", name: "ISTS 061 ASTRO 1968, S Georgia", value: "+ellps_code=IN +towgs84=-794,119,-298,0,0,0,0"),
    ListItem(code: "IST", name: "ISTS 073 ASTRO 1969, Diego Garc", value: "+ellps_code=IN +towgs84=208,-435,-229,0,0,0,0"),
    ListItem(code: "JOH", name: "JOHNSTON ISLAND 1961", value: "+ellps_code=IN +towgs84=189,-79,-202,0,0,0,0"),
    ListItem(code: "KAN", name: "KANDAWALA, Sri Lanka", value: "+ellps_code=EA +towgs84=-97,787,86,0,0,0,0"),
    ListItem(code: "KEG", name: "KERGUELEN ISLAND 1949", value: "+ellps_code=IN +towgs84=145,-187,103,0,0,0,0"),
    ListItem(code: "KEA", name: "KERTAU 1948, W Malaysia & Sing.", value: "+ellps_code=EE +towgs84=-11,851,5,0,0,0,0"),
    ListItem(code: "KGS", name: "KOREAN GEO DATUM 1995, S Korea", value: "+ellps_code=WE +towgs84=0,0,0,0,0,0,0"),
    ListItem(code: "KUS", name: "KUSAIE ASTRO 1951, Caroline Is.", value: "+ellps_code=IN +towgs84=647,1777,-1124,0,0,0,0"),
    ListItem(code: "LCF", name: "L.C. 5 ASTRO 1961, Cayman Brac", value: "+ellps_code=CC +towgs84=42,124,147,0,0,0,0"),
    ListItem(code: "LEH", name: "LEIGON, Ghana", value: "+ellps_code=CD +towgs84=-130,29,364,0,0,0,0"),
    ListItem(code: "LIB", name: "LIBERIA 1964", value: "+ellps_code=CD +towgs84=-90,40,88,0,0,0,0"),
    ListItem(code: "LIS", name: "LISBON, Portugal", value: "+ellps_code=IN +towgs84=-306,-62,105,0,0,0,0"),
    ListItem(code: "LUZ-A", name: "LUZON, Philippines", value: "+ellps_code=CC +towgs84=-133,-77,-51,0,0,0,0"),
    ListItem(code: "LUZ-B", name: "LUZON, Mindanao Island", value: "+ellps_code=CC +towgs84=-133,-79,-72,0,0,0,0"),
    ListItem(code: "MAS", name: "MASSAWA, Ethiopia", value: "+ellps_code=BR +towgs84=639,405,60,0,0,0,0"),
    ListItem(code: "MCX", name: "MAYOTTE COMBANI, Comoros", value: "+ellps_code=IN +towgs84=-382,-59,-262,0,0,0,0"),
    ListItem(code: "MER", name: "MERCHICH, Morocco", value: "+ellps_code=CD +towgs84=31,146,47,0,0,0,0"),
    ListItem(code: "MID", name: "MIDWAY ASTRO 1961, Midway Is. ", value: "+ellps_code=IN +towgs84=403,-81,277,0,0,0,0"),
    ListItem(code: "MIK", name: "MAHE 1971, Mahe Is.", value: "+ellps_code=CD +towgs84=41,-220,-134,0,0,0,0"),
    ListItem(code: "MIN-A", name: "MINNA, Cameroon", value: "+ellps_code=CD +towgs84=-81,-84,115,0,0,0,0"),
    ListItem(code: "MIN-B", name: "MINNA, Nigeria", value: "+ellps_code=CD +towgs84=-92,-93,122,0,0,0,0"),
    ListItem(code: "MOD", name: "ROME 1940, Sardinia", value: "+ellps_code=IN +towgs84=-225,-65,9,0,0,0,0"),
    ListItem(code: "MPO", name: "M'PORALOKO, Gabon", value: "+ellps_code=CD +towgs84=-74,-130,42,0,0,0,0"),
    ListItem(code: "MVS", name: "VITI LEVU 1916, Viti Levu Is. ", value: "+ellps_code=CD +towgs84=98,390,-22,0,0,0,0"),
    ListItem(code: "NAH-A", name: "NAHRWAN, Masirah Island (Oman)", value: "+ellps_code=CD +towgs84=-247,-148,369,0,0,0,0"),
    ListItem(code: "NAH-B", name: "NAHRWAN, United Arab Emirates ", value: "+ellps_code=CD +towgs84=-249,-156,381,0,0,0,0"),
    ListItem(code: "NAH-C", name: "NAHRWAN, Saudi Arabia", value: "+ellps_code=CD +towgs84=-243,-192,477,0,0,0,0"),
    ListItem(code: "NAP", name: "NAPARIMA, Trinidad & Tobago", value: "+ellps_code=IN +towgs84=-10,375,165,0,0,0,0"),
    ListItem(code: "NAR-A", name: "NORTH AMERICAN 1983, Alaska", value: "+ellps_code=RF +towgs84=0,0,0,0,0,0,0"),
    ListItem(code: "NAR-B", name: "NORTH AMERICAN 1983, Canada", value: "+ellps_code=RF +towgs84=0,0,0,0,0,0,0"),
    ListItem(code: "NAR-C", name: "NORTH AMERICAN 1983, CONUS", value: "+ellps_code=RF +towgs84=0,0,0,0,0,0,0"),
    ListItem(code: "NAR-D", name: "NORTH AMERICAN 1983, Mexico", value: "+ellps_code=RF +towgs84=0,0,0,0,0,0,0"),
    ListItem(code: "NAR-E", name: "NORTH AMERICAN 1983, Aleutian ", value: "+ellps_code=RF +towgs84=-2,0,4,0,0,0,0"),
    ListItem(code: "NAR-H", name: "NORTH AMERICAN 1983, Hawaii", value: "+ellps_code=RF +towgs84=1,1,-1,0,0,0,0"),
    ListItem(code: "NAS-A", name: "NORTH AMERICAN 1927, Eastern US", value: "+ellps_code=CC +towgs84=-9,161,179,0,0,0,0"),
    ListItem(code: "NAS-B", name: "NORTH AMERICAN 1927, Western US", value: "+ellps_code=CC +towgs84=-8,159,175,0,0,0,0"),
    ListItem(code: "NAS-C", name: "NORTH AMERICAN 1927, CONUS", value: "+ellps_code=CC +towgs84=-8,160,176,0,0,0,0"),
    ListItem(code: "NAS-D", name: "NORTH AMERICAN 1927, Alaska", value: "+ellps_code=CC +towgs84=-5,135,172,0,0,0,0"),
    ListItem(code: "NAS-E", name: "NORTH AMERICAN 1927, Canada", value: "+ellps_code=CC +towgs84=-10,158,187,0,0,0,0"),
    ListItem(code: "NAS-F", name: "NORTH AMERICAN 1927, Alberta/BC", value: "+ellps_code=CC +towgs84=-7,162,188,0,0,0,0"),
    ListItem(code: "NAS-G", name: "NORTH AMERICAN 1927, E. Canada", value: "+ellps_code=CC +towgs84=-22,160,190,0,0,0,0"),
    ListItem(code: "NAS-H", name: "NORTH AMERICAN 1927, Man/Ont", value: "+ellps_code=CC +towgs84=-9,157,184,0,0,0,0"),
    ListItem(code: "NAS-I", name: "NORTH AMERICAN 1927, NW Terr. ", value: "+ellps_code=CC +towgs84=4,159,188,0,0,0,0"),
    ListItem(code: "NAS-J", name: "NORTH AMERICAN 1927, Yukon", value: "+ellps_code=CC +towgs84=-7,139,181,0,0,0,0"),
    ListItem(code: "NAS-L", name: "NORTH AMERICAN 1927, Mexico", value: "+ellps_code=CC +towgs84=-12,130,190,0,0,0,0"),
    ListItem(code: "NAS-N", name: "NORTH AMERICAN 1927, C. America", value: "+ellps_code=CC +towgs84=0,125,194,0,0,0,0"),
    ListItem(code: "NAS-O", name: "NORTH AMERICAN 1927, Canal Zone", value: "+ellps_code=CC +towgs84=0,125,201,0,0,0,0"),
    ListItem(code: "NAS-P", name: "NORTH AMERICAN 1927, Caribbean", value: "+ellps_code=CC +towgs84=-3,142,183,0,0,0,0"),
    ListItem(code: "NAS-Q", name: "NORTH AMERICAN 1927, Bahamas", value: "+ellps_code=CC +towgs84=-4,154,178,0,0,0,0"),
    ListItem(code: "NAS-R", name: "NORTH AMERICAN 1927, San Salv.", value: "+ellps_code=CC +towgs84=1,140,165,0,0,0,0"),
    ListItem(code: "NAS-T", name: "NORTH AMERICAN 1927, Cuba", value: "+ellps_code=CC +towgs84=-9,152,178,0,0,0,0"),
    ListItem(code: "NAS-U", name: "NORTH AMERICAN 1927, Greenland", value: "+ellps_code=CC +towgs84=11,114,195,0,0,0,0"),
    ListItem(code: "NAS-V", name: "NORTH AMERICAN 1927, Aleutian E", value: "+ellps_code=CC +towgs84=-2,152,149,0,0,0,0"),
    ListItem(code: "NAS-W", name: "NORTH AMERICAN 1927, Aleutian W", value: "+ellps_code=CC +towgs84=2,204,105,0,0,0,0"),
    ListItem(code: "NSD", name: "NORTH SAHARA 1959, Algeria", value: "+ellps_code=CD +towgs84=-186,-93,310,0,0,0,0"),
    ListItem(code: "NTF", name: "NEW TRIANGULATION OF FRANCE", value: "+ellps_code=CG +towgs84=-168,-60,320,0,0,0,0"),
    ListItem(code: "OCE", name: "OCOTEPEQUE, Costa Rica", value: "+ellps_code=CC +towgs84=205,96,-98,0,0,0,0"),
    ListItem(code: "OEG", name: "OLD EGYPTIAN 1907", value: "+ellps_code=HE +towgs84=-130,110,-13,0,0,0,0"),
    ListItem(code: "OGB-M", name: "ORDNANCE GB 1936, Mean (3 Para)", value: "+ellps_code=AA +towgs84=375,-111,431,0,0,0,0"),
    ListItem(code: "OGB-A", name: "ORDNANCE GB 1936, England", value: "+ellps_code=AA +towgs84=371,-112,434,0,0,0,0"),
    ListItem(code: "OGB-B", name: "ORDNANCE GB 1936, Eng., Wales ", value: "+ellps_code=AA +towgs84=371,-111,434,0,0,0,0"),
    ListItem(code: "OGB-C", name: "ORDNANCE GB 1936, Scotland", value: "+ellps_code=AA +towgs84=384,-111,425,0,0,0,0"),
    ListItem(code: "OGB-D", name: "ORDNANCE GB 1936, Wales", value: "+ellps_code=AA +towgs84=370,-108,434,0,0,0,0"),
    ListItem(code: "OHA-M", name: "OLD HAWAIIAN (CC), Mean", value: "+ellps_code=CC +towgs84=61,-285,-181,0,0,0,0"),
    ListItem(code: "OHA-A", name: "OLD HAWAIIAN (CC), Hawaii", value: "+ellps_code=CC +towgs84=89,-279,-183,0,0,0,0"),
    ListItem(code: "OHA-B", name: "OLD HAWAIIAN (CC), Kauai", value: "+ellps_code=CC +towgs84=45,-290,-172,0,0,0,0"),
    ListItem(code: "OHA-C", name: "OLD HAWAIIAN (CC), Maui", value: "+ellps_code=CC +towgs84=65,-290,-190,0,0,0,0"),
    ListItem(code: "OHA-D", name: "OLD HAWAIIAN (CC), Oahu", value: "+ellps_code=CC +towgs84=58,-283,-182,0,0,0,0"),
    ListItem(code: "OHI-M", name: "OLD HAWAIIAN (IN), Mean", value: "+ellps_code=IN +towgs84=201,-228,-346,0,0,0,0"),
    ListItem(code: "OHI-A", name: "OLD HAWAIIAN (IN), Hawaii", value: "+ellps_code=IN +towgs84=229,-222,-348,0,0,0,0"),
    ListItem(code: "OHI-B", name: "OLD HAWAIIAN (IN), Kauai", value: "+ellps_code=IN +towgs84=185,-233,-337,0,0,0,0"),
    ListItem(code: "OHI-C", name: "OLD HAWAIIAN (IN), Maui", value: "+ellps_code=IN +towgs84=205,-233,-355,0,0,0,0"),
    ListItem(code: "OHI-D", name: "OLD HAWAIIAN (IN), Oahu", value: "+ellps_code=IN +towgs84=198,-226,-347,0,0,0,0"),
    ListItem(code: "PED", name: "BEIJING (PEKING), China", value: "+ellps_code=KA +towgs84=-11,-113,-41,0,0,0,0"),
    ListItem(code: "PHA", name: "AYABELLE LIGHTHOUSE, Djibouti ", value: "+ellps_code=CD +towgs84=-77,-128,142,0,0,0,0"),
    ListItem(code: "PIT", name: "PITCAIRN ASTRO 1967", value: "+ellps_code=IN +towgs84=185,165,42,0,0,0,0"),
    ListItem(code: "PLN", name: "PICO DE LAS NIEVES, Canary Is.", value: "+ellps_code=IN +towgs84=-307,-92,127,0,0,0,0"),
    ListItem(code: "POS", name: "PORTO SANTO 1936, Madeira Is. ", value: "+ellps_code=IN +towgs84=-499,-249,314,0,0,0,0"),
    ListItem(code: "PRP-A", name: "PROV. S AMERICAN 1956, Bolivia", value: "+ellps_code=IN +towgs84=-270,188,-388,0,0,0,0"),
    ListItem(code: "PRP-B", name: "PROV. S AMERICAN 1956, N Chile", value: "+ellps_code=IN +towgs84=-270,183,-390,0,0,0,0"),
    ListItem(code: "PRP-C", name: "PROV. S AMERICAN 1956, S Chile", value: "+ellps_code=IN +towgs84=-305,243,-442,0,0,0,0"),
    ListItem(code: "PRP-D", name: "PROV. S AMERICAN 1956, Colombia", value: "+ellps_code=IN +towgs84=-282,169,-371,0,0,0,0"),
    ListItem(code: "PRP-E", name: "PROV. S AMERICAN 1956, Ecuador", value: "+ellps_code=IN +towgs84=-278,171,-367,0,0,0,0"),
    ListItem(code: "PRP-F", name: "PROV. S AMERICAN 1956, Guyana ", value: "+ellps_code=IN +towgs84=-298,159,-369,0,0,0,0"),
    ListItem(code: "PRP-G", name: "PROV. S AMERICAN 1956, Peru", value: "+ellps_code=IN +towgs84=-279,175,-379,0,0,0,0"),
    ListItem(code: "PRP-H", name: "PROV. S AMERICAN 1956, Venez", value: "+ellps_code=IN +towgs84=-295,173,-371,0,0,0,0"),
    ListItem(code: "PRP-M", name: "PROV. S AMERICAN 1956, Mean", value: "+ellps_code=IN +towgs84=-288,175,-376,0,0,0,0"),
    ListItem(code: "PTB", name: "POINT 58, Burkina Faso & Niger", value: "+ellps_code=CD +towgs84=-106,-129,165,0,0,0,0"),
    ListItem(code: "PTN", name: "POINT NOIRE 1948, Congo", value: "+ellps_code=CD +towgs84=-148,51,-291,0,0,0,0"),
    ListItem(code: "PUK", name: "PULKOVO 1942, Russia", value: "+ellps_code=KA +towgs84=28,-130,-95,0,0,0,0"),
    ListItem(code: "PUR", name: "PUERTO RICO & Virgin Is.", value: "+ellps_code=CC +towgs84=11,72,-101,0,0,0,0"),
    ListItem(code: "QAT", name: "QATAR NATIONAL", value: "+ellps_code=IN +towgs84=-128,-283,22,0,0,0,0"),
    ListItem(code: "QUO", name: "QORNOQ, South Greenland", value: "+ellps_code=IN +towgs84=164,138,-189,0,0,0,0"),
    ListItem(code: "REU", name: "REUNION, Mascarene Is.", value: "+ellps_code=IN +towgs84=94,-948,-1262,0,0,0,0"),
    ListItem(code: "SAE", name: "SANTO (DOS) 1965", value: "+ellps_code=IN +towgs84=170,42,84,0,0,0,0"),
    ListItem(code: "SAO", name: "SAO BRAZ, Santa Maria Is.", value: "+ellps_code=IN +towgs84=-203,141,53,0,0,0,0"),
    ListItem(code: "SAP", name: "SAPPER HILL 1943, E Falkland Is", value: "+ellps_code=IN +towgs84=-355,21,72,0,0,0,0"),
    ListItem(code: "SAN-M", name: "SOUTH AMERICAN 1969, Mean", value: "+ellps_code=SA +towgs84=-57,1,-41,0,0,0,0"),
    ListItem(code: "SAN-A", name: "SOUTH AMERICAN 1969, Argentina", value: "+ellps_code=SA +towgs84=-62,-1,-37,0,0,0,0"),
    ListItem(code: "SAN-B", name: "SOUTH AMERICAN 1969, Bolivia", value: "+ellps_code=SA +towgs84=-61,2,-48,0,0,0,0"),
    ListItem(code: "SAN-C", name: "SOUTH AMERICAN 1969, Brazil", value: "+ellps_code=SA +towgs84=-60,-2,-41,0,0,0,0"),
    ListItem(code: "SAN-D", name: "SOUTH AMERICAN 1969, Chile", value: "+ellps_code=SA +towgs84=-75,-1,-44,0,0,0,0"),
    ListItem(code: "SAN-E", name: "SOUTH AMERICAN 1969, Colombia ", value: "+ellps_code=SA +towgs84=-44,6,-36,0,0,0,0"),
    ListItem(code: "SAN-F", name: "SOUTH AMERICAN 1969, Ecuador", value: "+ellps_code=SA +towgs84=-48,3,-44,0,0,0,0"),
    ListItem(code: "SAN-G", name: "SOUTH AMERICAN 1969, Guyana", value: "+ellps_code=SA +towgs84=-53,3,-47,0,0,0,0"),
    ListItem(code: "SAN-H", name: "SOUTH AMERICAN 1969, Paraguay ", value: "+ellps_code=SA +towgs84=-61,2,-33,0,0,0,0"),
    ListItem(code: "SAN-I", name: "SOUTH AMERICAN 1969, Peru", value: "+ellps_code=SA +towgs84=-58,0,-44,0,0,0,0"),
    ListItem(code: "SAN-J", name: "SOUTH AMERICAN 1969, Baltra", value: "+ellps_code=SA +towgs84=-47,26,-42,0,0,0,0"),
    ListItem(code: "SAN-K", name: "SOUTH AMERICAN 1969, Trinidad ", value: "+ellps_code=SA +towgs84=-45,12,-33,0,0,0,0"),
    ListItem(code: "SAN-L", name: "SOUTH AMERICAN 1969, Venezuela", value: "+ellps_code=SA +towgs84=-45,8,-33,0,0,0,0"),
    ListItem(code: "SCK", name: "SCHWARZECK, Namibia", value: "+ellps_code=BN +towgs84=616,97,-251,0,0,0,0"),
    ListItem(code: "SEI", name: "SOUTH EAST ISLAND, Seychelles ", value: "+ellps_code=CD +towgs84=-44,-180,-268,0,0,0,0"),
    ListItem(code: "SGM", name: "SELVAGEM GRANDE 1938, Salvage Is", value: "+ellps_code=IN +towgs84=-289,-124,60,0,0,0,0"),
    ListItem(code: "SHB", name: "ASTRO DOS 71/4, St. Helena Is.", value: "+ellps_code=IN +towgs84=-320,550,-494,0,0,0,0"),
    ListItem(code: "SIR", name: "SIRGAS, South America", value: "+ellps_code=RF +towgs84=0,0,0,0,0,0,0"),
    ListItem(code: "SOA", name: "SOUTH ASIA, Singapore", value: "+ellps_code=FA +towgs84=7,-10,-26,0,0,0,0"),
    ListItem(code: "SPK-A", name: "S-42 (PULKOVO 1942), Hungary", value: "+ellps_code=KA +towgs84=28,-121,-77,0,0,0,0"),
    ListItem(code: "SPK-B", name: "S-42 (PULKOVO 1942), Poland", value: "+ellps_code=KA +towgs84=23,-124,-82,0,0,0,0"),
    ListItem(code: "SPK-C", name: "S-42 (PK42) Former Czechoslov.", value: "+ellps_code=KA +towgs84=26,-121,-78,0,0,0,0"),
    ListItem(code: "SPK-D", name: "S-42 (PULKOVO 1942), Latvia", value: "+ellps_code=KA +towgs84=24,-124,-82,0,0,0,0"),
    ListItem(code: "SPK-E", name: "S-42 (PK 1942), Kazakhstan", value: "+ellps_code=KA +towgs84=15,-130,-84,0,0,0,0"),
    ListItem(code: "SPK-F", name: "S-42 (PULKOVO 1942), Albania", value: "+ellps_code=KA +towgs84=24,-130,-92,0,0,0,0"),
    ListItem(code: "SPK-G", name: "S-42 (PULKOVO 1942), Romania", value: "+ellps_code=KA +towgs84=28,-121,-77,0,0,0,0"),
    ListItem(code: "SPK-H", name: "S-42 (PULKOVO 1942), Estonia", value: "+ellps_code=KA +towgs84=22,-126,-85,0,0,0,0"),
    ListItem(code: "SPX", name: "ST PIERRE et MIQUELON 1950", value: "+ellps_code=CC +towgs84=30,430,368,0,0,0,0"),
    ListItem(code: "SRL", name: "SIERRA LEONE 1960", value: "+ellps_code=CD +towgs84=-88,4,101,0,0,0,0"),
    ListItem(code: "TAN", name: "TANANARIVE OBSERVATORY 1925", value: "+ellps_code=IN +towgs84=-191,-232,-111,0,0,0,0"),
    ListItem(code: "TDC", name: "TRISTAN ASTRO 1968", value: "+ellps_code=IN +towgs84=-632,438,-609,0,0,0,0"),
    ListItem(code: "TEC", name: "TETE 1960, Mozambique", value: "+ellps_code=CC +towgs84=-80,-100,-228,0,0,0,0"),
    ListItem(code: "TIL", name: "TIMBALAI 1948, Brunei & E Malay", value: "+ellps_code=EB +towgs84=-679,669,-48,0,0,0,0"),
    ListItem(code: "TIN", name: "TIMBALAI 1968, Brunei", value: "+ellps_code=EB +towgs84=-679,667,-49,0,0,0,0"),
    ListItem(code: "TOY-A", name: "TOKYO, Japan", value: "+ellps_code=BR +towgs84=-148,507,685,0,0,0,0"),
    ListItem(code: "TOY-B", name: "TOKYO, South Korea", value: "+ellps_code=BR +towgs84=-146,507,687,0,0,0,0"),
    ListItem(code: "TOY-B1", name: "TOKYO, South Korea", value: "+ellps_code=BR +towgs84=-147,506,687,0,0,0,0"),
    ListItem(code: "TOY-C", name: "TOKYO, Okinawa", value: "+ellps_code=BR +towgs84=-158,507,676,0,0,0,0"),
    ListItem(code: "TOY-M", name: "TOKYO, Mean", value: "+ellps_code=BR +towgs84=-148,507,685,0,0,0,0"),
    ListItem(code: "TRN", name: "ASTRO TERN ISLAND (FRIG) 1961 ", value: "+ellps_code=IN +towgs84=114,-116,-333,0,0,0,0"),
    ListItem(code: "VOI", name: "VOIROL 1874, Algeria", value: "+ellps_code=CD +towgs84=-73,-247,227,0,0,0,0"),
    ListItem(code: "VOR", name: "VOIROL 1960, Algeria", value: "+ellps_code=CD +towgs84=-123,-206,219,0,0,0,0"),
    ListItem(code: "WAK", name: "WAKE ISLAND ASTRO 1952", value: "+ellps_code=IN +towgs84=276,-57,149,0,0,0,0"),
    ListItem(code: "YAC", name: "YACARE, Uruguay", value: "+ellps_code=IN +towgs84=-155,171,37,0,0,0,0"),
    ListItem(code: "ZAN", name: "ZANDERIJ, Suriname", value: "+ellps_code=IN +towgs84=-265,120,-358,0,0,0,0"),
    ListItem(code: "YOF", name: "YOF ASTRO 1967, Senegal", value: "+ellps_code=CD +towgs84=-30,190,89,0,0,0,0"),
    ListItem(code: "WGE", name: "WGS 84", value: "+ellps_code=WE +towgs84=0,0,0,0,0,0,0"),
    ListItem(code: "EUR-7", name: "EUROPEAN 1950, Mean (7 Parameters)", value: "+ellps_code=IN +towgs84=-102,-102,-129,0.413,-0.184,0.385,0.0000024664"),
    ListItem(code: "OGB-7", name: "ORDNANCE GB 1936, Mean (7 Parameters)", value: "+ellps_code=AA  +towgs84=446,-99,544,-0.945,-0.261,-0.435,-0.0000208927"),
    ListItem(code: "VN-2", name: "VN-2000, Vietnam (7 Parameters)", value: "+ellps_code=WE +towgs84=-191.90441429,-39.30318279,-111.45032835,-0.00928836,0.01975479,-0.00427372,0.00000025290628")
]

var DEVICE_WIDTH = ""

let publicDatabase = CKContainer.default().publicCloudDatabase

// HUD View (customizable by editing the code below)
let hudView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
let indicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
extension UIView {
    
    func showHUD(_ view: UIView) {
        hudView.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        hudView.backgroundColor = UIColor.black
        hudView.alpha = 0.5
        hudView.layer.cornerRadius = 5
        
        indicatorView.center = CGPoint(x: hudView.frame.size.width/2, y: hudView.frame.size.height/2)
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        hudView.addSubview(indicatorView)
        indicatorView.startAnimating()
        view.addSubview(hudView)
    }
    func hideHUD() {
        hudView.removeFromSuperview()
    }

    func startFlashing() {
        self.alpha = 1.0
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseInOut, .repeat, .autoreverse, .allowUserInteraction], animations: {() -> Void in
            self.alpha = 0.1
            if ENABLE_SOUND_EFFECT {
                SoundPlayer.play(file: "beep.mp3")
            }
        }, completion: {(_ finished: Bool) -> Void in
            // Do nothing
            if ENABLE_SOUND_EFFECT {
                SoundPlayer.play(file: "click.mp3")
            }
        })
    }
    
    func stopFlashing() {
        UIView.animate(withDuration: 0.12, delay: 0.0, options: [.curveEaseInOut, .beginFromCurrentState], animations: {() -> Void in
            self.alpha = 1.0
        }, completion: {(_ finished: Bool) -> Void in
            // Do nothing
        })
    }
}

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_GB")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter
    }()
    static let local: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
}

extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
    var local: String {
        return Formatter.local.string(from: self)
    }
}

extension String {
    subscript(i: Int) -> String {
        guard i >= 0 && i < count else { return "" }
        return String(self[index(startIndex, offsetBy: i)])
    }
//    subscript(range: Range<Int>) -> String {
//        let lowerIndex = index(startIndex, offsetBy: max(0,range.lowerBound), limitedBy: endIndex) ?? endIndex
//        return substring(with: lowerIndex..<(index(lowerIndex, offsetBy: range.upperBound - range.lowerBound, limitedBy: endIndex) ?? endIndex))
//    }
//    subscript(range: ClosedRange<Int>) -> String {
//        let lowerIndex = index(startIndex, offsetBy: max(0,range.lowerBound), limitedBy: endIndex) ?? endIndex
//        return substring(with: lowerIndex..<(index(lowerIndex, offsetBy: range.upperBound - range.lowerBound + 1, limitedBy: endIndex) ?? endIndex))
//    }
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: Data(utf8), options: [NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
    var floatValue: CGFloat {
        return CGFloat((self as NSString).doubleValue)
    }
}

class CButton : UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(_ frame: CGRect, _ title: String, _ view: UIView) {
        super.init(frame: frame)
        titleLabel?.numberOfLines = 2
        setTitle(title, for: UIControlState.normal)
        backgroundColor = UIColor(red: 142.0/255.0, green: 224.0/255.0, blue: 102.0/255.0, alpha: 0.90)
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
    }
    override func layoutSubviews() {
        layer.cornerRadius = frame.width / 2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 2
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel?.textAlignment = .center
        // Đặt chiều cao
        NSLayoutConstraint(item: self,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: self.frame.height).isActive = true
        // Đặt chiều rộng
        NSLayoutConstraint(item: self,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: self.frame.width).isActive = true
        // Căn chỉnh giữa
        NSLayoutConstraint(item: self,
                           attribute: .centerX,
                           relatedBy: .equal,
                           toItem: self.superview,
                           attribute: .centerX,
                           multiplier: 1.0,
                           constant: 0).isActive = true
        // Căn dưới
        NSLayoutConstraint(item: self,
                           attribute: .bottom,
                           relatedBy: .lessThanOrEqual,
                           toItem: self.superview,
                           attribute: .bottom,
                           multiplier: 1.0,
                           constant: -280).isActive = true

     super.layoutSubviews()
    }
//    override var isHighlighted: Bool {
//        didSet {
//            if (isHighlighted) {
//                self.imageView?.layer.borderColor = self.tintColor.cgColor
//                self.imageView?.layer.borderWidth = 1
//                self.imageView?.layer.cornerRadius = 5
//            } else {
//                self.imageView?.layer.borderColor = self.tintColor.cgColor
//                self.imageView?.layer.borderWidth = 0
//                self.imageView?.layer.cornerRadius = 5
//            }
//        }
//    }
}

extension UIAlertController {
    func show() {
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(self, animated: true, completion: nil)
    }
}

open class UIDistanceLabel: UILabel {
    open var distance: CLLocationDistance {
        get {
            return 0
        }
        set {
            if newValue > 1000.0 { //use km
                let formatted = String(format: "%.2f", (newValue/1000.0))
                self.text = "\(formatted)km"
            } else {
                let formatted = String(format: "%.0f", (newValue))
                self.text = "\(formatted)m"
            }
        }
    }
}

open class UIOutlinedLabel: UILabel {
    
    var outlineWidth: CGFloat = 1.5
    var outlineColor: UIColor = UIColor.white
    
    override open func drawText(in rect: CGRect) {
        
        let strokeTextAttributes = [
            NSAttributedStringKey.strokeColor : outlineColor,
            NSAttributedStringKey.strokeWidth : -1 * outlineWidth,
            ] as [NSAttributedStringKey : Any]
        
        self.attributedText = NSAttributedString(string: self.text ?? "", attributes: strokeTextAttributes)
        super.drawText(in: rect)
    }
}

extension UILabel {
    
    private struct AssociatedKeys {
        static var copyable = "copyable"
        static var longPressGestureRecognizer = "longPressGestureRecognizer"
    }
    
    @IBInspectable public var copyable: Bool {
        get {
            guard let number = objc_getAssociatedObject(self, &AssociatedKeys.copyable) as? NSNumber else {
                return true
            }
            
            return number.boolValue
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.copyable, NSNumber(value: newValue),
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            newValue ? enableCopying() : disableCopying()
        }
    }
    
    private var longPressGestureRecognizer: UILongPressGestureRecognizer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.longPressGestureRecognizer) as?
            UILongPressGestureRecognizer
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.longPressGestureRecognizer, newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private func enableCopying() {
        isUserInteractionEnabled = true
        
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(showCopyMenu))
        addGestureRecognizer(longPressGestureRecognizer!)
    }
    
    private func disableCopying() {
        isUserInteractionEnabled = false
        
        if let gestureRecognizer = longPressGestureRecognizer {
            removeGestureRecognizer(gestureRecognizer)
            longPressGestureRecognizer = nil
        }
    }
    
    @objc private func showCopyMenu() {
        let copyMenu = UIMenuController.shared
        
        guard !copyMenu.isMenuVisible else { return }
        
        becomeFirstResponder()
        
        copyMenu.setTargetRect(bounds, in: self)
        copyMenu.setMenuVisible(true, animated: true)
    }
    
    override open var canBecomeFirstResponder : Bool {
        return copyable
    }
    
    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        guard copyable else { return false }
        
        if action == #selector(copy(_:)) {
            return true
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
    
    override open func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
    }
    
}

extension CLLocation {
    func showMyLocationInfo() -> String {
        let info0 = NSLocalizedString("GPS Information", comment: "")
        let info1 = NSLocalizedString("Coordinates: ", comment: "")
        let info2 = NSLocalizedString("Altitude: ", comment: "")
        let info3 = NSLocalizedString("Horizontal Error: ±", comment: "")
        let info4 = NSLocalizedString("Vertical Error: ±", comment: "")
        let info5 = NSLocalizedString("Course: ", comment: "")
        let info6 = NSLocalizedString("Speed: ", comment: "")
        let txt = "\(info0)\n\(info1)\n\(coordinate.localCoordinate(true))\n\(info2)\(altitude.toString(1)) m\n\(info3)\(horizontalAccuracy.toString(1)) m\n\(info4)\(verticalAccuracy.toString(1)) m\n\(info5)\(course.courseUnit())\n\(info6)\(speed.speedUnit())"
        return txt
    }
}

extension GMSPath {
    func toNSArray(altitudes:[CGFloat]) -> NSArray {
        var alts = altitudes
        if altitudes.count == 0 {
            let arrays: NSMutableArray = NSMutableArray()
            for i in 0..<self.count() {
                arrays.add(self.coordinate(at: i).toNSArray(altitude: -9999.0))
            }
            return arrays
        } else if altitudes.count+1 == self.count() {
            alts.append(altitudes.first!)
        }
        let arrays: NSMutableArray = NSMutableArray()
        for i in 0..<self.count() {
            arrays.add(self.coordinate(at: i).toNSArray(altitude: alts[Int(i)]))
        }
        return arrays
    }
}

extension GMSCoordinateBounds {
    func fit(map: GMSMapView, padding: CGFloat) -> GMSCoordinateBounds {
        let northWest = CLLocationCoordinate2D(latitude: northEast.latitude, longitude: southWest.longitude)
        let pNW = map.projection.point(for: northWest)
        var pNE = map.projection.point(for: northEast)
        var pSW = map.projection.point(for: southWest)
        
        let len1 = pNE.x - pNW.x
        let len2 = pSW.y - pNW.y
        let factor = fabs(len1 - len2) / 2.0 + padding
        if len1 > len2 {
            pNE.y = pNE.y - factor
            pSW.y = pSW.y + factor
            let sw = map.projection.coordinate(for: pSW)
            let ne = map.projection.coordinate(for: pNE)
            return GMSCoordinateBounds(coordinate: sw, coordinate: ne)
        } else {
            pNE.x = pNE.x + factor
            pSW.x = pSW.x - factor
            let sw = map.projection.coordinate(for: pSW)
            let ne = map.projection.coordinate(for: pNE)
            return GMSCoordinateBounds(coordinate: sw, coordinate: ne)
        }
    }
}

extension Dictionary {
    var json: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
}

extension NSArray {
    func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self[1] as! CLLocationDegrees, longitude: self[0] as! CLLocationDegrees)
    }
    func toAltitude() -> CGFloat {
        guard self.count > 2 else {
            return -9999.0
        }
        return self[2] as! CGFloat
    }
    func toGMSPath(_ removeClosedVertex: Bool) -> GMSPath {
        let path: GMSMutablePath = GMSMutablePath()
        for array in self {
            let arr: NSArray = array as! NSArray
            path.add(CLLocationCoordinate2D(latitude: arr[1] as! CLLocationDegrees, longitude: arr[0] as! CLLocationDegrees))
        }
        if removeClosedVertex && path.count() > 3 {
            if path.coordinate(at: path.count()-1).distance(from: path.coordinate(at: 0)) == 0 {
                path.removeCoordinate(at: path.count()-1)
            }
        }
        return path
    }
    func toAltitudes(_ removeClosedVertex: Bool) -> [CGFloat] {
        var altitudes: [CGFloat] = [CGFloat]()
        for array in self {
            let arr: NSArray = array as! NSArray
            
            if arr.count > 2 {
                altitudes.append(arr[2] as! CGFloat)
            } else {
                altitudes.append(-9999.0)
            }
        }
        if removeClosedVertex {
            altitudes.removeLast()
        }
        return altitudes
    }
}

extension CLLocationCoordinate2D {
    /*
     * Tính chuyển từ (latitude, longitude, altitude) sang (northing, easting, elevation)
     */
    
    
    func targetCoordinates() -> [Double] {
        var easting: Double = 0;
        var northing: Double = 0;
        let grid = localCoordinate(false).components(separatedBy: ",")
        if grid.count >= 2 {
            if getMapGridFormat() == 0 { // EN
                easting = (grid[0] as NSString).doubleValue
                northing = (grid[1] as NSString).doubleValue
            } else {
                easting = (grid[1] as NSString).doubleValue
                northing = (grid[0] as NSString).doubleValue
            }
        }
        return [easting, northing]
    }
    
    /*
     * Định dạng tọa độ địa lý luôn dương dạng thập phân và có ký hiệu
     */
    func localizedCoordinateString() -> String {
        let latString = (latitude < 0) ? "S" : "N"
        let lonString = (longitude < 0) ? "W" : "E"
        return "\(fabs(latitude))\(latString)\n\(fabs(longitude))\(lonString)"
    }
    
    /*
     * Định dạng tọa độ địa lý luôn dương dạng độ phút giây và có ký hiệu
     */
    func localizedCoordinateString2() -> String {
        let latString = (latitude < 0) ? "S" : "N"
        let lonString = (longitude < 0) ? "W" : "E"
        return "\(fabs(latitude).toDMSString(0))\(latString)\n\(fabs(longitude).toDMSString(0))\(lonString)"
    }
    
    /*
     * Chuyển sang tọa độ đích theo chuỗi
     * Các kiểu định dạng tọa độ:
     * - britishNationalGrid (chuỗi 1 phần tử)
     * - geocentric, localCartesian (chuỗi 3 phần tử)
     * - globalAreaReferenceSystem (chuỗi 1 phần tử)
     * - georef (chuỗi 1 phần tử)
     * - militaryGridReferenceSystem, usNationalGrid (chuỗi 1 phần tử)
     * -
     */
    func localCoordinate(_ symbol: Bool) -> String {
        var txt: String? = String()
        let latString = (latitude < 0) ? "S" : "N"
        let lonString = (longitude < 0) ? "W" : "E"

        let lat = self.latitude*DEGREE_TO_RADIAN
        let lon = self.longitude*DEGREE_TO_RADIAN
        let alt: Double = 0.0
        
        var warningMessage: NSString? = NSString()
        var easting: Double = 0.0
        var northing: Double = 0.0
        var zone: Int = 0
        var hemi: NSString? = NSString()
        var mgrsOrUsngString: NSString? = NSString()
        var bngString: NSString? = NSString()
        var precision: Int = 0
        var georefString:NSString? = NSString()
        var garsString:NSString? = NSString()
        
        var cartesianX:Double = 0.0
        var cartesianY:Double = 0.0
        var cartesianZ:Double = 0.0
        
        // Kiểm tra thiết lập lưới chiếu hiện tại
        let coordinateType = getCoordinateType()
        let type: CoordinateType = CoordinateType(rawValue: coordinateType)!
        switch type {
        case CoordinateType.britishNationalGrid:
            geotrans?.getBNGCoordinates(forLat:lat, lng:lon, alt:alt, type:coordinateType, warningMessage:&warningMessage, bngString:&bngString, precision:&precision)
            if (warningMessage?.length)! > 0 {
                txt = NSLocalizedString((warningMessage! as String), comment: "")
            } else {
                txt = bngString! as String
            }
            break
        case CoordinateType.geocentric, CoordinateType.localCartesian:
            geotrans?.getCartesianCoordinates(forLat:lat, lng:lon, alt:alt, type:coordinateType, warningMessage:&warningMessage, x:&cartesianX, y:&cartesianY, z:&cartesianZ)
            if (warningMessage?.length)! > 0 {
                txt = NSLocalizedString((warningMessage! as String), comment: "")
            } else {
                if symbol {
                    txt = "\(fabs(cartesianX).toString(1)), \(fabs(cartesianY).toString(1)), \(fabs(cartesianZ).toString(1))"
                } else {
                    txt = "\(fabs(cartesianX).toString(1)), \(fabs(cartesianY).toString(1)), \(fabs(cartesianZ).toString(1))"
                }
            }
            break
        case CoordinateType.globalAreaReferenceSystem:
            geotrans?.getGARSCoordinates(forLat:lat, lng:lon, alt:alt, type:coordinateType, warningMessage:&warningMessage, garsString:&garsString, precision:&precision)
            if (warningMessage?.length)! > 0 {
                txt = NSLocalizedString((warningMessage! as String), comment: "")
            } else {
                txt = garsString! as String
            }
            break
        case CoordinateType.georef:
            geotrans?.getGEOREFCoordinates(forLat:lat, lng:lon, alt:alt, type:coordinateType, warningMessage:&warningMessage, georefString:&georefString, precision:&precision)
            if (warningMessage?.length)! > 0 {
                txt = NSLocalizedString((warningMessage! as String), comment: "")
            } else {
                txt = georefString! as String
            }
            break
        case CoordinateType.militaryGridReferenceSystem, CoordinateType.usNationalGrid:
            geotrans?.getMGRSorUSNGCoordinates(forLat:lat, lng:lon, alt:alt, type:coordinateType, warningMessage:&warningMessage, mgrsString:&mgrsOrUsngString, precision:&precision)
            if (warningMessage?.length)! > 0 {
                txt = NSLocalizedString((warningMessage! as String), comment: "")
            } else {
                txt = mgrsOrUsngString! as String
            }
            break
        case CoordinateType.universalPolarStereographic:
            geotrans?.getUPSCoordinates(forLat:lat, lng:lon, alt:alt, type:coordinateType, warningMessage:&warningMessage, hemisphere:&hemi, easting:&easting, northing:&northing)
            if (warningMessage?.length)! > 0 {
                txt = NSLocalizedString((warningMessage! as String), comment: "")
            } else {
                switch getMapGridFormat() {
                case 0: //"Easting, Northing"
                    if symbol {
                        txt = "\(hemi!): \(fabs(easting).toString(1))\(lonString), \(fabs(northing).toString(1))\(latString)"
                    } else {
                        txt = "\(hemi!): \(fabs(easting).toString(1)), \(fabs(northing).toString(1))"
                    }
                    break;
                case 1: //"Northing, Easting"
                    if symbol {
                        txt = "\(hemi!): \(fabs(northing).toString(1))\(latString), \(fabs(easting).toString(1))\(lonString)"
                    } else {
                        txt = "\(hemi!): \(fabs(northing).toString(1)), \(fabs(easting).toString(1))"
                    }
                    break;
                default:
                    
                    break;
                }
            }
            break
        case CoordinateType.universalTransverseMercator:
            geotrans?.getUTMCoordinates(forLat:lat, lng:lon, alt:alt, type:coordinateType, warningMessage:&warningMessage, zone:&zone, hemisphere:&hemi, easting:&easting, northing:&northing)
            if (warningMessage?.length)! > 0 {
                txt = NSLocalizedString((warningMessage! as String), comment: "")
            } else {
                switch getMapGridFormat() {
                case 0: //"Easting, Northing"
                    if symbol {
                        txt = "\(zone)\(hemi!): \(fabs(easting).toString(1))\(lonString), \(fabs(northing).toString(1))\(latString)"
                    } else {
                        txt = "\(zone) \(hemi!): \(fabs(easting).toString(1)), \(fabs(northing).toString(1))"
                    }
                    break;
                case 1: //"Northing, Easting"
                    if symbol {
                        txt = "\(zone)\(hemi!): \(fabs(northing).toString(1))\(latString), \(fabs(easting).toString(1))\(lonString)"
                    } else {
                        txt = "\(zone) \(hemi!): \(fabs(northing).toString(1)), \(fabs(easting).toString(1))"
                    }
                    break;
                default:
                    
                    break;
                }
            }
            break
        case CoordinateType.albersEqualAreaConic,
             CoordinateType.azimuthalEquidistant,
             CoordinateType.bonne,
             CoordinateType.cassini,
             CoordinateType.cylindricalEqualArea,
             CoordinateType.eckert4,
             CoordinateType.eckert6,
             CoordinateType.equidistantCylindrical,
             CoordinateType.gnomonic,
             CoordinateType.lambertConformalConic1Parallel,
             CoordinateType.lambertConformalConic2Parallels,
             CoordinateType.mercatorScaleFactor,
             CoordinateType.mercatorStandardParallel,
             CoordinateType.millerCylindrical,
             CoordinateType.mollweide,
             CoordinateType.neys,
             CoordinateType.newZealandMapGrid,
             CoordinateType.obliqueMercator,
             CoordinateType.orthographic,
             CoordinateType.polyconic,
             CoordinateType.polarStereographicScaleFactor,
             CoordinateType.polarStereographicStandardParallel,
             CoordinateType.sinusoidal,
             CoordinateType.stereographic,
             CoordinateType.transverseMercator,
             CoordinateType.transverseCylindricalEqualArea,
             CoordinateType.vanDerGrinten,
             CoordinateType.webMercator:
            
            // Tính chuyển tọa độ
            geotrans?.getMapProjectionCoordinates(forLat:lat, lng:lon, alt:alt, type:coordinateType, warningMessage:&warningMessage, easting: &easting, northing: &northing);
            
            // Nếu lỗi thì thay tọa độ bằng warningMessage
            if (warningMessage?.length)! > 0 {
                txt = NSLocalizedString((warningMessage! as String), comment: "")
            } else {
                switch getMapGridFormat() {
                case 0: //"Easting, Northing"
                    if symbol {
                        txt = "\(fabs(easting).toString(1))\(lonString), \(fabs(northing).toString(1))\(latString)"
                    } else {
                        txt = "\(fabs(easting).toString(1)), \(fabs(northing).toString(1))"
                    }
                    break;
                case 1: //"Northing, Easting"
                    if symbol {
                        txt = "\(fabs(northing).toString(1))\(latString), \(fabs(easting).toString(1))\(lonString)"
                    } else {
                        txt = "\(fabs(northing).toString(1)), \(fabs(easting).toString(1))"
                    }
                    break;
                default:
                    
                    break;
                }
            }
            break
        default:
            break
        }
        return txt!
    }
    
    func getMLSFormated(_ symbol: Bool) -> String {
        if myAltitude != 0 {
            if symbol {
                return ", \(fabs(myAltitude).toString(1))\("MLS")"
            } else {
                return ", \(fabs(myAltitude).toString(1))"
            }
        } else {
            return ""
        }
    }
    
    func latLngFormated(withTarget: Bool) -> String {
        var txt1: String = ""
        var txt2: String = ""
        
        switch getLatLngFormat() {
        case 0:
            let latString = (latitude < 0) ? "S" : "N"
            let lonString = (longitude < 0) ? "W" : "E"
            txt1 = "\(fabs(latitude).toDMSString(3))\(latString), \(fabs(longitude).toDMSString(3))\(lonString)"
        case 1:
            let latString = (latitude < 0) ? "S" : "N"
            let lonString = (longitude < 0) ? "W" : "E"
            txt1 = "\(fabs(latitude).toString(8))\(latString), \(fabs(longitude).toString(8))\(lonString)"
        case 2:
            let latString = (latitude < 0) ? "-" : "+"
            let lonString = (longitude < 0) ? "-" : "+"
            txt1 = "\(latString)\(fabs(latitude).toDMSString(3)), \(lonString)\(fabs(longitude).toDMSString(3))"
        case 3:
            let latString = (latitude < 0) ? "-" : "+"
            let lonString = (longitude < 0) ? "-" : "+"
            txt1 = "\(latString)\(fabs(latitude).toString(8)), \(lonString)\(fabs(longitude).toString(8))"
        default:
            break
        }
        if withTarget {
            txt2 = self.localCoordinate(true)
        }
        
        if txt2.length > 0 {
            return "\(txt1)\n\(txt2)"
        }
        return "\(txt1)"
    }
    
    func middleLocationWith(location:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        
        let lon1 = longitude * .pi / 180
        let lon2 = location.longitude * .pi / 180
        let lat1 = latitude * .pi / 180
        let lat2 = location.latitude * .pi / 180
        let dLon = lon2 - lon1
        let x = cos(lat2) * cos(dLon)
        let y = cos(lat2) * sin(dLon)
        
        let lat3 = atan2( sin(lat1) + sin(lat2), sqrt((cos(lat1) + x) * (cos(lat1) + x) + y * y) )
        let lon3 = lon1 + atan2(y, cos(lat1) + x)
        
        let center:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat3 * 180 / .pi, lon3 * 180 / .pi)
        return center
    }
    
    func toNSArray(altitude: CGFloat) -> NSArray {
        if altitude == -9999.0 {
            return NSArray(array: [longitude, latitude])
        } else {
            return NSArray(array: [longitude, latitude, altitude])
        }
    }
}

extension CMAcceleration {
    func getDeviceOrientation() -> CLDeviceOrientation {
        let epsilon = 0.5
        if (self.x <= -epsilon)  {       // Xup
            return .landscapeLeft
        } else if (self.x >= epsilon) {  // Xdown
            return .landscapeRight
        } else if (self.y <= -epsilon) { // Yup
            return .portrait
        } else if (self.y >= epsilon) {  // Ydown
            return .portraitUpsideDown
        } else if (self.z <= -epsilon) { // Zup
            return .faceUp
        } else if (self.z >= epsilon) {  // Zdown
            return .faceDown
        }
        return .unknown
    }
}

extension UIViewController {
    /// Executes the specified closure for each of the child and descendant view
    /// controller, as well as for the view controller itself.
    func enumerateHierarchy(_ closure: (UIViewController) -> Void) {
        closure(self)
        
        for child in childViewControllers {
            child.enumerateHierarchy(closure)
        }
        
    }
}

// ERROR ALERT
var error = NSError(domain: APP_NAME, code: 1, userInfo: nil)

class NetworkActivityIndicatorManager: NSObject {
    
    private static var loadingCount = 0
    
    class func networkOperationStarted() {
        
        #if os(iOS)
            if loadingCount == 0 {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
            loadingCount += 1
        #endif
    }
    
    class func networkOperationFinished() {
        #if os(iOS)
            if loadingCount > 0 {
                loadingCount -= 1
            }
            if loadingCount == 0 {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        #endif
    }
}

/**
 * Accelerometer data with compensation *
 * parameters:
 * - b is bias of accelerometer
 * - m is inverse of m matrix (scale and non-orthogonalities)
 */
extension CMAccelerometerData {
    @objc func valueWithCompensation(b: double3, m: double3x3) -> double3 {
        var a: double3 = [self.acceleration.y, self.acceleration.x, -self.acceleration.z] * 9.80665
        a = (a - b)*m
        return a
    }
}

extension CMGyroData {
    @objc func valueWithCompensation(b: double3, m: double3x3) -> double3 {
        var a: double3 = [self.rotationRate.y, self.rotationRate.x, -self.rotationRate.z]
        a = (a - b)*m
        return a
    }
}

extension CMMagnetometerData {
    @objc func valueWithCompensation(b: double3, m: double3x3) -> double3 {
        var a: double3 = [self.magneticField.y, self.magneticField.x, -self.magneticField.z]
        a = (a - b)*m
        return a
    }
}
