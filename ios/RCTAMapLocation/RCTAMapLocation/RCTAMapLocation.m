
#define DefaultLocationTimeout 20
#define DefaultReGeocodeTimeout 5

#import "RCTAMapLocation.h"
#import "RCTUtils.h"
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>

#import "AFHTTPSessionManager.h"
//#import "BackgroundLocationViewController.h"


@interface RCTAMapLocation() <AMapLocationManagerDelegate>
{
    
    CLLocation *mylocation;

    
    BOOL isSend;
    NSString *apihttp;  // 请求链接
    NSString *userId;   // 用户id
    float tspace;       // 时间间隔
    
    
}


@property (nonatomic, strong) AMapLocationManager *locationManager;

@property (nonatomic, copy) AMapLocatingCompletionBlock completionBlock;

@end

@implementation RCTAMapLocation

int i = 0;


@synthesize bridge = _bridge;

RCT_EXPORT_MODULE(AMapLocation);



//RCT_EXPORT_METHOD(showSKFCamera)
//{
//    
//    [self pushCameraclick];
//}
//
//- (void)pushCameraclick{
// 
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        UIViewController *root = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
//        while (root.presentedViewController != nil) {
//            root = root.presentedViewController;
//        }
//        
//        /* On iPad, UIAlertController presents a popover view rather than an action sheet like on iPhone. We must provide the location
//         of the location to show the popover in this case. For simplicity, we'll just display it on the bottom center of the screen
//         to mimic an action sheet */
//        BackgroundLocationViewController *homec = [[BackgroundLocationViewController alloc] init];
//        
//        
//        [root presentViewController:homec
//                           animated:NO
//                         completion:^{
//                         }];
//    });
//    
//    
//    
//}



RCT_EXPORT_METHOD(init2:(NSDictionary *)options)
{
    

    
    dispatch_async(dispatch_get_main_queue(), ^{
        

        [self configLocationManager];
        
        [self setOptions:options];
        
        [self delayMethod];
       
    });
    
    
    
}

