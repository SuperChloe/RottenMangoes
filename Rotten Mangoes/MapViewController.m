//
//  MapViewController.m
//  Rotten Mangoes
//
//  Created by Chloe on 2016-02-02.
//  Copyright © 2016 Chloe Horgan. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "TheatreCell.h"

@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *userLocation;
@property (strong, nonatomic) NSString *postalCode;
@property (assign, nonatomic) BOOL initialLocationSet;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initialLocationSet = NO;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    self.textField.delegate = self;
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mapView.annotations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TheatreCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Theatre *theatre = self.mapView.annotations[indexPath.row];
    cell.titleLabel.text = theatre.title;
    cell.addressLabel.text = theatre.subtitle;
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:theatre.coordinate.latitude longitude:theatre.coordinate.longitude];
    CLLocationDistance distance = [location distanceFromLocation:self.mapView.userLocation.location];
    
    cell.distanceLabel.text = [NSString stringWithFormat:@"%.02f km", (distance / 1000)];
    
    return cell;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField resignFirstResponder];
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder geocodeAddressString:self.textField.text completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        self.userLocation = placemarks[0].location;
        self.mapView.region = MKCoordinateRegionMake(self.userLocation.coordinate, MKCoordinateSpanMake(0.01, 0.01));
        self.postalCode = self.textField.text;
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self loadData];
    }];
    return YES;
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
                        theatre.title = theatreDictionary[@"name"];
                        theatre.subtitle = theatreDictionary[@"address"];
                        theatre.coordinate = CLLocationCoordinate2DMake([theatreDictionary[@"lat"] doubleValue], [theatreDictionary[@"lng"] doubleValue]);
                        [self.mapView addAnnotation:theatre];
                        [self.tableView reloadData];
                    }
                });
            }
        }
    }];
    [dataTask resume];
}

@end
