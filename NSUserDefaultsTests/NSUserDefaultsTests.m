//
//  NSUserDefaultsTestsTests.m
//  NSUserDefaultsTestsTests
//
//  Created by Andy Mroczkowski on 9/4/12.
//  Copyright (c) 2012 Andy Mroczkowski. All rights reserved.
//

#import "NSUserDefaultsTests.h"

@interface NSUserDefaultsTests ()
@property (strong) NSString *myDomainName;
@end

@implementation NSUserDefaultsTests

// !!!: Since NSUserDefaults is a singleton, we have to go through extra work to create a clean state for every test

+ (NSString *)myDomainName
{
    // I thought this should be [[NSBundle mainBundle] bundleIdentifier], but it returns nil.
    // hardcoding until I can figure out the programatic way.
    return @"otest";
}

- (void)_restorePersistentDomainState
{
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[self class] myDomainName]];
}

- (void)_restoreVolatileDomainState
{
    NSArray *validVolatileDomains = @[NSRegistrationDomain, NSArgumentDomain];
    NSArray *currentVolatileDomains = [[NSUserDefaults standardUserDefaults] volatileDomainNames];
    for (NSString *volatileDomain in currentVolatileDomains) {
        if (![validVolatileDomains containsObject:volatileDomain]) {
            [[NSUserDefaults standardUserDefaults] removeVolatileDomainForName:volatileDomain];
        }
    }
}

- (void)setUp
{
    [super setUp];
    

    [self _restorePersistentDomainState];
    [self _restoreVolatileDomainState];
    
    [NSUserDefaults resetStandardUserDefaults];
}

- (void)tearDown
{    
    [super tearDown];
}

#pragma mark - 

- (void)testSynchronizationBetweenInstances
{
    NSUserDefaults *master = [[NSUserDefaults alloc] init];
    NSUserDefaults *slave = [[NSUserDefaults alloc] init];
    
    STAssertNil([master objectForKey:@"someKey"],
                @"key should be nil initially");
    STAssertNil([slave objectForKey:@"someKey"],
                @"key should be nil initially");

    NSString *value = [[NSDate date] description];
    [master setObject:value forKey:@"someKey"];
    
    STAssertEqualObjects([slave objectForKey:@"someKey"], value,
                         @"values should be equal");
}

#pragma mark - Persitent Domains

- (void)testSetPersistentDomain
{
    NSString *domainName = @"net.mrox.persistent";
    
    STAssertFalse([[[NSUserDefaults standardUserDefaults] persistentDomainNames] containsObject:domainName],
                  @"The persistent domain should not exist before it's added.");

    [[NSUserDefaults standardUserDefaults] setPersistentDomain:@{} forName:domainName];

    STAssertFalse([[[NSUserDefaults standardUserDefaults] persistentDomainNames] containsObject:domainName],
                 @"A persistent domain should NOT have been added. Only persistent domains that match the bundle ID seem to be allowed.");
}

- (void)testGetValueViaPersistentDomain
{
    NSString *domainName = [[self class] myDomainName];
    
    NSString *value = [[NSDate date] description];
    
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:@"someKey"];
    
    NSDictionary *domain = [[NSUserDefaults standardUserDefaults] persistentDomainForName:domainName];

    STAssertEqualObjects([domain objectForKey:@"someKey"], value,
                         @"Values should be equal.");
    
}

#pragma mark - Volatile Domains

- (void)testSetVolatileDomain
{
    NSString *domainName = @"net.mrox.volatile";
    
    STAssertFalse([[[NSUserDefaults standardUserDefaults] volatileDomainNames] containsObject:domainName],
                 @"The volatile domain should not exist before it's added.");

    [[NSUserDefaults standardUserDefaults] setVolatileDomain:@{} forName:domainName];
    
    STAssertTrue([[[NSUserDefaults standardUserDefaults] volatileDomainNames] containsObject:domainName],
                 @"A volatile domain should have been added.");
}

- (void)testReadVolatileDomain
{
    NSString *domainName = @"net.mrox.volatile";

    STAssertNil([[NSUserDefaults standardUserDefaults] volatileDomainForName:domainName],
                @"The configuration dictionary should be nil, initiallly");
    
    NSDictionary *config = @{ @"volatileKey" : @5 };
    [[NSUserDefaults standardUserDefaults] setVolatileDomain:config forName:domainName];

    STAssertEqualObjects(config, [[NSUserDefaults standardUserDefaults] volatileDomainForName:domainName],
                         @"The configuration dictionary should now be the dictionary we set.");
}

@end
