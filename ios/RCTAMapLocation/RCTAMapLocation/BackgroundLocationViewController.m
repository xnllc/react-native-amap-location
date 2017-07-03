//
//  BackgroundLocationViewController.m
//  AMapLocationKit
//
//  Created by liubo on 8/4/16.
//  Copyright © 2016 AutoNavi. All rights reserved.
//

#import "BackgroundLocationViewController.h"
#import "AFHTTPSessionManager.h"

@interface BackgroundLocationViewController ()< AMapLocationManagerDelegate>
{
    
    CLLocation *mylocation;
    
}

@property (nonatomic, strong) UISegmentedControl *showSegment;
@property (nonatomic, strong) UISegmentedControl *backgroundSegment;


@end

@implementation BackgroundLocationViewController

#pragma mark - Action Handle

int i = 0;

- (void)configLocationManager
{
    self.locationManager = [[AMapLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    
    //设置不允许系统暂停定位
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    
    //设置允许在后台定位
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    
    //设置允许连续定位逆地理
    [self.locationManager setLocatingWithReGeocode:YES];
}

- (void)showsSegmentAction:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 1)
    {
        //停止定位
        [self.locationManager stopUpdatingLocation];
        
    }
    else
    {
        //开始进行连续定位
        [self.locationManager startUpdatingLocation];
    }
}

- (void)backgroundSegmentAction:(UISegmentedControl *)sender
{
    [self.locationManager stopUpdatingLocation];
    
    _showSegment.selectedSegmentIndex = 1;
    
    if (sender.selectedSegmentIndex == 1)
    {
        //设置允许系统暂停定位
        [self.locationManager setPausesLocationUpdatesAutomatically:YES];
        
        //设置禁止在后台定位
        [self.locationManager setAllowsBackgroundLocationUpdates:NO];
    }
    else
    {
        //为了方便演示后台定位功能，这里设置不允许系统暂停定位
        [self.locationManager setPausesLocationUpdatesAutomatically:NO];
        
        //设置允许在后台定位
        [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    }
}


-(void)delayMethod
{
    [self performSelector:@selector(delayMethod) withObject:nil afterDelay:10.0f];
    [self posttest2222:mylocation];
}


- (void)posttest2222:(CLLocation *)location
{
    
    
    NSLog(@"请求次数:%d",i++);
    

    
    NSString *strurl = @"https://httpbin.org/post";
    strurl =@"http://saleapi.qipeilong.net/User/CollectSalesLocation?";
    
    NSString *longitude = [NSString stringWithFormat:@"%f",location.coordinate.longitude];
    NSString *latitude = [NSString stringWithFormat:@"%f",location.coordinate.latitude];
    
    
    //创建词典对象，初始化长度为10
    NSMutableDictionary *dicp = [NSMutableDictionary dictionaryWithCapacity:6];

    dicp[@"longitude"] = longitude;
    dicp[@"latitude"] = latitude;
    dicp[@"ver"] = @"1.0";
    dicp[@"userId"] = @"1c03ec4c481c40f88682bbcdc902ddd5";
    dicp[@"TTTTT"] = @"TEST";
    
    NSLog(@"dic%@",dicp);

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    
    [manager POST:strurl parameters:dicp progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"post 成功%@",responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failure");
    }];
    
}


#pragma mark - AMapLocationManager Delegate

- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%s, amapLocationManager = %@, error = %@", __func__, [manager class], error);
}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode
{
    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f; reGeocode:%@}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy, reGeocode.formattedAddress);
    
    
    mylocation = location;
    

}

#pragma mark - Initialization



- (void)initToolBar
{
    UIBarButtonItem *flexble = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                             target:nil
                                                                             action:nil];
    
    self.showSegment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"开始定位", @"停止定位", nil]];
    [self.showSegment addTarget:self action:@selector(showsSegmentAction:) forControlEvents:UIControlEventValueChanged];
    self.showSegment.selectedSegmentIndex = 0;
    UIBarButtonItem *showItem = [[UIBarButtonItem alloc] initWithCustomView:self.showSegment];
    
    self.backgroundSegment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"开启后台", @"禁止后台", nil]];
    [self.backgroundSegment addTarget:self action:@selector(backgroundSegmentAction:) forControlEvents:UIControlEventValueChanged];
    self.backgroundSegment.selectedSegmentIndex = 0;
    UIBarButtonItem *bgItem = [[UIBarButtonItem alloc] initWithCustomView:self.backgroundSegment];
    
    self.toolbarItems = [NSArray arrayWithObjects:flexble, showItem, flexble, bgItem, flexble, nil];
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self initToolBar];
    
    
    
    [self configLocationManager];
    
    [self delayMethod];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.toolbar.translucent   = YES;
    self.navigationController.toolbarHidden         = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.locationManager startUpdatingLocation];
}



@end
