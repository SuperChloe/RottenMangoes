//
//  MapViewController.m
//  Rotten Mangoes
//
//  Created by Chloe on 2016-02-02.
//  Copyright © 2016 Chloe Horgan. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>

@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSString *postalCode;
@property (strong, nonatomic) NSMutableArray *theatreArray;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *userLocation = [locations lastObject];
    self.mapView.region = MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.02, 0.02));
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:userLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        self.postalCode = placemarks[0].postalCode;
    }];
}

#pragma mark - Helper methods

- (void)loadData {
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSString *urlString = [NSString stringWithFormat:@"http://lighthouse-movie-showtimes.herokuapp.com/theatres.json?address=%@&movie=%@", self.postalCode, self.movie.movieName];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            NSError *jsonParsingError;
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            if (!jsonParsingError) {
                
                for (NSDictionary *theatreDictionary in jsonData[@"theatres"]) {
                    Theatre *theatre = [[Theatre alloc] init];
                    theatre.name = theatreDictionary[@"name"];
                    theatre.address = theatreDictionary[@"address"];
                    theatre.coordinate = CLLocationCoordinate2DMake([theatreDictionary[@"lat"] doubleValue], [theatreDictionary[@"lng"] doubleValue]);
                    
                    [self.theatreArray addObject:theatre];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Do something
                });
            }
        }
    }];
    [dataTask resume];
    
}

@end
