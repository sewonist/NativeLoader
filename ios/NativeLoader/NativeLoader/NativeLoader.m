//
//  NativeLoader.m
//  NativeLoader
//
//  Created by sewonist on 13. 3. 7..
//  Copyright (c) 2013년 sewonist. All rights reserved.
//

#import "FlashRuntimeExtensions.h"
#import "NativeLoader.h"
#import <UIKit/UIKit.h>
#import <SDWebImage/SDWebImageDownloader.h>

@implementation NativeLoader

@end

const char* EVENT_COMPLETE = "complete";
NSMutableDictionary* returnObjects;

NSString* storeReturnObject(NSString* key, id object)
{
    /*
    NSString* key;
    do
    {
        key = [NSString stringWithFormat: @"%i", random()];
    } while ( [returnObjects valueForKey:key] != nil );
    */
    [returnObjects setValue:object forKey:key];
    return key;
}

id getReturnObject(NSString* key, Boolean delete)
{
    id object = [returnObjects valueForKey:key];
    if(delete==TRUE){
        [returnObjects setValue:nil forKey:key];
    }
    return object;
}

FREObject nativeLoaderIsSupported(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[] ){
    FREObject retVal;
    if(FRENewObjectFromBool(YES, &retVal) == FRE_OK){
        return retVal;
    }else{
        return nil;
    }
}

FREObject loadImage(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[] ){
    uint32_t pathLength;
    const uint8_t * path;
    FREGetObjectAsUTF8(argv[0], &pathLength, &path);
    
    NSString * pathString = [NSString stringWithFormat:@"%s", path];
    NSURL *pathURL = [NSURL URLWithString:pathString];
    
    [SDWebImageDownloader.sharedDownloader downloadImageWithURL:pathURL
                                                        options:0
                                                       progress:^(NSUInteger receivedSize, long long expectedSize)
     {
         // progression tracking code
     }
                                                      completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
     {
         if (image && finished)
         {
             NSString* key = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             storeReturnObject(key, image);
             
             NSLog(@"[image loaded] key :  %@", key);
             FREDispatchStatusEventAsync( ctx, (uint8_t*)[key UTF8String], (uint8_t*)EVENT_COMPLETE );
         }
     }];
    
    return nil;
}

FREObject getLoadedImageWidth(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[] )
{
    uint32_t keyLength;
    const uint8_t *key;
    FREGetObjectAsUTF8(argv[0], &keyLength, &key);
    NSString *keyString = [NSString stringWithUTF8String:(char*)key];
    id pickedImage = getReturnObject(keyString, FALSE);
    
    if (pickedImage)
    {
        CGImageRef imageRef = [pickedImage CGImage];
        NSUInteger width = CGImageGetWidth(imageRef);
        
        FREObject result;
        if (FRENewObjectFromUint32(width, &result) == FRE_OK)
        {
            NSLog(@"width : %i", width);
            return result;
        }
        else return nil;
    }
    else return nil;
}

FREObject getLoadedImageHeight(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[] )
{
    uint32_t keyLength;
    const uint8_t *key;
    FREGetObjectAsUTF8(argv[0], &keyLength, &key);
    NSString *keyString = [NSString stringWithUTF8String:(char*)key];
    id pickedImage = getReturnObject(keyString, FALSE);
    
    if (pickedImage)
    {
        CGImageRef imageRef = [pickedImage CGImage];
        NSUInteger height = CGImageGetHeight(imageRef);
        
        FREObject result;
        if (FRENewObjectFromUint32(height, &result) == FRE_OK)
        {
            NSLog(@"height : %i", height);
            return result;
        }
        else return nil;
    }
    else return nil;
}

