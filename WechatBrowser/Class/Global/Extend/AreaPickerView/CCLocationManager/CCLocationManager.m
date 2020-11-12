//
//  CCLocationManager.m
//

#import "CCLocationManager.h"
#import "Global.h"

#pragma mark - 模拟器指定位置
#if TARGET_IPHONE_SIMULATOR
@interface CLLocationManager (Simulator)
@end
@implementation CLLocationManager (Simulator)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void)startUpdatingLocation{
	double latitude = 23.123150;
	double longitude = 113.408790;
	CLLocation *locations = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
	if (self.delegate && [self.delegate respondsToSelector:@selector(locationManager:didUpdateLocations:)]) {
		[self.delegate locationManager:self didUpdateLocations:@[locations]];
	}
}
#pragma clang diagnostic pop
@end
#endif

#pragma mark - WGS-84转GCJ-02(火星坐标)
@interface WGS84TOGCJ02 : NSObject
+ (BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location; //判断是不是在中国
+ (CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D)wgsLoc; //转GCJ-02
@end
const double a = 6378245.0;
const double ee = 0.00669342162296594323;
const double pi = 3.14159265358979324;
@implementation WGS84TOGCJ02
+ (CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D)wgsLoc{
	CLLocationCoordinate2D adjustLoc;
	if ([self isLocationOutOfChina:wgsLoc]) {
		adjustLoc = wgsLoc;
	} else {
		double adjustLat = [self transformLatWithX:wgsLoc.longitude - 105.0 withY:wgsLoc.latitude - 35.0];
		double adjustLon = [self transformLonWithX:wgsLoc.longitude - 105.0 withY:wgsLoc.latitude - 35.0];
		double radLat = wgsLoc.latitude / 180.0 * pi;
		double magic = sin(radLat);
		magic = 1 - ee * magic * magic;
		double sqrtMagic = sqrt(magic);
		adjustLat = (adjustLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
		adjustLon = (adjustLon * 180.0) / (a / sqrtMagic * cos(radLat) * pi);
		adjustLoc.latitude = wgsLoc.latitude + adjustLat;
		adjustLoc.longitude = wgsLoc.longitude + adjustLon;
	}
	return adjustLoc;
}
+ (BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location{
	if (location.longitude<72.004 || location.longitude>137.8347 || location.latitude<0.8293 || location.latitude>55.8271) return YES;
	return NO;
}
+ (double)transformLatWithX:(double)x withY:(double)y{
	double lat = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
	lat += (20.0 * sin(6.0 * x * pi) + 20.0 *sin(2.0 * x * pi)) * 2.0 / 3.0;
	lat += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0;
	lat += (160.0 * sin(y / 12.0 * pi) + 3320 * sin(y * pi / 30.0)) * 2.0 / 3.0;
	return lat;
}
+ (double)transformLonWithX:(double)x withY:(double)y{
	double lon = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
	lon += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
	lon += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0;
	lon += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0 * pi)) * 2.0 / 3.0;
	return lon;
}
@end

#pragma mark - CCLocationManager
@interface CCLocationManager (){
	CLLocationManager *_manager;
	BOOL _isBaidu;
}
@property (nonatomic, strong) LocationBlock locationBlock;
@property (nonatomic, strong) LocationLLBlock locationllBlock;
@property (nonatomic, strong) JsonBlock jsonBlock;
@property (nonatomic, strong) AddressBlock addressBlock;
@property (nonatomic, strong) LocationErrorBlock errorBlock;
@property (nonatomic, strong) CoordinateAddressBlock coordinateAddressBlock;
@end

@implementation CCLocationManager

+ (CCLocationManager *)shareLocation{
	static dispatch_once_t once = 0;
	static CCLocationManager *sharedObject;
	dispatch_once(&once, ^{ sharedObject = [[CCLocationManager alloc] init]; });
	return sharedObject;
}

//获取经纬度
- (void)getLocationCoordinate:(LocationBlock)locaiontBlock{
	_locationBlock = locaiontBlock;
	[self startLocation];
}

//获取经纬度,返回double类型
- (void)getLocationCoordinateWithDouble:(LocationLLBlock)locaiontllBlock{
	_locationllBlock = locaiontllBlock;
	[self startLocation];
}
- (void)getBaiduCoordinateWithDouble:(LocationLLBlock)locaiontllBlock{
	_isBaidu = YES;
	_locationllBlock = locaiontllBlock;
	[self startLocation];
}

//获取坐标和详细地址信息
- (void)getCoordinateAndAddress:(CoordinateAddressBlock)coordinateAddressBlock{
	[self getCoordinateAndAddress:coordinateAddressBlock error:nil];
}
- (void)getCoordinateAndAddress:(CoordinateAddressBlock)coordinateAddressBlock error:(LocationErrorBlock)errorBlock{
	_coordinateAddressBlock = coordinateAddressBlock;
	_errorBlock = errorBlock;
	[self startLocation];
}
- (void)getBaiduCoordinateAndAddress:(CoordinateAddressBlock)coordinateAddressBlock{
	[self getBaiduCoordinateAndAddress:coordinateAddressBlock error:nil];
}
- (void)getBaiduCoordinateAndAddress:(CoordinateAddressBlock)coordinateAddressBlock error:(LocationErrorBlock)errorBlock{
	_isBaidu = YES;
	_coordinateAddressBlock = coordinateAddressBlock;
	_errorBlock = errorBlock;
	[self startLocation];
}

- (void)getBaiduGeocoder:(JsonBlock)jsonBlock{
	_isBaidu = YES;
	_jsonBlock = jsonBlock;
	[self startLocation];
}

//获取省市区
- (void)getCity:(AddressBlock)addressBlock{
	[self getCity:addressBlock error:nil];
}
- (void)getCity:(AddressBlock)addressBlock error:(LocationErrorBlock)errorBlock{
	_addressBlock = addressBlock;
	_errorBlock = errorBlock;
	[self startLocation];
}

//获取详细地址
- (void)getDetail:(AddressBlock)addressBlock{
	_addressBlock = addressBlock;
	[self startLocation];
}

//根据地址查询经纬度
- (void)getCoordinateWithAddress:(NSString *)address completion:(LocationBlock)completion{
	if (!completion) return;
	CLGeocoder *geocoder = [[CLGeocoder alloc]init];
	[geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
		if ([placemarks count]>0 && error==nil) {
			//NSLog(@"Found %ld placemark(s).", (long)placemarks.count);
			CLPlacemark *placemark = [placemarks objectAtIndex:0];
			completion(placemark.location.coordinate);
		} else if ([placemarks count]==0 && error==nil) {
			NSLog(@"Found no placemarks.");
			completion(CLLocationCoordinate2DMake(0, 0));
		} else if (error!=nil) {
			NSLog(@"An error occurred = %@", error);
		}
	}];
}
- (void)getBaiduCoordinateWithAddress:(NSString *)address completion:(LocationBlock)completion{
	if (!completion) return;
	[Common getApiWithUrl:@"http://int.dpool.sina.com.cn/iplookup/iplookup.php?format=json" success:^(NSMutableDictionary *json) {
		[Common getApiWithUrl:BAIDU_PLACE(address.URLEncode, [json[@"city"] URLEncode]) success:^(NSMutableDictionary *json) {
			if ([json[@"status"] integerValue]==0 && [json[@"results"] isArray]) {
				NSDictionary *dict = json[@"results"][0];
				CLLocationCoordinate2D pt = CLLocationCoordinate2DMake([dict[@"location"][@"lat"] floatValue], [dict[@"location"][@"lng"] floatValue]);
				completion(pt);
			}
		} fail:nil];
	} fail:nil];
}

