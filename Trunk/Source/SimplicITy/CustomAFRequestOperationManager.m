//
//  CustomAFRequestOperationManager.m
//  SimplicITy
//
//  Created by Varghese Simon on 1/2/15.
//  Copyright (c) 2015 Vmoksha. All rights reserved.
//

#import "CustomAFRequestOperationManager.h"

@implementation CustomAFRequestOperationManager

//- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)request
//                                                    success:(void (^)(AFHTTPRequestOperation *, id))success
//                                                    failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
//{
//    NSMutableURLRequest *modifiedRequest = [request mutableCopy];
//    
//    if (!self.reachabilityManager.isReachable)
//    {
//        modifiedRequest.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
//    }
//    
//    AFHTTPRequestOperation *operation = [super HTTPRequestOperationWithRequest:modifiedRequest
//                                                                       success:success
//                                                                       failure:failure];
//    
//    [operation setCacheResponseBlock:^NSCachedURLResponse *(NSURLConnection *connection, NSCachedURLResponse *cachedResponse) {
//        
//        NSURLResponse *response = cachedResponse.response;
////        if ([response isKindOfClass:NSHTTPURLResponse.class]) return cachedResponse;
//        
//        NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse*)response;
//        NSDictionary *headers = HTTPResponse.allHeaderFields;
//        if (headers[@"Cache-Control"]) return cachedResponse;
//        
//        NSMutableDictionary *modifiedHeaders = headers.mutableCopy;
//        modifiedHeaders[@"Cache-Control"] = @"max-age=60";
//        NSHTTPURLResponse *modifiedResponse = [[NSHTTPURLResponse alloc]
//                                               initWithURL:HTTPResponse.URL
//                                               statusCode:HTTPResponse.statusCode
//                                               HTTPVersion:@"HTTP/1.1"
//                                               headerFields:modifiedHeaders];
//        
//        cachedResponse = [[NSCachedURLResponse alloc]
//                          initWithResponse:modifiedResponse
//                          data:cachedResponse.data
//                          userInfo:cachedResponse.userInfo
//                          storagePolicy:cachedResponse.storagePolicy];
//        return cachedResponse;
//    }];
//    
//    return operation;
//}

- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)request
                                                    success:(void (^)(AFHTTPRequestOperation *operation,
                                                                      id responseObject))success
                                                    failure:(void (^)(AFHTTPRequestOperation *operation,
                                                                      NSError *error))failure
{
    NSMutableURLRequest *modifiedRequest = request.mutableCopy;
    AFNetworkReachabilityManager *reachability = self.reachabilityManager;
    if (!reachability.isReachable)
    {
        modifiedRequest.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    }
    
    AFHTTPRequestOperation *operation = [super HTTPRequestOperationWithRequest:modifiedRequest
                                                                       success:success
                                                                       failure:failure];
    
    [operation setCacheResponseBlock: ^NSCachedURLResponse *(NSURLConnection *connection,
                                                             NSCachedURLResponse *cachedResponse)
     {
         NSURLResponse *response = cachedResponse.response;
//         if ([response isKindOfClass:NSHTTPURLResponse.class]) return cachedResponse;
         
         NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse*)response;
         NSDictionary *headers = HTTPResponse.allHeaderFields;
//         if (headers[@"Cache-Control"]) return cachedResponse;
         
         NSMutableDictionary *modifiedHeaders = headers.mutableCopy;
         modifiedHeaders[@"Cache-Control"] = @"max-age=60";
         NSHTTPURLResponse *modifiedResponse = [[NSHTTPURLResponse alloc]
                                                initWithURL:HTTPResponse.URL
                                                statusCode:HTTPResponse.statusCode
                                                HTTPVersion:@"HTTP/1.1"
                                                headerFields:modifiedHeaders];
         
         cachedResponse = [[NSCachedURLResponse alloc]
                           initWithResponse:modifiedResponse
                           data:cachedResponse.data
                           userInfo:cachedResponse.userInfo
                           storagePolicy:cachedResponse.storagePolicy];
         return cachedResponse;
     }];
    return operation;
}

@end
