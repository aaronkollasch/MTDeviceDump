//
//  main.m
//  MTDeviceDump
//
//  Created by Aaron on 8/9/22.
//

#import <Foundation/Foundation.h>
#import <IOKit/hid/IOHIDDeviceKeys.h>

typedef void *MTDeviceRef;

MTDeviceRef MTDeviceCreateDefault(void);
CFMutableArrayRef MTDeviceCreateList(void);

bool MTDeviceIsRunning(MTDeviceRef);
bool MTDeviceIsBuiltIn(MTDeviceRef);
bool MTDeviceIsAlive(MTDeviceRef);
bool MTDeviceIsOpaqueSurface(MTDeviceRef);
bool MTDeviceIsMTHIDDevice(MTDeviceRef);
io_service_t MTDeviceGetService(MTDeviceRef);
OSStatus MTDeviceGetSensorSurfaceDimensions(MTDeviceRef, int*, int*);
OSStatus MTDeviceGetSensorDimensions(MTDeviceRef, int*, int*);
OSStatus MTDeviceGetFamilyID(MTDeviceRef, int*);
OSStatus MTDeviceGetDeviceID(MTDeviceRef, uint64_t*);
OSStatus MTDeviceGetDriverType(MTDeviceRef, int*);
OSStatus MTDeviceGetVersion(MTDeviceRef, int*);
OSStatus MTDeviceGetGUID(MTDeviceRef, uuid_t*);

CFMutableArrayRef deviceList;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        deviceList = MTDeviceCreateList();
        for (CFIndex i = 0; i < CFArrayGetCount(deviceList); i++) {
            MTDeviceRef device = (MTDeviceRef)CFArrayGetValueAtIndex(deviceList, i);
            int familyID, driverType, version, dim1, dim2, sdim1, sdim2;
            uint64_t deviceID = 0;
            uuid_t GUID;
            MTDeviceGetFamilyID(device, &familyID);
            MTDeviceGetDeviceID(device, &deviceID);
            MTDeviceGetDriverType(device, &driverType);
            MTDeviceGetVersion(device, &version);
            MTDeviceGetSensorDimensions(device, &dim1, &dim2);
            MTDeviceGetSensorSurfaceDimensions(device, &sdim1, &sdim2);
            bool builtIn = MTDeviceIsBuiltIn(device);
            bool opaque = MTDeviceIsOpaqueSurface(device);
            bool isHID = MTDeviceIsMTHIDDevice(device);
            MTDeviceGetGUID(device, &GUID);
            NSMutableString *GUID_hex = [NSMutableString string];
            for (int i=0; i<sizeof(GUID); i++) {
                [GUID_hex appendFormat:@"%02x", GUID[i]];
                if (i == 3 || i == 5 || i == 7 || i == 9)
                    [GUID_hex appendString:@"-"];
            }
            CFStringRef deviceName = (CFStringRef)IORegistryEntrySearchCFProperty(MTDeviceGetService(device), kIOServicePlane, CFSTR(kIOHIDProductKey), kCFAllocatorDefault, kIORegistryIterateRecursively);
            
            NSLog(@"Device %li\n"
                  "      deviceID: %"PRIu64"\n"
                  "      familyID: %d\n"
                  "    driverType: %d\n"
                  "       version: %d\n"
//                  "          GUID: %@\n"
                  "   productName: %@\n"
                  "    dimensions: %d x %d\n"
                  "    surf. dim.: %.3f mm x %.3f mm\n"
                  "        opaque: %s\n"
                  "      built-in: %s\n"
                  " is HID device: %s\n",
                  (long)i,
                  deviceID,
                  familyID,
                  driverType,
                  version,
//                  GUID_hex,
                  deviceName,
                  dim1,
                  dim2,
                  sdim1/100.,
                  sdim2/100.,
                  opaque? "true" : "false",
                  builtIn? "true" : "false",
                  isHID? "true" : "false"
            );
        }
    }
    return 0;
}