//根据经纬度查询地址
- (void)getAddressWithCoordinate:(CLLocationCoordinate2D)coordinate completion:(AddressBlock)completion{
	if (!completion) return;
	CLLocation *newLocation = [[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
	CLGeocoder *geocoder = [[CLGeocoder alloc] init];
	[geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *array, NSError *error) {
		if (!error && array.count > 0) {
			CLPlacemark *placemark = [array objectAtIndex:0];
			NSString *country = placemark.country ? placemark.country : @""; //国家
			NSString *province = placemark.administrativeArea ? placemark.administrativeArea : @""; //省
			NSString *city = placemark.locality ? placemark.locality : @""; //市
			NSString *district = placemark.subLocality ? placemark.subLocality : @""; //区
			NSString *road = placemark.thoroughfare ? placemark.thoroughfare : @""; //道路
			NSString *room = placemark.subThoroughfare ? placemark.subThoroughfare : @""; //门牌
			NSString *code = placemark.ISOcountryCode ? placemark.ISOcountryCode : @""; //国家代号
			NSString *name = placemark.name ? placemark.name : @""; //详细地方名
			NSString *address = [NSString stringWithFormat:@"%@%@", road, room]; //地址
			NSString *addressDetail = [NSString stringWithFormat:@"%@%@%@%@%@", province, city, district, road, room]; //详细地址
			NSDictionary *dictionary = @{
										 @"country" : country,
										 @"province" : province,
										 @"city" : city,
										 @"district" : district,
										 @"road" : road,
										 @"room" : room,
										 @"code" : code,
										 @"name" : name
										 };
			completion(province, city, district, address, addressDetail, dictionary);
		}
	}];
}
- (void)getBaiduAddressWithCoordinate:(CLLocationCoordinate2D)coordinate completion:(AddressBlock)completion{
	if (!completion) return;
	[Common getApiWithUrl:BAIDU_GEOCODER(@(coordinate.latitude), @(coordinate.longitude)) success:^(NSMutableDictionary *json) {
		if ([json[@"status"] integerValue]==0) {
			NSDictionary *dict = json[@"result"][@"addressComponent"];
			NSString *country = dict[@"country"];
			NSString *province = dict[@"province"];
			NSString *city = dict[@"city"];
			NSString *district = dict[@"district"];
			NSString *road = dict[@"street"];
			NSString *room = dict[@"street_number"];
			NSString *code = dict[@"country_code"];
			NSString *name = @"";
			NSString *address = [NSString stringWithFormat:@"%@%@", road, room];
			NSString *addressDetail = [NSString stringWithFormat:@"%@%@%@%@%@", province, city, district, road, room];
			NSDictionary *dictionary = @{
										 @"country" : country,
										 @"province" : province,
										 @"city" : city,
										 @"district" : district,
										 @"road" : road,
										 @"room" : room,
										 @"code" : code,
										 @"name" : name
										 };
			completion(province, city, district, address, addressDetail, dictionary);
		}
	} fail:nil];
}

//计算两个位置之间的距离,单位米
- (double)distanceWithLat1:(double)lat1 lng1:(double)lng1 lat2:(double)lat2 lng2:(double)lng2{
	CLLocation *location1 = [[CLLocation alloc]initWithLatitude:lat1 longitude:lng1];
	CLLocation *location2 = [[CLLocation alloc]initWithLatitude:lat2 longitude:lng2];
	return [location1 distanceFromLocation:location2];
}

- (void)startLocation{
	if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
		_manager = [[CLLocationManager alloc]init];
		_manager.delegate = self;
		_manager.distanceFilter = 10;
		_manager.desiredAccuracy = kCLLocationAccuracyBest;
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
			//[_manager requestAlwaysAuthorization];
			[_manager requestWhenInUseAuthorization];
		}
		[_manager startUpdatingLocation];
	} else {
		UIAlertView *alvertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"需要开启定位服务,请到设置->隐私,打开定位服务" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
		[alvertView show];
		if (_locationllBlock) {
			_locationllBlock(0.0, 0.0);
			_locationllBlock = nil;
		}
		if (_addressBlock) {
			_addressBlock(nil, nil, nil, nil, nil, nil);
			_addressBlock = nil;
		}
		if (_jsonBlock) {
			_jsonBlock(nil);
			_jsonBlock = nil;
		}
		if (_coordinateAddressBlock) {
			_coordinateAddressBlock(CLLocationCoordinate2DMake(0, 0), nil, nil, nil, nil, nil, nil);
			_coordinateAddressBlock = nil;
		}
		if (_errorBlock) _errorBlock(nil);
	}
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
	CLLocation *newLocation = [locations firstObject];
	CLLocationCoordinate2D lastCoordinate = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude);
	
	if (!_isBaidu) {
		if (![WGS84TOGCJ02 isLocationOutOfChina:[newLocation coordinate]]) {
			lastCoordinate = [WGS84TOGCJ02 transformFromWGSToGCJ:[newLocation coordinate]];
		}
		
		if (_locationBlock) {
			_locationBlock(lastCoordinate);
			_locationBlock = nil;
		}
		
		if (_locationllBlock) {
			_locationllBlock(lastCoordinate.latitude, lastCoordinate.longitude);
			_locationllBlock = nil;
		}
		
		if (_addressBlock || _coordinateAddressBlock) {
			//根据经纬度查询地址
			CLGeocoder *geocoder = [[CLGeocoder alloc]init];
			[geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
				NSDictionary *dictionary = [NSDictionary dictionary];
				NSString *addressDetail = @"";
				NSString *province = @"";
				NSString *city = @"";
				NSString *district = @"";
				NSString *address = @"";
				
				if (placemarks.count > 0) {
					CLPlacemark *placemark = [placemarks objectAtIndex:0];
					province = placemark.administrativeArea ? placemark.administrativeArea : @""; //省
					city = placemark.locality ? placemark.locality : @""; //市
					district = placemark.subLocality ? placemark.subLocality : @""; //区
					
					NSString *country = placemark.country ? placemark.country : @""; //国家
					NSString *road = placemark.thoroughfare ? placemark.thoroughfare : @""; //道路
					NSString *room = placemark.subThoroughfare ? placemark.subThoroughfare : @""; //门牌
					NSString *code = placemark.ISOcountryCode ? placemark.ISOcountryCode : @""; //国家代号
					NSString *name = placemark.name ? placemark.name : @""; //详细地方名
					address = [NSString stringWithFormat:@"%@%@", road, room]; //地址
					
					addressDetail = [NSString stringWithFormat:@"%@%@%@%@%@", province, city, district, road, room]; //详细地址
					dictionary = @{
							   @"country" : country,
							   @"province" : province,
							   @"city" : city,
							   @"district" : district,
							   @"road" : road,
							   @"room" : room,
							   @"code" : code,
							   @"name" : name
							   };
				}
				
				if (_addressBlock) {
					_addressBlock(province, city, district, address, addressDetail, dictionary);
					_addressBlock = nil;
				}
				
				if (_coordinateAddressBlock) {
					_coordinateAddressBlock(CLLocationCoordinate2DMake(lastCoordinate.latitude, lastCoordinate.longitude), province, city, district, address, addressDetail, dictionary);
					_coordinateAddressBlock = nil;
				}
			}];
		}
		
	} else {
		[Common getApiWithUrl:BAIDU_GEOCONV(FORMAT(@"%f", lastCoordinate.latitude), FORMAT(@"%f", lastCoordinate.longitude)) success:^(NSMutableDictionary *json) {
			if ([json[@"status"] integerValue]==0) {
				NSDictionary *dict = json[@"result"][0];
				CLLocationCoordinate2D pt = (CLLocationCoordinate2D){[dict[@"y"] floatValue], [dict[@"x"] floatValue]};
				NSString *lng = FORMAT(@"%f", [dict[@"x"] floatValue]);
				NSString *lat = FORMAT(@"%f", [dict[@"y"] floatValue]);
				
				if (_locationBlock) {
					_locationBlock(pt);
					_locationBlock = nil;
				}
				
				if (_locationllBlock) {
					_locationllBlock(pt.latitude, pt.longitude);
					_locationllBlock = nil;
				}
				
				if (_addressBlock || _jsonBlock || _coordinateAddressBlock) {
					[Common getApiWithUrl:BAIDU_GEOCODER(lat, lng) success:^(NSMutableDictionary *json) {
						//NSLog(@"%@", json.descriptionASCII);
						if ([json[@"status"] integerValue]==0) {
							NSDictionary *dict = json[@"result"][@"addressComponent"];
							
							NSString *province = dict[@"province"];
							NSString *city = dict[@"city"];
							NSString *district = dict[@"district"];
							NSString *country = dict[@"country"];
							NSString *road = dict[@"street"];
							NSString *room = dict[@"street_number"];
							NSString *code = dict[@"country_code"];
							NSString *name = @"";
							NSString *address = [NSString stringWithFormat:@"%@%@", road, room];
							NSString *addressDetail = [NSString stringWithFormat:@"%@%@%@%@%@", province, city, district, road, room];
							NSDictionary *dictionary = @{
													 @"country" : country,
													 @"province" : province,
													 @"city" : city,
													 @"district" : district,
													 @"road" : road,
													 @"room" : room,
													 @"code" : code,
													 @"name" : name
													 };
							
							if (_addressBlock) {
								_addressBlock(province, city, district, address, addressDetail, dictionary);
								_addressBlock = nil;
							}
							
							if (_jsonBlock) {
								_jsonBlock(json);
								_jsonBlock = nil;
							}
							
							if (_coordinateAddressBlock) {
								_coordinateAddressBlock(CLLocationCoordinate2DMake(pt.latitude, pt.longitude), province, city, district, address, addressDetail, dictionary);
								_coordinateAddressBlock = nil;
							}
						}
					} fail:nil];
				}
			}
		} fail:nil];
	}
	
	[_manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
	if (_errorBlock) _errorBlock(error);
	_manager = nil;
}

@end
