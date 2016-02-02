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
@property (strong, nonatomic) CLLocation *userLocation;
@property (strong, nonatomic) NSString *postalCode;
@property (strong, nonatomic) NSMutableArray *theatreArray;
@property (assign, nonatomic) BOOL initialLocationSet;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.theatreArray = [[NSMutableArray alloc] init];
    self.initialLocationSet = NO;
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
    if (!self.initialLocationSet) {
        self.initialLocationSet = YES;
    
    
    self.userLocation = [locations lastObject];
    self.mapView.region = MKCoordinateRegionMake(self.userLocation.coordinate, MKCoordinateSpanMake(0.01, 0.01));
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:self.userLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        self.postalCode = placemarks[0].postalCode;
        [self loadData];
    }];
    }
}

#pragma mark - Helper methods

- (void)loadData {
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSString *urlString = [NSString stringWithFormat:@"http://lighthouse-movie-showtimes.herokuapp.com/theatres.json?address=%@&movie=%@", [self.postalCode stringByReplacingOccurrencesOfString:@" " withString:@"%20"], [self.movie.movieName stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            NSError *jsonParsingError;
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            if (!jsonParsingError) {
                
            dispatch_async(dispatch_get_main_queue(), ^{
                for (NSDictionary *theatreDictionary in jsonData[@"theatres"]) {
                    Theatre *theatre = [[Theatre alloc] init];
                    theatre.name = theatreDictionary[@"name"];
                    theatre.address = theatreDictionary[@"address"];
                    theatre.coordinate = CLLocationCoordinate2DMake([theatreDictionary[@"lat"] doubleValue], [theatreDictionary[@"lng"] doubleValue]);
                    
                    NSLog(@"%f, %f", theatre.coordinate.latitude, theatre.coordinate.longitude);
                    
                    MKPointAnnotation *marker = [[MKPointAnnotation alloc] init];
                    marker.coordinate = theatre.coordinate;
                    marker.title = theatre.name;
                    
                    [self.mapView addAnnotation:marker];
                    
                    
                    
                }
                });
            }
        }
    }];
    [dataTask resume];
}

@end
