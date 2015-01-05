//
//  Postman.m
//  EuLux
//
//  Created by Varghese Simon on 3/3/14.
//  Copyright (c) 2014 Vmoksha. All rights reserved.
//

#import "Postman.h"
#import "CustomAFRequestOperationManager.h"

@implementation Postman
{
    CustomAFRequestOperationManager *manager;
}

- (id)init
{
    if (self = [super init])
    {
        [self initiate];
    }
    
    return self;
}

- (void)initiate
{
    manager = [CustomAFRequestOperationManager manager];
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    manager.requestSerializer = requestSerializer;
}

- (void)post:(NSString *)URLString withParameters:(NSString *)parameter
{
    NSDictionary *parameterDict = [NSJSONSerialization JSONObjectWithData:[parameter dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    
    [manager POST:URLString
       parameters:parameterDict
          success:^(AFHTTPRequestOperation *operation, id responseObject){
              NSData *responseData = [operation responseData];
              [self.delegate postman:self gotSuccess:responseData];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [self.delegate postman:self gotFailure:error];
              NSLog(@"%@",error);
          }];
}

- (void)get:(NSString *)URLString
{
    [manager GET:URLString
      parameters:Nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             NSData *responseData = [operation responseData];
             [self.delegate postman:self gotSuccess:responseData];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             [self.delegate postman:self gotFailure:error];
             NSLog(@"%@",error);
             
         }];
}

@end