FREObject drawLoadedImageToBitmapData(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[] )
{
    uint32_t keyLength;
    const uint8_t *key;
    FREGetObjectAsUTF8(argv[0], &keyLength, &key);
    NSString *keyString = [NSString stringWithUTF8String:(char*)key];
    id pickedImage = getReturnObject(keyString, FALSE);
    
    NSLog(@"drawLoadedImageToBitmapData, key : %@", keyString);
    
    if (pickedImage)
    {
        NSLog(@"break-------001");
        // Get the AS3 BitmapData
        FREBitmapData bitmapData;
        FREAcquireBitmapData(argv[1], &bitmapData);
        NSLog(@"break-------002");
        // Pull the raw pixels values out of the image data
        CGImageRef imageRef = [pickedImage CGImage];
        NSUInteger width = CGImageGetWidth(imageRef);
        NSUInteger height = CGImageGetHeight(imageRef);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        unsigned char *rawData = malloc(height * width * 4);
        NSUInteger bytesPerPixel = 4;
        NSUInteger bytesPerRow = bytesPerPixel * width;
        NSUInteger bitsPerComponent = 8;
        CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGColorSpaceRelease(colorSpace);
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        CGContextRelease(context);
        NSLog(@"break-------003");
        // Pixels are now it rawData in the format RGBA8888
        // Now loop over each pixel to write them into the AS3 BitmapData memory
        int x, y;
        // There may be extra pixels in each row due to the value of lineStride32.
        // We'll skip over those as needed.
        int offset = bitmapData.lineStride32 - bitmapData.width;
        int offset2 = bytesPerRow - bitmapData.width*4;
        int byteIndex = 0;
        uint32_t *bitmapDataPixels = bitmapData.bits32;
        for (y=0; y<bitmapData.height; y++)
        {
            for (x=0; x<bitmapData.width; x++, bitmapDataPixels++, byteIndex += 4)
            {
                // Values are currently in RGBA7777, so each color value is currently a separate number.
                int red     = (rawData[byteIndex]);
                int green   = (rawData[byteIndex + 1]);
                int blue    = (rawData[byteIndex + 2]);
                int alpha   = (rawData[byteIndex + 3]);
                
                // Combine values into ARGB32
                *bitmapDataPixels = (alpha << 24) | (red << 16) | (green << 8) | blue;
            }
            
            bitmapDataPixels += offset;
            byteIndex += offset2;
        }
        
        // Free the memory we allocated
        free(rawData);
        NSLog(@"break-------004");
        // Tell Flash which region of the BitmapData changes (all of it here)
        FREInvalidateBitmapDataRect(argv[1], 0, 0, bitmapData.width, bitmapData.height);
        
        // Release our control over the BitmapData
        FREReleaseBitmapData(argv[1]);
    }
    
    return nil;
}


// ContextInitializer()
//
// The context initializer is called when the runtime creates the extension context instance.

void NativeLoaderContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx,
                                  uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    int count = 5;
	*numFunctionsToTest = count;
	FRENamedFunction* func = (FRENamedFunction*)malloc(sizeof(FRENamedFunction) * count);
    
	func[0].name = (const uint8_t*)"isSupported";
	func[0].functionData = NULL;
	func[0].function = &nativeLoaderIsSupported;
	
    func[1].name = (const uint8_t*)"loadImage";
	func[1].functionData = NULL;
	func[1].function = &loadImage;
    
    func[2].name = (const uint8_t*)"getLoadedImageWidth";
	func[2].functionData = NULL;
	func[2].function = &getLoadedImageWidth;
    
    func[3].name = (const uint8_t*)"getLoadedImageHeight";
	func[3].functionData = NULL;
	func[3].function = &getLoadedImageHeight;
    
    func[4].name = (const uint8_t*)"drawLoadedImageToBitmapData";
	func[4].functionData = NULL;
	func[4].function = &drawLoadedImageToBitmapData;
    
	*functionsToSet = func;
    
    returnObjects = [[NSMutableDictionary alloc] init];
}

// ContextFinalizer()
//
// The context finalizer is called when the extension's ActionScript code
// calls the ExtensionContext instance's dispose() method.
// If the AIR runtime garbage collector disposes of the ExtensionContext instance, the runtime also calls
// ContextFinalizer().

void NativeLoaderContextFinalizer(FREContext ctx)
{
	return;
}

// ExtInitializer()
//
// The extension initializer is called the first time the ActionScript side of the extension
// calls ExtensionContext.createExtensionContext() for any context.

void NativeLoaderExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet,
                              FREContextFinalizer* ctxFinalizerToSet)
{
	*extDataToSet = NULL;
	*ctxInitializerToSet = &NativeLoaderContextInitializer;
	*ctxFinalizerToSet = &NativeLoaderContextFinalizer;
}

// ExtFinalizer()
//
// The extension finalizer is called when the runtime unloads the extension. However, it is not always called.

void NativeLoaderExtFinalizer(void* extData)
{
	return;
}