- (void)configLocationManager
{
    if(self.locationManager != nil) {
        return;
    }
    
    isSend = YES;
    self.locationManager = [[AMapLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    
    //开始进行连续定位
    [self.locationManager startUpdatingLocation];
}



RCT_EXPORT_METHOD(init:(NSDictionary *)options)
{
    if(self.locationManager != nil) {
        return;
    }
    
    self.locationManager = [[AMapLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    
    [self setOptions:options];
    [self delayMethod];
    
    
    
    self.completionBlock = ^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error)
    {
        NSDictionary *resultDic;
        if (error)
        {
            resultDic = [self setErrorResult:error];
        }
        else {
            resultDic = [self setSuccessResult:location regeocode:regeocode];
        }
        [self.bridge.eventDispatcher sendAppEventWithName:@"amap.location.onLocationResult"
                                                     body:resultDic];
    };
}




-(void)delayMethod
{
    [self performSelector:@selector(delayMethod) withObject:nil afterDelay:tspace];
    [self posttest2222];
}


RCT_EXPORT_METHOD(setOptions:(NSDictionary *)options)
{
    CLLocationAccuracy locationMode = kCLLocationAccuracyHundredMeters;
    BOOL pausesLocationUpdatesAutomatically = YES;
    BOOL allowsBackgroundLocationUpdates = YES; // 修改后台默认定位
    int locationTimeout = DefaultLocationTimeout;
    int reGeocodeTimeout = DefaultReGeocodeTimeout;
    
    apihttp = @"http://saleapi.qipeilong.net/User/CollectSalesLocation?";
    userId = @"1c03ec4c481c40f88682bbcdc902ddd5";
    tspace = 30.0f;
    
    if(options != nil) {
        
        NSArray *keys = [options allKeys];
        
        if([keys containsObject:@"locationMode"]) {
            locationMode = [[options objectForKey:@"locationMode"] doubleValue];
        }
        
        if([keys containsObject:@"pausesLocationUpdatesAutomatically"]) {
            pausesLocationUpdatesAutomatically = [[options objectForKey:@"pausesLocationUpdatesAutomatically"] boolValue];
        }
        
        if([keys containsObject:@"allowsBackgroundLocationUpdates"]) {
            allowsBackgroundLocationUpdates = [[options objectForKey:@"allowsBackgroundLocationUpdates"] boolValue];
        }
        
        
        if([keys containsObject:@"locationTimeout"]) {
            locationTimeout = [[options objectForKey:@"locationTimeout"] intValue];
        }
        
        if([keys containsObject:@"reGeocodeTimeout"]) {
            reGeocodeTimeout = [[options objectForKey:@"reGeocodeTimeout"] intValue];
        }
        
        if([keys containsObject:@"apihttp"]) {
            apihttp = [options objectForKey:@"apihttp"];
        }
        if([keys containsObject:@"userId"]) {
            userId = [options objectForKey:@"userId"];
        }
        if([keys containsObject:@"tspace"]) {
            tspace = [[options objectForKey:@"tspace"] floatValue];
        }
    }
    
    //设置期望定位精度
    [self.locationManager setDesiredAccuracy:locationMode];
    
    //设置是否允许系统暂停定位
    [self.locationManager setPausesLocationUpdatesAutomatically:pausesLocationUpdatesAutomatically];
    
    //设置是否允许在后台定位
    [self.locationManager setAllowsBackgroundLocationUpdates:allowsBackgroundLocationUpdates];
    
    //设置定位超时时间
    [self.locationManager setLocationTimeout:locationTimeout];
    
    //设置逆地理超时时间
    [self.locationManager setReGeocodeTimeout:reGeocodeTimeout];

}

RCT_EXPORT_METHOD(cleanUp)
{
    //停止定位
    [self.locationManager stopUpdatingLocation];
    
    [self.locationManager setDelegate:nil];
    
    self.locationManager = nil;
    
    isSend = NO;
    

}



RCT_EXPORT_METHOD(getReGeocode)
{
    //进行单次带逆地理定位请求
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:self.completionBlock];
}

RCT_EXPORT_METHOD(getLocation)
{
    //进行单次定位请求
    [self.locationManager requestLocationWithReGeocode:NO completionBlock:self.completionBlock];
}

RCT_EXPORT_METHOD(startUpdatingLocation)
{
    //开始进行连续定位
    [self.locationManager startUpdatingLocation];
}

RCT_EXPORT_METHOD(stopUpdatingLocation)
{
    //停止连续定位
    [self.locationManager stopUpdatingLocation];

}



- (void)posttest2222
{
    
    
    if(!isSend) return;

    NSLog(@"请求次数:%d",i++);
    
    NSString *strurl = @"https://httpbin.org/post";
    strurl =@"http://saleapi.qipeilong.net/User/CollectSalesLocation?";
    strurl = apihttp;
    
    NSString *longitude = [NSString stringWithFormat:@"%f",mylocation.coordinate.longitude];
    NSString *latitude = [NSString stringWithFormat:@"%f",mylocation.coordinate.latitude];
    
    
    //创建词典对象，初始化长度为10
    NSMutableDictionary *dicp = [NSMutableDictionary dictionaryWithCapacity:6];
    
    dicp[@"longitude"] = longitude;
    dicp[@"latitude"] = latitude;
    dicp[@"ver"] = @"1.0";
    dicp[@"userId"] = userId;
    dicp[@"TTTTT"] = @"TEST-ios";
    
    NSLog(@"strurl:%@,dic%@",strurl,dicp);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    
    [manager POST:strurl parameters:dicp progress:^(NSProgress *  uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask *  task, id   responseObject) {
        NSLog(@"post 成功%@",responseObject);
        
    } failure:^(NSURLSessionDataTask *  task, NSError *  error) {
        NSLog(@"failure");
    }];
    
}



- (void)dealloc
{
    [self cleanUp];
}

- (NSDictionary*)setErrorResult:(NSError *)error
{
    NSDictionary *resultDic;
    
    resultDic = @{
                  @"error": @{
                          @"code": @(error.code),
                          @"localizedDescription": error.localizedDescription
                          }
                  };
    return resultDic;
}

- (NSDictionary*)setSuccessResult:(CLLocation *)location regeocode:(AMapLocationReGeocode *)regeocode
{
    NSDictionary *resultDic;
    
    //得到定位信息
    if (location)
    {
        if(regeocode) {
            resultDic = @{
                          @"horizontalAccuracy": @(location.horizontalAccuracy),
                          @"verticalAccuracy": @(location.verticalAccuracy),
                          @"coordinate": @{
                                  @"latitude": @(location.coordinate.latitude),
                                  @"longitude": @(location.coordinate.longitude),
                                  },
                          @"formattedAddress": regeocode.formattedAddress,
                          @"country": regeocode.country,
                          @"province": regeocode.province,
                          @"city": regeocode.city,
                          @"district": regeocode.district,
                          @"citycode": regeocode.citycode,
                          @"adcode": regeocode.adcode,
                          @"street": regeocode.street,
                          @"number": regeocode.number,
                          @"POIName": regeocode.POIName,
                          @"AOIName": regeocode.AOIName
                          };
        }
        else {
            resultDic = @{
                          @"horizontalAccuracy": @(location.horizontalAccuracy),
                          @"verticalAccuracy": @(location.verticalAccuracy),
                          @"coordinate": @{
                                  @"latitude": @(location.coordinate.latitude),
                                  @"longitude": @(location.coordinate.longitude),
                                  }
                          };
            
        }
    }
    else {
        resultDic = @{
                      @"error": @{
                              @"code": @(-1),
                              @"localizedDescription": @"定位结果不存在"
                              }
                      };
    }
    return resultDic;
}

#pragma mark - AMapLocationManager Delegate

- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error
{
//    NSLog(@"%s, amapLocationManager = %@, error = %@", __func__, [manager class], error);
    NSDictionary *resultDic;
    
    resultDic = [self setErrorResult:error];
    
    [self.bridge.eventDispatcher sendAppEventWithName:@"amap.location.onLocationResult"
                                                 body:resultDic];
}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)regeocode
{
//    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f; regeocode:%@}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy, regeocode.formattedAddress);
    
        mylocation = location;
    
    NSDictionary *resultDic;
    
    resultDic = [self setSuccessResult:location regeocode:regeocode];
    
    [self.bridge.eventDispatcher sendAppEventWithName:@"amap.location.onLocationResult"
                                                 body:resultDic];

}


- (NSDictionary *)constantsToExport
{
    return @{
             @"locationMode": @{
                     @"bestForNavigation": @(kCLLocationAccuracyBestForNavigation),
                     @"best": @(kCLLocationAccuracyBest),
                     @"nearestTenMeters": @(kCLLocationAccuracyNearestTenMeters),
                     @"hundredMeters": @(kCLLocationAccuracyHundredMeters),
                     @"kilometer":  @(kCLLocationAccuracyKilometer),
                     @"threeKilometers": @(kCLLocationAccuracyThreeKilometers)
                     }
             };
}


@end
