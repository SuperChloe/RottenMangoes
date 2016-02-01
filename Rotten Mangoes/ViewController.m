//
//  ViewController.m
//  Rotten Mangoes
//
//  Created by Chloe on 2016-02-01.
//  Copyright © 2016 Chloe Horgan. All rights reserved.
//

#import "ViewController.h"
#import "Movie.h"

@interface ViewController ()

@property (strong, nonatomic) NSMutableArray *objects;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSString *urlString = @"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?apikey=j9fhnct2tp8wu2q9h75kanh9";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            NSError *jsonParsingError;
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            if (!jsonParsingError) {
                NSLog(@"%@", jsonData);
                
                NSMutableArray *movieList = [NSMutableArray array];
                for (NSDictionary *movieDictionary in jsonData[@"movies"]) {
                    Movie *movie = [[Movie alloc] init];
                    movie.movieName = movieDictionary[@"full_name"];
                    movie.movieDescription = movieDictionary[@"description"];
                    
                    [movieList addObject:movie];
                }
                self.objects = movieList;
            }
        }
    }];
    [dataTask resume];    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
